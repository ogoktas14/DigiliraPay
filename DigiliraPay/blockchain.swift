//
//  Blockchain.swift
//  WavesSDKUI
//
//  Created by Hayrettin İletmiş on 6.07.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions
import RxSwift
import Locksmith
import Foundation
import LocalAuthentication


class Blockchain: NSObject {
    
    struct signData {
        var signature: String
        var publicKey: String
        var wallet: String
    }
    
    private var isCertificatePinning: Bool = true
    
    // MARK: - GetCurrencies
    struct GetCurrencies: Codable {
        let type: String
        let pageInfo: PageInfo
        let items: [Item]
        
        enum CodingKeys: String, CodingKey {
            case type
            case pageInfo = "page_info"
            case items
        }
    }
    
    enum Status: String, Codable {
        case active = "active"
    }
    
    enum TypeEnum: String, Codable {
        case depositCurrency = "deposit_currency"
    }
    
    // MARK: - PageInfo
    struct PageInfo: Codable {
        let hasNextPage: Bool
        
        enum CodingKeys: String, CodingKey {
            case hasNextPage = "has_next_page"
        }
    }
    // MARK: - Item
    struct Item: Codable {
        let type: TypeEnum
        let id: String
        let wavesAssetID: String?
        let decimals: Int
        let status: Status
        let allowedAmount: AllowedAmount
        let fees: Fees
        
        enum CodingKeys: String, CodingKey {
            case type, id
            case wavesAssetID = "waves_asset_id"
            case decimals, status
            case allowedAmount = "allowed_amount"
            case fees
        }
    }
    // MARK: - WithdrawAddresses
    struct WithdrawAddresses: Codable {
        let type: String
        let currency: Currency
        let proxyAddresses: [String]
        
        enum CodingKeys: String, CodingKey {
            case type, currency
            case proxyAddresses = "proxy_addresses"
        }
    }
    
    // MARK: - WavesToken
    struct WavesToken: Codable {
        let accessToken, tokenType, refreshToken: String
        let expiresIn: Int
        let scope: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
            case scope
        }
    }
    
    
    // MARK: - DepositeAddresses
    struct DepositeAddresses: Codable {
        let type: String
        let currency: Currency
        let depositAddresses: [String]
        
        enum CodingKeys: String, CodingKey {
            case type, currency
            case depositAddresses = "deposit_addresses"
        }
    }
    
    // MARK: - Currency
    struct Currency: Codable {
        let type, id, wavesAssetID: String
        let decimals: Int
        let status: String
        let allowedAmount: AllowedAmount
        let fees: Fees
        
        enum CodingKeys: String, CodingKey {
            case type, id
            case wavesAssetID = "waves_asset_id"
            case decimals, status
            case allowedAmount = "allowed_amount"
            case fees
        }
    }
    
    // MARK: - AllowedAmount
    struct AllowedAmount: Codable {
        let min, max: Double
    }
    
    // MARK: - Fees
    struct Fees: Codable {
        let flat, rate: Int
    }
    
    private var balances: NodeService.DTO.AddressAssetsBalance?
    private var disposeBag: DisposeBag = DisposeBag()
    private var disposeBag2: DisposeBag = DisposeBag()
    
    private let wavesCrypto: WavesCrypto = WavesCrypto()
    
    let digiliraPay = digiliraPayApi()
    let throwEngine = ErrorHandling()
    var crud = centralRequest()
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    
    var onAssetBalance: ((_ result: NodeService.DTO.AddressAssetsBalance)->())?
    var onTransferTransaction: ((_ result: NodeService.DTO.Transaction, _ verifyData: TransferOnWay )->())?
    var onVerified: ((_ result: [String : AnyObject], _ verifyData: TransferOnWay)->())?
    var onSensitive: ((_ result: digilira.wallet, _ err: String)->())?
    var onError: ((_ result: Error)->())?
    var onPinSuccess: ((_ result: Bool)->())?
    var onSmartAvailable: ((_ result: Bool)->())?
    var onMember: ((_ result: Bool, _ data: digilira.externalTransaction?)->())?
    
    var onComplete: ((_ result: Bool, _ statusCode: Int)->())?
    
    var onWavesApiError: ((_ result: String, _ statusCode: Int, _ path: String)->())?
    var onWavesTokenResponse: ((_ result: Data, _ statusCode: Int) ->())?
    
    func checkAssetBalance(address: String ) {
        
        WavesSDK.shared.services.nodeServices.assetsNodeService
            .assetsBalances(address: address)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (balances) in
                
                self.onAssetBalance?(balances)
            }, onError: {_ in
                self.onError!(digilira.NAError.noBalance)
            })
            .disposed(by: disposeBag)
    }
    
    func sendTransaction2(name: String, recipient: String, fee: Int64, amount:Int64, assetId:String, attachment:String, wallet:digilira.wallet, blob: SendTrx) {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard let address = WavesCrypto.shared.address(seed: wallet.seed, chainId: chainId) else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed) else { return }
        guard wallet.seed != "" else { return }
        
        let feeAssetId = digilira.sponsorToken
        
        var attachmentValidation = attachment
        if attachmentValidation == "" {
            attachmentValidation = "DIGILIRAPAY TRANSFER"
        }
        
        let buf: [UInt8] = Array(attachmentValidation.utf8)
        let attachment58 = WavesCrypto.shared.base58encode(input: buf)
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        var queryModel = NodeService.Query.Transaction.Transfer(recipient: recipient,
                                                                assetId: assetId,
                                                                amount: amount,
                                                                fee: fee,
                                                                attachment: attachment58!,
                                                                feeAssetId: feeAssetId,
                                                                timestamp: timestamp,
                                                                senderPublicKey: senderPublicKey, chainId: chainId)
        
        
        // sign transfer transaction using seed
        queryModel.sign(seed: wallet.seed)
        
        let send = NodeService.Query.Transaction.transfer(queryModel)
        
        WavesSDK.shared.services
            .nodeServices // You can choose different Waves services: node, matcher and data service
            .transactionNodeService // Here methods of service
            .transactions(query: send)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [self] (tx) in
                if let txid = tx.dictionary["id"] as? String {
                    var external = "N/A"
                    var merchantId = "N/A"
                    
                    switch blob.destination {
                    case digilira.transactionDestination.foreign:
                        external = blob.externalAddress!
                        break
                    case digilira.transactionDestination.domestic:
                        merchantId = blob.merchantId!
                        break
                    default:
                        break
                    }
                    if blob.destination != digilira.transactionDestination.foreign {
                        if blob.externalAddress != nil {
                            external = blob.externalAddress!
                        }
                    }
                    
                    let v:[String] = [amount.description, assetId.description, attachmentValidation, blob.blockchainFee.description, blob.destination, external, fee.description, feeAssetId, merchantId, blob.me, recipient, name, blob.fiat.description, 0.description, txid]
                    let sign1 = try? bytization(v, timestamp)
                    
                    let t = TransferOnWay.init(recipientName: name,
                                               recipient: recipient,
                                               myName: blob.me,
                                               wallet: address,
                                               amount: amount,
                                               assetId: assetId,
                                               tickerTl: blob.fiat,
                                               tickerUsd: 0,
                                               fee: fee,
                                               feeAssetId: feeAssetId,
                                               blockchainFee: blob.blockchainFee,
                                               transactionID: txid,
                                               destination: blob.destination,
                                               externalAddress: external,
                                               attachment: attachmentValidation,
                                               merchantId: merchantId,
                                               publicKey: sign1!.publicKey,
                                               signed: sign1!.signature,
                                               timestamp: timestamp)
                    
                    self.onTransferTransaction?(tx, t)
                }
                
            }, onError: { (error ) -> Void in
                
                if let s = error as? NetworkError{
                    self.onError!(s)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func getUserId() throws -> String {
        do {
            let data = try secretKeys.userData()
            return data.id
        } catch  {
            throw digilira.NAError.emptyAuth
        }
    }
    
    func massTransferTx(name:String, recipient: String, fee: Int64, amount:Int64, assetId:String, attachment:String, wallet:digilira.wallet, blob: SendTrx) {
         
        sendTransaction2(name:name, recipient: recipient, fee: fee, amount:amount, assetId:assetId, attachment:attachment, wallet:wallet, blob: blob)
    }
     
    func verifyTrx(txid: String, t: TransferOnWay) {
        getTransactionId(rURL: WavesSDK.shared.enviroment.nodeUrl.description + "/transactions/info/" + txid, t:t)
        
    }
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) -> T? where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch let parsingError {
            print("Error", parsingError)
            return nil
        }
        
    }
    
    private func wavesApi(seed: String) {
        
        UserDefaults.standard.removeObject(forKey: "btcAddress")
        UserDefaults.standard.removeObject(forKey: "ethAddress")
        UserDefaults.standard.removeObject(forKey: "ltcAddress")
        UserDefaults.standard.removeObject(forKey: "usdtAddress")
        
        self.onWavesApiError = { res, sts, path in
            print(res,sts, path)
        }
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard WavesCrypto.shared.address(seed: seed, chainId: chainId) != nil else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: seed) else { return }
        
        let client_id = digilira.wavesApiEndpoints.client_id;
        
        let timestamp = Int64(Date().timeIntervalSince1970) + 1000 * 60
        var bytes: [UInt8] = [255, 255, 255, 1]
        
        let byteString = chainId + ":" + client_id + ":" + timestamp.description
        
        let array: [UInt8] = Array(byteString.utf8)
        bytes.append(contentsOf: array)
                
        if let preSign = wavesCrypto.signBytes(bytes: bytes, seed: seed) {
            if let bs58 = WavesCrypto.shared.base58encode(input: preSign) {
                let params = digilira.authTokenWaves.init(
                    username: senderPublicKey,
                    password: timestamp.description + ":" + bs58
                )
                wavesApiRequest(auth: params, endpoint:digilira.wavesApiEndpoints.getToken, sender:WavesToken.self){ [self] (token, statusCode) in
                    
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.BTC, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[1], forKey: "btcAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.ETH, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[0], forKey: "ethAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.LTC, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[0], forKey: "ltcAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.USDT, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[0], forKey: "usdtAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                }
            }
        }
    }
    
    
    
    func getWavesToken(wallet: digilira.wallet) {
        
        let seed = wallet.seed
        
        self.onWavesApiError = { res, sts, path in
            print(res,sts, path)
        }
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard WavesCrypto.shared.address(seed: seed, chainId: chainId) != nil else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: seed) else { return }
        
        let client_id = digilira.wavesApiEndpoints.client_id;
        
        let timestamp = Int64(Date().timeIntervalSince1970) + 1000 * 60
        var bytes: [UInt8] = [255, 255, 255, 1]
        
        let byteString = chainId + ":" + client_id + ":" + timestamp.description
        
        let array: [UInt8] = Array(byteString.utf8)
        bytes.append(contentsOf: array)
        
        if let preSign = wavesCrypto.signBytes(bytes: bytes, seed: seed) {
            if let bs58 = WavesCrypto.shared.base58encode(input: preSign) {
                let params = digilira.authTokenWaves.init(
                    username: senderPublicKey,
                    password: timestamp.description + ":" + bs58
                )
                wavesApiRequest(auth: params, endpoint:digilira.wavesApiEndpoints.getToken, sender:WavesToken.self){(token, statusCode) in
                    UserDefaults.standard.set(token.accessToken, forKey: "wavesToken")
                }
            }
        }
    }
    
    func createWithdrawRequest(token: WavesToken, address: String, currency: String, amount: Int64) {
        
        self.onError = { [self] error in
            throwEngine.evaluateError(error: error)
        }
        
        self.onSensitive = { wallet, error in
            self.wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getWithdraw, currency: currency, withdrawAddress: address, token: token.accessToken, sender: WithdrawAddresses.self) { [self] (address, statusCode) in
                
                //Make Sure Gateway is active
                if address.currency.status == "active" {
                    let minAmount = MainScreen.decimal2Int64(address.currency.allowedAmount.min, digits: address.currency.decimals)
                    let maxAmount = MainScreen.decimal2Int64(address.currency.allowedAmount.max, digits: address.currency.decimals)
                    
                    guard amount < maxAmount else { return }
                    guard amount > minAmount else { return }
                    
                    //External address gateway
                    let proxyAddress = address.proxyAddresses[0]
                    //Asset will be transfered
                    let assetId = address.currency.wavesAssetID
                    let blockchainFee: Int64 = 1000
                    let me = digilira.dummyName
                    
                    sendTransaction2(name: "", recipient: proxyAddress, fee: digilira.sponsorTokenFee, amount: amount, assetId: assetId, attachment: "", wallet: wallet, blob: SendTrx.init(fiat: 0, attachment: "N/A", destination: digilira.transactionDestination.foreign, me: me, blockchainFee: blockchainFee))
                }
            }
        }
        
        getSensitive(pin: true)
    }
     
    func wavesApiRequest<T>(auth: digilira.authTokenWaves? = nil, endpoint: String, currency: String? = "", withdrawAddress: String? = "", token: String? = "", sender: T.Type, returnCompletion: @escaping (T, Int) -> ()) where T: Decodable  {
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        var apiUrl = digilira.node.apiUrl
        if chainId == "T" {
            apiUrl = digilira.node.apiTestnetUrl
        }
        
        if let url = URL(string: apiUrl + endpoint) {
            var request = URLRequest(url: url)
            
            switch endpoint {
            case digilira.wavesApiEndpoints.getToken:
                if let auth = auth {
                    request.httpMethod = digilira.requestMethod.post
                    
                    var requestBody = URLComponents()
                    
                    let grant_type = URLQueryItem(name: "grant_type", value: digilira.wavesApiEndpoints.grant_type_password)
                    let scope = URLQueryItem(name: "scope", value: digilira.wavesApiEndpoints.scope)
                    let username = URLQueryItem(name: "username", value: auth.username)
                    let password = URLQueryItem(name: "password", value: auth.password)
                    let client_id = URLQueryItem(name: "client_id", value: digilira.wavesApiEndpoints.client_id)
                    
                    requestBody.queryItems = [grant_type, scope, username, password, client_id]
                    
                    if let rb = requestBody.query {
                        request.httpBody = rb.data(using: .utf8)
                        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    }
                }
                break
            case digilira.wavesApiEndpoints.getDeposit:
                request.httpMethod = digilira.requestMethod.get
                if currency != "" {
                    if let currency = currency {
                        request.url!.appendPathComponent(currency, isDirectory: false)
                    }
                }
                if token != "" {
                    let tokenString = "Bearer " + token!
                    request.setValue(tokenString, forHTTPHeaderField: "Authorization")
                }
                
                break
            case digilira.wavesApiEndpoints.getWithdraw:
                request.httpMethod = digilira.requestMethod.get
                if currency != "" {
                    if let currency = currency {
                        request.url!.appendPathComponent(currency, isDirectory: true)
                    }
                }
                
                if withdrawAddress != "" {
                    if let withdrawAddress = withdrawAddress {
                        request.url!.appendPathComponent(withdrawAddress, isDirectory: false)
                    }
                }
                if token != "" {
                    let tokenString = "Bearer " + token!
                    request.setValue(tokenString, forHTTPHeaderField: "Authorization")
                }
                break
            case digilira.wavesApiEndpoints.getCurrencies:
                request.httpMethod = digilira.requestMethod.get
                break
            default:
                break
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if error != nil {
                        
                    }else {
                        guard let dataResponse = data, error == nil else {
                            if let f = self.onWavesApiError {
                                f(error!.localizedDescription, httpResponse.statusCode, endpoint)
                            }
                            
                            return }
                        
                        do{
                            let ticker = try JSONDecoder().decode(T.self, from: dataResponse)
                            returnCompletion(ticker, httpResponse.statusCode)
                        } catch let parsingError {
                            self.onWavesApiError!(parsingError.localizedDescription, httpResponse.statusCode, endpoint)
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    func getTransactionId(rURL: String, t: TransferOnWay) {
        
        let url = rURL
        
        var request = URLRequest(url: URL(string: rURL)!)
        request.httpMethod = digilira.requestMethod.get
        
        let session2 = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task2 = session2.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            
            if error != nil {
                //                print("error: \(error!.localizedDescription): \(error!)")
                self.onError!(error!)
                
            } else if data != nil {
                
                if httpResponse!.statusCode == 404 {
                    sleep(1)
                    print("control")
                    self.getTransactionId(rURL: url, t:t)
                    return
                }else{
                    guard let dataResponse = data,
                          error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse) as! Dictionary<String, AnyObject>
                        self.onVerified!(jsonResponse, t)
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
            }
            
        }
        task2.resume()
        
    }
    
    
    func returnCoin(tokenName: String) throws -> digilira.coin {
        
        switch WavesSDK.shared.enviroment.server {
        case .mainNet:
            
            switch tokenName {
            case digilira.wavesWaves.tokenName:
                return digilira.wavesWaves
            case digilira.tetherWaves.tokenName:
                return digilira.tetherWaves
            case digilira.bitcoinWaves.tokenName:
                return digilira.bitcoinWaves
            case digilira.ethereumWaves.tokenName:
                return digilira.ethereumWaves
            case digilira.litecoinWaves.tokenName:
                return digilira.litecoinWaves
            default:
                throw digilira.NAError.notListedToken
            }
        case .testNet:
            switch tokenName {
            case digilira.waves.tokenName:
                return digilira.waves
            case digilira.bitcoin.tokenName:
                return digilira.bitcoin
            case digilira.ethereum.tokenName:
                return digilira.ethereum
            default:
                throw digilira.NAError.notListedToken
            }
        default:
            throw digilira.NAError.notListedToken
        }
    }
     
    func returnCoins() -> [digilira.coin] {
        
        var result: [digilira.coin] = []
        
        switch WavesSDK.shared.enviroment.server {
        case .mainNet:
            result = [
                digilira.wavesWaves,
                digilira.tetherWaves,
                digilira.bitcoinWaves,
                digilira.ethereumWaves,
                digilira.litecoinWaves,
            ]
            return result
        case .testNet:
            result = [
                digilira.waves,
                digilira.bitcoin,
                digilira.ethereum
            ]
            return result
        default:
            return result
        }
    }
    
    func returnAsset (assetId: String) throws -> digilira.coin {
        
        switch assetId {
        case digilira.bitcoin.token:
            return digilira.bitcoin //digilirapay wrapped
        case digilira.ethereum.token:
            return digilira.ethereum
        case digilira.waves.token:
            return digilira.waves
            
            
        case digilira.tetherWaves.token: //waves wrapped
            return digilira.tetherWaves
        case digilira.bitcoinWaves.token: //waves wrapped
            return digilira.bitcoinWaves
        case digilira.ethereumWaves.token: //waves wrapped
            return digilira.ethereumWaves
        case digilira.litecoinWaves.token: //waves wrapped
            return digilira.litecoinWaves
            
        case digilira.sponsorToken:
            throw digilira.NAError.sponsorToken
        default:
            throw digilira.NAError.notListedToken
        } 
    }
    
    func base58 (data:String) -> String{
        let attachment =  WavesCrypto.shared.base58decode(input: data)
        let string = String(bytes: attachment!, encoding: .utf8)
        return string ?? "empty"
    }
    
    func smartD(initial: Bool) {
        
        do {
            
            let wallet = try getSeed()
            
            guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
            guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed) else { return }
            
            let fee: Int64 = 1400000
            let timestamp = Int64(Date().timeIntervalSince1970) * 1000
            
            var queryModel = NodeService.Query.Transaction.SetScript.init(chainId: chainId,
                                                                          fee: fee,
                                                                          timestamp: timestamp,
                                                                          senderPublicKey: senderPublicKey,
                                                                          script: digilira.smartAccount.script)
            
            queryModel.sign(seed: wallet.seed)
            let send = NodeService.Query.Transaction.setScript(queryModel)
            
            if initial {
                WavesSDK.shared.services
                    .nodeServices
                    .transactionNodeService
                    .transactions(query: send)
                    .subscribe(onNext: {(tx) in
                        print(tx) // Do something on success, now we have wavesBalance.balance in satoshi in Long
                    }, onError: {(error) in
                        self.onError!(error)
                    })
            } else {
                digiliraPay.updateSmartAcountScript(data: send)
            }
        } catch {
            print (error)
        }
    }
    
    func checkBalance(account: NodeService.DTO.AddressScriptInfo) {
        WavesSDK.shared.services
            .nodeServices
            .addressesNodeService
            .addressBalance(address: account.address)
            .subscribe(onNext: { (balances) in
                if balances.balance < 1400000 {
                    sleep(1)
                    self.checkBalance(account: account)
                }else {
                    if account.script != digilira.smartAccount.script {
                        //script is updated
                        if account.script == nil {
                            //initial script
                            self.smartD(initial: true)
                        } else {
                            self.smartD(initial: false)
                        }
                    }
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    
    func checkTransactions (address: String, returnCompletion: @escaping ([NodeService.DTO.Transaction]) -> () ) {
        WavesSDK.shared.services.nodeServices.transactionNodeService
            .transactions(by: address, offset: 0, limit: 100)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe({(history) in
                if let h = history.element {
                    returnCompletion(h.transactions)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func checkSmart(address: String) {
        WavesSDK.shared.services
            .nodeServices
            .addressesNodeService
            .scriptInfo(address: address)
            .asObservable()
            .subscribe(onNext:{(smart) in
                if smart.script != digilira.smartAccount.script {
                    // not so smart
                    self.checkBalance(account: smart)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getSensitive(pin:Bool) {
        if pin {
            do {
                let seed = try getSeed()
                self.onSensitive!(seed, "ok")
                return
            } catch {
                print(error)
            }
        }
         
        digiliraPay.onTouchID = { res, err in
            if res == true {
                
                do {
                    let seed = try self.getSeed()
                    self.onSensitive!(seed, "ok")
                    return
                } catch {
                    print(error)
                }
                 
            } else {
                self.onSensitive!(digilira.wallet.init(seed: ""), err)
            }
        }
        
        digiliraPay.touchID(reason: "Transferin gerçekleşebilmesi için biometrik onayınız gerekmektedir!")
    }
    
    private func getSeed() throws -> digilira.wallet {
        
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let seed = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: digilira.login.self)
            let r = digilira.wallet.init(seed: seed.seed)
            return r
        } catch {
            throw digilira.NAError.seed404
        }
    }
    
    func checkIfUser() -> Bool {
        do {
            let seed = try getSeed()
            if seed.seed == "" {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    func isOurMember(external: digilira.externalTransaction) {
        
        let normalizedAddress = external.address?.components(separatedBy: "?")
        let croppedAddress = normalizedAddress?.first
        
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let v:[String] = [external.address!, "externalTransaction", external.network!]
        
        if let sign = try? bytization(v, timestamp) {
            let user = digilira.externalTransaction.init(
                network: external.network,
                address: external.address,
                wallet: sign.wallet,
                signed: sign.signature,
                publicKey: sign.publicKey,
                timestamp: timestamp
            )
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(user)
            
            crud.onResponse = { [self] res, sts in
                if (sts == 200) {
                    
                    do {
                        let ourMember = try digiliraPay.decodeDefaults(forKey: res, conformance: TransferDestination.self)
                        
                        let response = digilira.externalTransaction.init(network: external.network,
                                                                         address: external.address,
                                                                         amount: external.amount,
                                                                         owner: ourMember.owner,
                                                                         wallet: ourMember.wallet,
                                                                         assetId: external.assetId,
                                                                         destination: ourMember.destination
                        )
                        
                        self.onMember!(true, response)
                        
                        
                    } catch  {
                        print(error)
                    }
                    
                    
                }else {
                    
                    //-TODO check withdraw address
                    
                    let response = digilira.externalTransaction.init(network: external.network,
                                                                     address: croppedAddress,
                                                                     amount: 0,
                                                                     owner: croppedAddress,
                                                                     wallet: digilira.gatewayAddress,
                                                                     assetId: external.assetId,
                                                                     destination: digilira.transactionDestination.foreign
                    )
                    self.onMember!(false, response)
                }
            }
            
            crud.request(rURL: digiliraPay.getApiURL() + digilira.api.isOurMember, postData: data, method: digilira.requestMethod.post)
        }
    }
    
    
    
    func bytization(_ array: [String]?, _ timestamp: Int64, _ seed: String = "N/A") throws -> signData {
        var s = seed
        if (s == "N/A") {
            do {
                s = try getSeed().seed
            } catch {
                throw digilira.NAError.emptyPassword
            }
        }
        
        if let a = array {
            guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: s) else {
                throw digilira.NAError.emptyPassword
            }
            
            guard let wallet = WavesCrypto.shared.address(seed: s, chainId: WavesSDK.shared.enviroment.chainId) else { throw digilira.NAError.emptyPassword }
            
            var bytes: [UInt8] = [255, 255, 255, 1]
            var byteString = ""
            for item in a {
                if item != "" {
                    byteString = byteString + item + ":"
                } 
            }
            
            byteString = byteString + timestamp.description + ":" + senderPublicKey + ":" + wallet
            let array: [UInt8] = Array(byteString.utf8)
            
            bytes.append(contentsOf: array)
            
            if let sign = wavesCrypto.signBytes(bytes: bytes, seed: s) {
                
                if let signed = wavesCrypto.base58encode(input: sign) {
                    let signD = signData.init(signature: signed, publicKey: senderPublicKey, wallet: wallet)
                    
                    return signD
                }
            }
            
        }
        
        throw digilira.NAError.emptyPassword
        
    }
    
    func getKeyChainSource() throws -> digilira.keychainData {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw digilira.NAError.emptyAuth }
        
        switch chainId {
        case "T":
            return digilira.keychainData.init(authenticateData: "authenticate", sensitiveData: "sensitive")
        case "W":
            return digilira.keychainData.init(authenticateData: "authenticateMainnet", sensitiveData: "sensitiveMainnet")
        default:
            throw digilira.NAError.emptyAuth
        }
    }
    
    func createUser(seed: String) {
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        
        do {
            let source = try getKeyChainSource()
            
            guard let btc = UserDefaults.standard.value(forKey: "btcAddress") as? String  else { return }
            guard let eth = UserDefaults.standard.value(forKey: "ethAddress") as? String else { return }
            guard let ltc = UserDefaults.standard.value(forKey: "ltcAddress") as? String else { return }
            if chainId != "T" {
                guard UserDefaults.standard.value(forKey: "usdtAddress") != nil  else { return }
            }
            guard let imported = UserDefaults.standard.value(forKey: "imported") as? Bool  else { return }
            guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: seed) else { return }
            guard let wallet = WavesCrypto.shared.address(seed: seed, chainId: chainId) else { return }
            
            let timestamp = Int64(Date().timeIntervalSince1970) + 1000 * 60
            
            let v = [btc, eth, imported.description, ltc]
            guard let signed = try? bytization( v, timestamp, seed) else {return}
            
            var user = digilira.exUser.init(btcAddress: btc,
                                            ethAddress: eth,
                                            ltcAddress: ltc,
                                            wallet: wallet,
                                            imported: imported,
                                            signed: signed.signature,
                                            publicKey: senderPublicKey,
                                            timestamp: timestamp
            )
            
            if chainId != "T" {
                guard let usd = UserDefaults.standard.value(forKey: "usdtAddress") as? String else { return }
                user.tetherAddress = usd
                let v = [btc, eth, imported.description, ltc, usd]
                guard let signed = try? bytization( v, timestamp, seed) else {return}
                user.signed = signed.signature
            }
            
            if imported {
                do {
                    let u = try secretKeys.userData()
                    user.dogum = u.dogum
                    user.firstName = u.firstName
                    user.lastName = u.lastName
                    user.pincode = u.pincode
                    user.tel = u.tel
                    user.mail = u.mail
                    user.tcno = u.tcno
                    user.status = u.status
                    user.apnToken = u.apnToken
                    user.btcAddress = u.btcAddress
                    user.ltcAddress = u.ltcAddress
                    user.ethAddress = u.ethAddress
                    user.tetherAddress = u.tetherAddress
                    
                    let v = [btc, eth, imported.description, ltc, user.tetherAddress!]
                    guard let signed = try? bytization(v, timestamp, seed) else {return}
                    user.signed = signed.signature
                } catch {
                    print(error)
                }
            }
            
            do {
                let postdata = try digiliraPay.jsonEncoder.encode(user)
                
                digiliraPay.request(rURL: digiliraPay.getApiURL() + digilira.api.userRegister,
                                    JSON:  postdata,
                                    METHOD: digilira.requestMethod.post
                ) { (json, statusCode) in
                    DispatchQueue.main.async  { [self] in
                        
                        if statusCode == 200 {
                            do {
                                let j = try JSONSerialization.data(withJSONObject: json, options: [])
                                
                                if secretKeys.LocksmithSave(forKey: source.authenticateData, data: j) {
                                    if imported {
                                        
                                        try Locksmith.deleteDataForUserAccount(userAccount: source.sensitiveData)
                                        try Locksmith.saveData(
                                            data: [
                                                "seed": seed
                                            ],
                                            forUserAccount: source.sensitiveData)
                                        
                                        self.onComplete!(true, statusCode!)
                                        
                                    }else {
                                        
                                        try Locksmith.saveData(
                                            data: [
                                                "seed": seed
                                            ],
                                            forUserAccount: source.sensitiveData)
                                        self.onComplete!(true, statusCode!)
                                    }
                                }
                                
                            }catch {
                                if (error as! LocksmithError == LocksmithError.duplicate ) {
                                    try? Locksmith.deleteDataForUserAccount(userAccount: source.sensitiveData)
                                }
                                try? Locksmith.saveData(
                                    data: [
                                        "seed": seed
                                    ],
                                    forUserAccount: source.sensitiveData)
                                self.onComplete!(true, statusCode!)
                            }
                        } else {
                            if let s = statusCode {
                                switch s {
                                case 502:
                                    self.onComplete!(false, 502)
                                default:
                                    self.onComplete!(false, 502)
                                }
                            }
                        }
                    }
                }
            } catch  {
                print(error)
            }
        } catch {
            print (error)
        }
    }
    
    func createMainnet(imported: Bool = false, importedSeed: String = "") {
        
        var seed = importedSeed
        if !imported {
            seed = wavesCrypto.randomSeed()
            print(seed)
        }
        
        UserDefaults.standard.removeObject(forKey: "imported")
        UserDefaults.standard.removeObject(forKey: "btcAddress")
        UserDefaults.standard.removeObject(forKey: "ethAddress")
        UserDefaults.standard.removeObject(forKey: "ltcAddress")
        UserDefaults.standard.removeObject(forKey: "usdtAddress")
        
        self.onWavesApiError = { res, sts, path in
            print(res,sts, path)
        }
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: seed) else { return }
        
        let client_id = digilira.wavesApiEndpoints.client_id;
        
        let timestamp = Int64(Date().timeIntervalSince1970) + 1000 * 60
        var bytes: [UInt8] = [255, 255, 255, 1]
        
        let byteString = chainId + ":" + client_id + ":" + timestamp.description
        
        let array: [UInt8] = Array(byteString.utf8)
        bytes.append(contentsOf: array)
        
        UserDefaults.standard.set(imported, forKey: "imported")
        
        if let preSign = wavesCrypto.signBytes(bytes: bytes, seed: seed) {
            if let bs58 = WavesCrypto.shared.base58encode(input: preSign) {
                let params = digilira.authTokenWaves.init(
                    username: senderPublicKey,
                    password: timestamp.description + ":" + bs58
                )
                wavesApiRequest(auth: params, endpoint:digilira.wavesApiEndpoints.getToken, sender:WavesToken.self){ [self] (token, statusCode) in
                    
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.BTC, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[1], forKey: "btcAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.ETH, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[0], forKey: "ethAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.LTC, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                        UserDefaults.standard.set(address.depositAddresses[0], forKey: "ltcAddress")
                        createUser(seed: seed)
                        print(address.depositAddresses)
                    }
                    if chainId != "T" {
                        wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getDeposit, currency: digilira.wavesApiEndpoints.USDT, token: token.accessToken, sender: DepositeAddresses.self) { (address, statusCode) in
                            UserDefaults.standard.set(address.depositAddresses[0], forKey: "usdtAddress")
                            createUser(seed: seed)
                            print(address.depositAddresses)
                        }
                    }
                }
            }
        }
    }
}
 
extension Blockchain: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        if self.isCertificatePinning {
            
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            // SSL Policies for domain name check
            let policy = NSMutableArray()
            policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
            
            //evaluate server certifiacte
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            
            //Local and Remote certificate Data
            let remoteCertificateData:NSData =  SecCertificateCopyData(certificate!)
            //let LocalCertificate = Bundle.main.path(forResource: "github.com", ofType: "cer")
            let pathToCertificate = Bundle.main.path(forResource: digilira.sslPinning.wavesCert, ofType: digilira.sslPinning.fileType)
            let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
            
            //Compare certificates
            if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
                let credential:URLCredential =  URLCredential(trust:serverTrust)
                
                completionHandler(.useCredential,credential)
            }
            else{
                completionHandler(.cancelAuthenticationChallenge,nil)
            }
        }
    } 
}

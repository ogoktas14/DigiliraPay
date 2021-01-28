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
    
    struct DataTransationModelElement: Codable {
        let type: String
        let value: Value
        let key: String
    }
    
    enum Value: Codable {
        case integer(Int)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .integer(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .integer(let x):
                try container.encode(x)
            case .string(let x):
                try container.encode(x)
            }
        }
    }
    
    typealias DataTransationModel = [DataTransationModelElement]
    
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
    
    private let wavesCrypto: WavesCrypto = WavesCrypto()
    
    var lang = Localize()
    var listedTokens = ListedTokens()
    let digiliraPay = digiliraPayApi()
    let throwEngine = ErrorHandling()
    var crud = centralRequest()
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    var onWavesBalance: ((_ result: NodeService.DTO.AddressBalance)->())?
    var onAssetBalance: ((_ assets: NodeService.DTO.AddressAssetsBalance, _ waves: NodeService.DTO.AddressBalance)->())?
    var onTransferTransaction: ((_ result: NodeService.DTO.Transaction, _ verifyData: TransferOnWay )->())?
    var onVerified: ((_ result: TransferTransactionModel, _ verifyData: TransferOnWay)->())?
    var onSensitive: ((_ result: digilira.wallet, _ err: String)->())?
    var onError: ((_ result: Error)->())?
    var onPinSuccess: ((_ result: Bool)->())?
    var onSmartAvailable: ((_ result: Bool)->())?
    var onMember: ((_ result: Bool, _ data: digilira.externalTransaction?)->())?
    
    var onComplete: ((_ result: Bool, _ statusCode: Int)->())?
    
    var onWavesApiError: ((_ result: String, _ statusCode: Int, _ path: String)->())?
    var onWavesTokenResponse: ((_ result: Data, _ statusCode: Int) ->())?
    var onWavesNodeResponse: ((_ result: Data, _ statusCode: Int) ->())?
    var onWavesDataResponse: ((_ result: Data, _ statusCode: Int) ->())?

    
    func checkWavesBalance(address: String) {
        WavesSDK.shared.services
            .nodeServices
            .addressesNodeService
            .addressBalance(address: address)
            .subscribe(onNext: { (balances) in
                self.onWavesBalance!(balances)
            })
            .disposed(by: self.disposeBag)
    }
    
    func checkAssetBalance(address: String ) {
        onWavesBalance = { [self] wavesBalance in
            WavesSDK.shared.services.nodeServices.assetsNodeService
                .assetsBalances(address: address)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (balances) in
                    self.onAssetBalance?(balances, wavesBalance)
                }, onError: {_ in
                    self.onError!(digilira.NAError.noBalance)
                })
                .disposed(by: disposeBag)
        }
        checkWavesBalance(address: address)
    }
    
    func getFeeAssetId(destination: String) -> String {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return "" }

        switch chainId {
        case "T":
            switch destination {
            case digilira.transactionDestination.domestic:
                return digilira.paymentToken
            case digilira.transactionDestination.interwallets:
                return digilira.sponsorToken
            case digilira.transactionDestination.foreign:
                return digilira.sponsorToken
            default:
                return ""
            }
        default:
            switch destination {
            case digilira.transactionDestination.domestic:
                return digilira.mainnetPaymentToken
            case digilira.transactionDestination.interwallets:
                return digilira.mainnetSponsorToken
            case digilira.transactionDestination.foreign:
                return digilira.mainnetSponsorToken
            default:
                return ""
            }
        }
        

    }
    
    func sendBitexen() {
        
    }
    
    func sendTransaction2(name: String, recipient: String, amount:Int64, assetId:String, attachment:String, wallet:digilira.wallet, blob: SendTrx) {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard let address = WavesCrypto.shared.address(seed: wallet.seed, chainId: chainId) else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed) else { return }
        guard wallet.seed != "" else { return }
         
        self.onWavesApiError = { res, sts, path in
            self.onError!(digilira.NAError.anErrorOccured)
        }
        self.onWavesNodeResponse = { [self] result, status in
            do {
                
                if let feeAssetResponse = try decodeDefaults(forKey: result, conformance: FeeCalculateResponse.self)
                {
                    
                    var attachmentValidation = attachment
                    if attachmentValidation == "" {
                        attachmentValidation = "DIGILIRAPAY TRANSFER"
                    }
                    
                    var feeAsset = ""
                    
                    if let f =  feeAssetResponse.feeAssetID {
                        feeAsset = f
                    }
                    
                    let buf: [UInt8] = Array(attachmentValidation.utf8)
                    let attachment58 = WavesCrypto.shared.base58encode(input: buf)
                    let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                    
                    var queryModel = NodeService.Query.Transaction.Transfer(recipient: recipient,
                                                                            assetId: assetId,
                                                                            amount: amount,
                                                                            fee: feeAssetResponse.feeAmount,
                                                                            attachment: attachment58!,
                                                                            feeAssetId: feeAsset,
                                                                            timestamp: timestamp,
                                                                            senderPublicKey: senderPublicKey, chainId: chainId)
                    
                    
                    queryModel.sign(seed: wallet.seed)
                    
                    let send = NodeService.Query.Transaction.transfer(queryModel)
                    
                    WavesSDK.shared.services
                        .nodeServices
                        .transactionNodeService
                        .transactions(query: send)
                        .observeOn(MainScheduler.asyncInstance)
                        .subscribe(onNext: { [self] (tx) in
                            if let data = tx.data {
                                do {
                                    if let type = try decodeDefaults(forKey: data, conformance: TransactionType.self) {
                                        switch type.type {
                                        case 4:
                                            if let transaction = try decodeDefaults(forKey: data, conformance: TransferTransactionModel.self) {
                                                var external = "N/A"
                                                var merchantId = "N/A"
                                                
                                                switch blob.destination {
                                                case digilira.transactionDestination.foreign:
                                                    if let e = blob.externalAddress {
                                                        external = e
                                                    }
                                                    break
                                                case digilira.transactionDestination.domestic:
                                                    if let m = blob.merchantId {
                                                        merchantId = m
                                                    }
                                                    break
                                                default:
                                                    break
                                                }
                                                if blob.destination != digilira.transactionDestination.foreign {
                                                    if let e = blob.externalAddress {
                                                        external = e
                                                    }
                                                }
                                                
                                                if feeAsset == "" {
                                                    feeAsset = "WAVES"
                                                }
                                                
                                                let v:[String] = [amount.description, assetId.description, attachmentValidation, blob.blockchainFee.description, blob.destination, external, feeAssetResponse.feeAmount.description, feeAsset, merchantId, blob.me, recipient, name, MainScreen.df2so(blob.fiat), 0.description, transaction.id]
                                                let sign = try bytization(v, timestamp)
                                                
                                                let t = TransferOnWay.init(recipientName: name,
                                                                           recipient: recipient,
                                                                           myName: blob.me,
                                                                           wallet: address,
                                                                           amount: amount,
                                                                           assetId: assetId,
                                                                           tickerTl: MainScreen.df2so(blob.fiat),
                                                                           tickerUsd: 0,
                                                                           fee: feeAssetResponse.feeAmount,
                                                                           feeAssetId: feeAsset,
                                                                           blockchainFee: blob.blockchainFee,
                                                                           transactionID: transaction.id,
                                                                           destination: blob.destination,
                                                                           externalAddress: external,
                                                                           attachment: attachmentValidation,
                                                                           merchantId: merchantId,
                                                                           publicKey: sign.publicKey,
                                                                           signed: sign.signature,
                                                                           timestamp: timestamp)
                                                
                                                self.onTransferTransaction?(tx, t)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                    }
                                } catch{
                                    print(error)
                                }
                            }
                        }, onError: { (error ) -> Void in
                            if let s = error as? NetworkError{
                                self.onError!(s)
                            }
                        })
                        .disposed(by: disposeBag)
                    
                }
                
            } catch {
                print(error)
            }
            
        }
        
        let feeParams = FeeCalculate.init(type: 4,
                                          senderPublicKey: senderPublicKey,
                                          feeAssetID: getFeeAssetId(destination: blob.destination),
                                          assetID: assetId,
                                          recipient: recipient,
                                          amount: amount)
        
        wavesNodeRequests(path: "/transactions/calculateFee", method: digilira.requestMethod.post, postData: try? JSONEncoder().encode(feeParams))
        
    }
    
    func verifyTrx(txid: String, t: TransferOnWay) {
        getTransactionId(rURL: WavesSDK.shared.enviroment.nodeUrl.description + "/transactions/status?id=" + txid, t:t)
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
    
    func getWavesToken(seed: String) {
//        do {
//            let source = try getKeyChainSource().wavesToken
//            if let data = Locksmith.loadDataForUserAccount(userAccount: source) {
//                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//                do {
//                    let token = try JSONDecoder().decode(WavesToken.self, from: jsonData)
//                    if token.expiresIn > 1000 {
//                        return
//                    }
//                } catch {
//                    print("ERROR:", error)
//                }
//            }
//        } catch {
//            print("N/A")
//        }

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
                wavesApiRequest(auth: params, endpoint:digilira.wavesApiEndpoints.getToken, sender:WavesToken.self){ [self](token, statusCode) in
                    if let data = token.data {
                        do {
                            let source = try getKeyChainSource().wavesToken
                            if secretKeys.LocksmithSave(forKey: source, data: data) {
                                print(true)
                            } else {
                                print(false)
                            }
                        }catch{
                            throwEngine.evaluateError(error: error)
                        }
                    }
                }
            }
        }
    }
    
    func createWithdrawRequest(wallet: digilira.wallet, address: String, currency: String, amount: Int64, blob: SendTrx) {
        
        self.onError = { [self] error in
            throwEngine.evaluateError(error: error)
        }
        guard let symbol = try? returnAsset(assetId: currency) else { return }
         
        self.onWavesApiError = { res, sts, path in
            print(res,sts, path)
        }
        
        self.wavesApiRequest(auth: nil, endpoint:digilira.wavesApiEndpoints.getWithdraw, currency: symbol.symbol, withdrawAddress: address, token: wallet.wavesToken, sender: WithdrawAddresses.self) { [self] (result, statusCode) in
                
                if result.currency.status == "active" {
                    let minAmount = MainScreen.decimal2Int64(result.currency.allowedAmount.min, digits: result.currency.decimals)
                    let maxAmount = MainScreen.decimal2Int64(result.currency.allowedAmount.max, digits: result.currency.decimals)
                    
                    guard amount < maxAmount else { return }
                    guard amount > minAmount else { return }
                    
                    let proxyAddress = result.proxyAddresses[0]
                    
                    var assetId = result.currency.wavesAssetID
                    
                    guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
                    if chainId == "T" {
                        assetId = currency
                    }
                    
                    let me = digilira.dummyName
                    
                    sendTransaction2(name: me, recipient: proxyAddress, amount: amount, assetId: assetId, attachment: "", wallet: wallet, blob: blob)
                    
                }
            }
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
                    request.httpMethod = req.method.post
                    
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
                request.httpMethod = req.method.get
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
                request.httpMethod = req.method.get
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
                request.httpMethod = req.method.get
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
                            //var jsonResponse = try? (JSONSerialization.jsonObject(with: dataResponse) as! Dictionary<String, AnyObject>)

                            let ifError = try? JSONDecoder().decode(WavesTokenError.self, from: dataResponse)
                            let ifApiError = try? JSONDecoder().decode(WavesAPIError.self, from: dataResponse)

                            if let isError = ifError {
                                self.onWavesApiError!(isError.errors.first!.message, httpResponse.statusCode, endpoint)
                                return
                            }
                             
                            if let isError = ifApiError {
                                self.onWavesApiError!(isError.errors.first!.message, httpResponse.statusCode, endpoint)
                                return
                            }
                             
                            let ticker = try JSONDecoder().decode(T.self, from: dataResponse)
                            returnCompletion(ticker, httpResponse.statusCode)
                        } catch let parsingError {
                            print(parsingError)
                            self.onWavesApiError!(parsingError.localizedDescription, httpResponse.statusCode, endpoint)
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type ) throws -> T? where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch {
            throw digilira.NAError.parsingError
        }
    }
    
    func wavesNodeRequests(path: String, method:String = digilira.requestMethod.get, postData: Data? = nil) {
        let url = WavesSDK.shared.enviroment.nodeUrl.description
        
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.httpMethod = method
            if let json = postData {
                request.httpBody = json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            if path != "" {
                request.url?.appendPathComponent(path, isDirectory: false)
            }
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            isCertificatePinning = true
            let task = session.dataTask(with: request) { (data, response, error) in
          
                if let httpResponse = response as? HTTPURLResponse {
                    if error != nil {
                        self.onWavesApiError!(error!.localizedDescription, httpResponse.statusCode, path)
                    } else if data != nil {
                        guard let dataResponse = data,
                              error == nil else {
                           
                            return }
                        self.onWavesNodeResponse!(dataResponse, httpResponse.statusCode)
                    }
                }
            }
            task.resume()
        }
 
    }
    
    func getTransactionId(rURL: String, t: TransferOnWay) {
        
        let url = rURL
        
        var request = URLRequest(url: URL(string: rURL)!)
        request.httpMethod = req.method.get
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task = session.dataTask(with: request) { [self] (data, response, error) in
            if error != nil {
                self.onError!(error!)
                
            } else if data != nil {
                guard let dataResponse = data,
                      error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
                do{
                    let confirmationModel = try JSONDecoder().decode(ConfirmationModel.self, from: dataResponse)
                    if let c = confirmationModel.first {
                        switch c.status {
                        case "confirmed":
                            onWavesNodeResponse = { result, statusCode in
                                do {
                                    let trxModel = try JSONDecoder().decode(TransferTransactionModel.self, from: result)
                                    self.onVerified!(trxModel, t)
                                } catch  {
                                    print(error)
                                }
                            }
                            wavesNodeRequests(path: "/transactions/info/" + c.id!)
                            break
                        case "unconfirmed":
                            sleep(1)
                            print("control")
                            self.getTransactionId(rURL: url, t:t)
                            break
                        default:
                            break
                        }
                    }
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
            
        }
        task.resume()
        
    }
    
    func returnEnv() -> String  {
        switch WavesSDK.shared.enviroment.server {
        case .mainNet:
            return "mainnet"
        case .testNet:
            return "testnet"
        default:
            return "-"
        }
    }
    
    func returnNetworks() throws -> [WavesListedToken] {
        do {
            let tokens = try listedTokens.returnCoins()
            return tokens
        } catch {
            throw digilira.NAError.notListedToken
        }
    }
    
    func returnCoins() throws -> [WavesListedToken] {
        do {
            let tokens = try listedTokens.returnCoins()
            return tokens
        } catch {
            throw digilira.NAError.notListedToken
        }
    }
    
    func returnAsset (assetId: String?) throws -> WavesListedToken {
        do {
            return try listedTokens.returnAsset(assetId:assetId)
        } catch {
            throw digilira.NAError.notListedToken
        }
    }
    
    func base58 (data:String) -> String {
        let attachment =  WavesCrypto.shared.base58decode(input: data)
        if let a = attachment {
            if let string = String(bytes: a, encoding: .utf8) {
                return string
            }
        }
        return "Diğer"
    }
    
    func base64 (data:String) -> String {
        let attachment =  WavesCrypto.shared.base64decode(input: data)
        if let a = attachment {
            if let string = String(bytes: a, encoding: .utf8) {
                return string
            }
        }
        return "Diğer"
    }
    
    func returnScript() -> String {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return "" }
        switch chainId {
        case "T":
            return digilira.smartAccount.script
        default:
            return digilira.smartAccountMainnet.script
        }
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
                                                                          script: returnScript())
            
            
            let v:[String] = [chainId, fee.description, returnScript()]
            let sign = try bytization(v, timestamp)
            
            struct scriptSend: Codable {
                let chainId: String
                let fee: String
                let timestamp: Int64
                let publicKey: String
                let signed: String
                let wallet: String
                let setScript: NodeService.Query.Transaction.SetScript
                let script: String
            }

             
            queryModel.sign(seed: wallet.seed)
            let send = NodeService.Query.Transaction.setScript(queryModel)
            
            let t = scriptSend.init(chainId: chainId,
                                    fee: fee.description,
                                    timestamp: timestamp,
                                    publicKey: sign.publicKey,
                                    signed: sign.signature,
                                    wallet: sign.wallet,
                                    setScript: queryModel,
                                    script: returnScript())
            
            if initial {
                WavesSDK.shared.services
                    .nodeServices
                    .transactionNodeService
                    .transactions(query: send)
                    .subscribe(onNext: {(tx) in
                        print(tx)
                    }, onError: {(error) in
                        //self.onError!(error)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                digiliraPay.updateSmartAcountScript(data: t.data!, signature: sign.signature)
            }
        } catch {
            print (error)
        }
    }
    
    func getWalletAddress(address: String) {
        onWavesApiError = { error, status, path in
            
        }
        
        DispatchQueue.global(qos: .background).async  {
            self.onWavesNodeResponse = { result, status in
                let defaults = UserDefaults.standard
                defaults.set(result, forKey: "walletStatus")
            }
            
            self.wavesNodeRequests(path: "/addresses/data/" + self.returnDataAddress() + "/" + address)
            }


    }
    
    func returnDataAddress() -> String {
        
        let gatewayPublicAddress = "57EFni8M1XesEurFh3c4jnpLExP2PCPd5TRrwMjePAT4"
        let mainnetDataPublic = "4snGCeL4Wjopx9awWd7pfdqUYyN1CLqbPz66bn7VY8oe"
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return "" }
        switch chainId {
        case "T":
            return WavesCrypto.shared.address(publicKey: gatewayPublicAddress, chainId: "T")!
        default:
            return WavesCrypto.shared.address(publicKey: mainnetDataPublic, chainId: "W")!
        }
    }
    
    func returnGatewayAddress() -> String {
        
        let gatewayPublicAddress = "57EFni8M1XesEurFh3c4jnpLExP2PCPd5TRrwMjePAT4"
        let mainnetGatewayPublic = "ActWMpdeyp8YHRhLxXmwdJmr37VXGgb44m8DuSVJW3k1"
        
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return "" }
        switch chainId {
        case "T":
            return WavesCrypto.shared.address(publicKey: gatewayPublicAddress, chainId: "T")!
        default:
            return WavesCrypto.shared.address(publicKey: mainnetGatewayPublic, chainId: "W")!
        }
        
    }
    
    func getDataTrx(key:String) {
        
        onWavesApiError = { error, status, path in
            self.onWavesDataResponse!(error.data!,status)
        }
        
        self.onWavesNodeResponse = { result, status in
            self.onWavesDataResponse!(result,status)
        }
        
        wavesNodeRequests(path: "/addresses/data/" + returnDataAddress() + "/" + key)
    }
    
    func checkListedTokens() {
        onWavesApiError = { error, status, path in
            
        }
        self.onWavesNodeResponse = { result, status in
            let defaults = UserDefaults.standard
            defaults.set(result, forKey: "listedTokens")
        }
        wavesNodeRequests(path: "/addresses/data/" + returnDataAddress() + "/ListedTokens")

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
                    if account.script != self.returnScript() {
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
        checkListedTokens()
        WavesSDK.shared.services
            .nodeServices
            .addressesNodeService
            .scriptInfo(address: address)
            .asObservable()
            .subscribe(onNext:{(smart) in
                if smart.script != self.returnScript() {
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
                self.onSensitive!(digilira.wallet.init(seed: "", wavesToken: ""), err)
            }
        }
        digiliraPay.touchID(reason: lang.const(x: "touch_id_reason"))
    }
    
    private func getSeed() throws -> digilira.wallet {
        do {
            let source = try getKeyChainSource()
            let seed = try secretKeys.LocksmithLoad(forKey: source.sensitiveData, conformance: digilira.login.self)
            
            do {
                let wavesToken = try secretKeys.LocksmithLoad(forKey: source.wavesToken, conformance: WavesToken.self)
                let r = digilira.wallet.init(seed: seed.seed, wavesToken: wavesToken.accessToken)
                return r
            } catch {
                getWavesToken(seed: seed.seed)
            }
            let r = digilira.wallet.init(seed: seed.seed, wavesToken: "")
            return r
        } catch {
            switch error {
            case digilira.NAError.emptyAuth:
                throw digilira.NAError.seed404
            case digilira.NAError.seed404:
                throw digilira.NAError.seed404
            default:
                throw digilira.NAError.anErrorOccured
            }
        }
    }
    
    func checkIfUser() -> Bool {
        do {
            let seed = try getSeed()
            getWavesToken(seed:seed.seed)
            if seed.seed == "" {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    func isOurMember(external: digilira.externalTransaction) {
        
        guard let address = external.address else { return }
        
        let normalizedAddress = address.components(separatedBy: "?")
        let croppedAddress = normalizedAddress.first
        
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let v:[String] = [address, "DIGILIRAPAY TRANSFER", external.network!]
        
        if let sign = try? bytization(v, timestamp) {
            let user = digilira.externalTransaction.init(
                network: external.network,
                address: address,
                wallet: sign.wallet,
                signed: sign.signature,
                publicKey: sign.publicKey,
                timestamp: timestamp
            )
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(user)
            
            crud.onError = { error, sts in
                
            }
            
            crud.onResponse = { [self] res, sts in
                print(sts)
                if (sts == 200) {
                    
                    do {
                        let ourMember = try crud.decodeDefaults(forKey: res, conformance: TransferDestination.self)
                        
                        let response = digilira.externalTransaction.init(network: external.network,
                                                                         address: external.address,
                                                                         amount: external.amount,
                                                                         owner: ourMember.owner,
                                                                         wallet: ourMember.wallet,
                                                                         assetId: external.assetId,
                                                                         destination: ourMember.destination,
                                                                         isTether: ourMember.isTether ?? false
                        )
                        
                        self.onMember!(true, response)
                        
                        
                    } catch  {
                        print(error)
                    }
                    
                    
                }else {
                    
                    //-TODO check withdraw address
                    
                    switch sts {
                    case 404:
                        let response = digilira.externalTransaction.init(network: external.network,
                                                                         address: croppedAddress,
                                                                         amount: 0,
                                                                         owner: croppedAddress,
                                                                         wallet: returnGatewayAddress(),
                                                                         assetId: external.assetId,
                                                                         destination: digilira.transactionDestination.foreign
                        )
                        self.onMember!(false, response)
                        break
                    case 502:
                        //server is down
                        self.onWavesNodeResponse = { result, statusCode in
                            switch statusCode {
                            case 200:
                                if let dataTransationModel = try? JSONDecoder().decode(DataTransationModelElement.self, from: result) {
                                    if dataTransationModel.type == "integer" {
                                        do {
                                            let value = try JSONDecoder().decode(Int.self, from: dataTransationModel.value.data!)
                                            if value == 2 {
                                                let response = digilira.externalTransaction.init(network: external.network,
                                                                                                 address: croppedAddress,
                                                                                                 amount: 0,
                                                                                                 owner: croppedAddress,
                                                                                                 wallet: croppedAddress,
                                                                                                 assetId: external.assetId,
                                                                                                 destination: digilira.transactionDestination.interwallets
                                                )
                                                self.onMember!(true, response)
                                            }
                                        } catch  {
                                            break
                                        }
                                        
                                        
                                        
                                    } else if dataTransationModel.type == "string" {
                                        do {
                                            let wallet = try JSONDecoder().decode(String.self, from: dataTransationModel.value.data!)
                                            let response = digilira.externalTransaction.init(network: external.network,
                                                                                             address: croppedAddress,
                                                                                             amount: 0,
                                                                                             owner: croppedAddress,
                                                                                             wallet: wallet,
                                                                                             assetId: external.assetId,
                                                                                             destination: digilira.transactionDestination.interwallets
                                            )
                                            self.onMember!(true, response)
                                        } catch  {
                                            
                                        }
                                    }
                                }
                            case 404:
                                let response = digilira.externalTransaction.init(network: external.network,
                                                                                 address: croppedAddress,
                                                                                 amount: 0,
                                                                                 owner: croppedAddress,
                                                                                 wallet: returnGatewayAddress(),
                                                                                 assetId: external.assetId,
                                                                                 destination: digilira.transactionDestination.foreign
                                )
                                self.onMember!(false, response)
                                break
                            default:
                                break
                            }
                            
                        }
                        let StringUrl = "/addresses/data/" + returnDataAddress() + "/" + croppedAddress!
                        wavesNodeRequests(path: StringUrl)
                        break
                    default:
                        break
                    }
                }
            }
            crud.request(rURL: crud.getApiURL() + digilira.api.isOurMember, postData: data, signature: sign.signature)
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
            return digilira.keychainData.init(authenticateData: "authenticate", sensitiveData: "sensitive", wavesToken: "wavesToken")
        case "W":
            return digilira.keychainData.init(authenticateData: "authenticateMainnet", sensitiveData: "sensitiveMainnet", wavesToken: "wavesTokenMainnet")
        default:
            throw digilira.NAError.emptyAuth
        }
    }
    
    func getChain() throws -> String {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw digilira.NAError.emptyAuth }
        return chainId
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
            
            let timestamp = Int64(Date().timeIntervalSince1970) * 1000
            
            var devToken = "N/A"
            if let deviceToken = UserDefaults.standard.value(forKey: "deviceToken") as? String
            {
                devToken = deviceToken
            }
            var zmark = ""
            
            if let isInvitation = UserDefaults.standard.value(forKey: "invitation") as? String
            {
                zmark = isInvitation
            }
            
            let v = [devToken, btc, eth, imported.description, ltc, zmark]
            guard let signed = try? bytization( v, timestamp, seed) else {return}
            
            var user = digilira.exUser.init(btcAddress: btc,
                                            ethAddress: eth,
                                            ltcAddress: ltc,
                                            wallet: wallet,
                                            imported: imported,
                                            apnToken: devToken,
                                            zmark: zmark,
                                            signed: signed.signature,
                                            publicKey: senderPublicKey,
                                            timestamp: timestamp
            )
            
            if chainId != "T" {
                guard let usd = UserDefaults.standard.value(forKey: "usdtAddress") as? String else { return }
                user.tetherAddress = usd
                let v = [devToken, btc, eth, imported.description, ltc, usd, zmark]
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
                crud.onError = { error, sts in
                    
                }
                crud.onResponse = { [self] data, statusCode in
                    DispatchQueue.main.async  { [self] in
                        if statusCode == 200 {
                            do {
                                if secretKeys.LocksmithSave(forKey: source.authenticateData, data: data) {
                                    if imported {
                                        
                                        try Locksmith.deleteDataForUserAccount(userAccount: source.sensitiveData)
                                        try Locksmith.saveData(data: ["seed": seed], forUserAccount: source.sensitiveData)
                                        self.onComplete!(true, statusCode)
                                        
                                    }else {
                                        try Locksmith.saveData(data: ["seed": seed], forUserAccount: source.sensitiveData)
                                        self.onComplete!(true, statusCode)
                                    }
                                }
                            }catch {
                                if (error as! LocksmithError == LocksmithError.duplicate ) {
                                    try? Locksmith.deleteDataForUserAccount(userAccount: source.sensitiveData)
                                }
                                try? Locksmith.saveData(data: ["seed": seed], forUserAccount: source.sensitiveData)
                                
                                self.onComplete!(true, statusCode)
                            }
                        } else {
                            switch statusCode {
                            case 502:
                                self.onComplete!(false, 502)
                                break
                            case 400:
                                let defaults = UserDefaults.standard
                                let dictionary = defaults.dictionaryRepresentation()
                                dictionary.keys.forEach { key in
                                    defaults.removeObject(forKey: key)
                                }
                                UserDefaults.standard.setValue(true, forKey: "environment")
                                self.onComplete!(false, 400)
                                break
                            default:
                                self.onComplete!(false, 502)
                                break
                            }
                        }
                    }
                }
                crud.request(rURL: crud.getApiURL() + digilira.api.userRegister, postData: try JSONEncoder().encode(user), signature: user.signed!)
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
        
        self.onWavesApiError = { [self] res, sts, path in
            print(res,sts, path)
            createUser(seed: seed)
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

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


class Blockchain {
    
    
    private var balances: NodeService.DTO.AddressAssetsBalance?
    private var disposeBag: DisposeBag = DisposeBag()
    private var disposeBag2: DisposeBag = DisposeBag()
    
    private let wavesCrypto: WavesCrypto = WavesCrypto()
    
    let digiliraPay = digiliraPayApi()
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    
    var onAssetBalance: ((_ result: NodeService.DTO.AddressAssetsBalance)->())?
    var onTransferTransaction: ((_ result: NodeService.DTO.Transaction)->())?
    var onVerified: ((_ result: [String : AnyObject])->())?
    var onSensitive: ((_ result: digilira.wallet, _ err: String)->())?
    var onError: ((_ result: String)->())?
    var onPinSuccess: ((_ result: Bool)->())?
    var onSmartAvailable: ((_ result: Bool)->())?

    func checkAssetBalance(address: String ) {
        WavesSDK.shared.services.nodeServices.assetsNodeService
            .assetsBalances(address: address)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (balances) in
                self.onAssetBalance?(balances)
            })
            .disposed(by: disposeBag)
    }
        

    func sendTransaction2(recipient: String, fee: Int64, amount:Int64, assetId:String, attachment:String, wallet:digilira.wallet) {
            guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
            guard WavesCrypto.shared.address(seed: wallet.seed!, chainId: chainId) != nil else { return }
            guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed!) else { return }

            let feeAssetId = ""
            let buf: [UInt8] = Array(attachment.utf8)
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
            queryModel.sign(seed: wallet.seed!)
             
            let send = NodeService.Query.Transaction.transfer(queryModel)
            
            WavesSDK.shared.services
                .nodeServices // You can choose different Waves services: node, matcher and data service
                .transactionNodeService // Here methods of service
                .transactions(query: send)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (tx) in
                    self!.onTransferTransaction?(tx)
                }, onError: { (error ) -> Void in
                    self.onError!(error.localizedDescription)
                })
                .disposed(by: disposeBag)
    }
    
    func testMassTransferTx(recipient: String, fee: Int64, amount:Int64, assetId:String, attachment:String, wallet:digilira.wallet) {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard WavesCrypto.shared.address(seed: wallet.seed!, chainId: chainId) != nil else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed!) else { return }
        
        let fee: Int64 = fee
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000

        var queryModel = NodeService.Query.Transaction.MassTransfer.init(chainId: chainId,
                                                                       fee: fee,
                                                                       timestamp: timestamp,
                                                                       senderPublicKey: senderPublicKey,
                                                                       assetId: assetId,
                                                                       attachment: attachment,
                                                                       transfers: [.init(recipient: "3NCpyPuNzUaB7LFS4KBzwzWVnXmjur582oy", amount: 10000),
                                                                                   .init(recipient: recipient, amount: 1)])

        queryModel.sign(seed: wallet.seed!)

        let send = NodeService.Query.Transaction.massTransfer(queryModel)
        print(send)
        WavesSDK.shared.services
            .nodeServices
            .transactionNodeService
            .transactions(query: send)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {(tx) in
                print(tx) // Do something on success, now we have wavesBalance.balance in satoshi in Long
            }, onError: {(error) in
                print(error)
            })
        


    }
    
     
    func verifyTrx(txid: String, id:String) {
        getTransactionId(rURL: digilira.node.url + "/transactions/info/" + txid)
    }
    
    func getTransactionId(rURL: String) {
        
        let url = rURL
        
        var request = URLRequest(url: URL(string: rURL)!)
        request.httpMethod = digilira.requestMethod.get
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 404 {
                    sleep(1)
                    
                    self.getTransactionId(rURL: url)
                }else {
                    guard let dataResponse = data,
                        error == nil else {
                            print(error?.localizedDescription ?? "Response Error")
                            return }
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse) as! Dictionary<String, AnyObject>
                        self.onVerified!(jsonResponse)
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    func returnAsset (assetId: String) -> String {
        
        switch assetId {
        case "FjTB2DdymTfpYbCCdcFwoRbHQnEhQD11CUm6nAF7P1UD":
            return "Bitcoin"
        case "LVf3qaCtb9tieS1bHD8gg5XjWvqpBm5TaDxeSVcqPwn":
            return "Ethereum"
        case "49hWHwJcTwV7bq76NebfpEj8N4DpF8iYKDSAVHK9w9gF":
            return "Litecoin"
        case "HGoEZAsEQpbA3DJyV9J3X1JCTTBuwUB6PE19g1kUYXsH":
            return "Waves"
        case "2CrDXATWpvrriHHr1cVpQM65CaP3m7MJ425xz3tn9zMr":
            return "Charity"
        default:
            return "null"
        }
        
    }
    
    
    func base58 (data:String) -> String{
        let attachment =  WavesCrypto.shared.base58decode(input: data)
        let string = String(bytes: attachment!, encoding: .utf8)
        return string ?? "empty"
    }
    
    func smartD(initial: Bool) {
        let wallet = getSeed();
 
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
        guard let senderPublicKey = WavesCrypto.shared.publicKey(seed: wallet.seed!) else { return }
                
        let fee: Int64 = 1400000
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                
        var queryModel = NodeService.Query.Transaction.SetScript.init(chainId: chainId,
                                                                              fee: fee,
                                                                              timestamp: timestamp,
                                                                              senderPublicKey: senderPublicKey,
                                                                              script: digilira.smartAccount.script)
                
        queryModel.sign(seed: wallet.seed!)
        let send = NodeService.Query.Transaction.setScript(queryModel)

        if initial {
            WavesSDK.shared.services
                .nodeServices
                .transactionNodeService
                .transactions(query: send)
                .subscribe(onNext: {(tx) in
                    print(tx) // Do something on success, now we have wavesBalance.balance in satoshi in Long
                }, onError: {(error) in
                    print(error)
                })
        } else {
            digiliraPay.updateSmartAcountScript(data: send)
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
    
    
    func checkTransactions (address: String, returnCompletion: @escaping ([NodeService.DTO.Transaction]?) -> () ) {
        WavesSDK.shared.services.nodeServices.transactionNodeService
            .transactions(by: address, offset: 0, limit: 100)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe({(history) in
                returnCompletion(history.element?.transactions)
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
            self.onSensitive!(getSeed(), "ok")
            return
        }
        
        
        digiliraPay.onTouchID = { res, err in
            if res == true {
                self.onSensitive!(self.getSeed(), "ok")
            } else {
                self.onSensitive!(digilira.wallet.init(seed: ""), err)
            }
        }
        
        digiliraPay.touchID(reason: "Transferin gerçekleşebilmesi için biometrik onayınız gerekmektedir!")
   
    }
    
    private func getSeed() -> digilira.wallet {
        
        var seed = digilira.wallet.init(seed: "")
        
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
        if dictionary != nil {
            seed = digilira.wallet.init(seed: dictionary?["seed"] as? String)
        }
        return seed
    }
    
    func checkIfUser() -> Bool {
        //try? Locksmith.deleteDataForUserAccount(userAccount: "sensitive")
        if getSeed().seed == "" {return false}
        return true
    }
    
    
    func create (imported: Bool = false, importedSeed: String = "", returnCompletion: @escaping (String) -> () ) {
        
        let uuid = NSUUID().uuidString
        var seed = importedSeed
        
        if !imported {
            seed = wavesCrypto.randomSeed()
        }
        
        let address = wavesCrypto.address(seed: seed, chainId: "T")
        
        let username = NSUUID().uuidString
        
        let user = digilira.user.init(username: username,
                                   password: uuid,
                                   firstName: "Ad",
                                   lastName: "Soyad",
                                   tcno: "11111111111",
                                   tel: "0000000000",
                                   mail: "0000000000",
                                   btcAddress: "",
                                   ethAddress: "",
                                   ltcAddress: "",
                                   wallet: address!,
                                   imported: imported
        )
         
        
        digiliraPay.request(rURL: digilira.api.url + "/users/register",
                            JSON:  try? digiliraPay.jsonEncoder.encode(user),
                            METHOD: digilira.requestMethod.post
        ) { (json, statusCode) in
            DispatchQueue.main.async {
                try? Locksmith.saveData(data: ["password": uuid, "seed": seed, "username": username], forUserAccount: "sensitive")
                returnCompletion(address!)
            }
         }
 
 
        
    }
    
 
}


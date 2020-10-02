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
    
    private let wavesCrypto: WavesCrypto = WavesCrypto()
    
    let digiliraPay = digiliraPayApi()
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    
    var onAssetBalance: ((_ result: NodeService.DTO.AddressAssetsBalance)->())?
    var onTransferTransaction: ((_ result: NodeService.DTO.Transaction)->())?
    var onVerified: ((_ result: [String : AnyObject])->())?
    var onSensitive: ((_ result: digilira.wallet)->())?
    var onError: ((_ result: String)->())?
    var onPinSuccess: ((_ result: Bool)->())?

    func checkAssetBalance(address: String ) {
        WavesSDK.shared.services.nodeServices.assetsNodeService
            .assetsBalances(address: address)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (balances) in
                self.onAssetBalance?(balances)
            })
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
                })
                .disposed(by: disposeBag)
            
        
        

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
    
    func smartD() {
        

        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
        let wallet = digilira.wallet.init(seed: dictionary?["seed"] as? String)
 
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
                
                WavesSDK.shared.services
                    .nodeServices
                    .transactionNodeService
                    .transactions(query: send)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] (tx) in
                        //print(tx) // Do something on success, now we have wavesBalance.balance in satoshi in Long
                        
                    })
                
                
        
        
        
        
        
    }
    
    func retry(address: String) {
        
        checkBalance(address: address);
        
    }
    
    
    
    func checkBalance(address: String) {
        

                
                guard let chainId = WavesSDK.shared.enviroment.chainId else { return }
                //guard let address = WavesCrypto.shared.address(seed: json.seed!, chainId: chainId) else { return }
                
                
                WavesSDK.shared.services
                    .nodeServices
                    .addressesNodeService
                    .addressBalance(address: address)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] (balances) in
                        //print(balances)
                        let BC = Blockchain()
                        
                        if balances.balance < 1400000 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                print("retry")
                                BC.retry(address: address)
                            }
                        }else {
                            BC.smartD()
                        }
                    })
                 
            
        
         
    }
    
    
    func checkTransactions (address: String, returnCompletion: @escaping ([NodeService.DTO.Transaction]?) -> () ) {
        WavesSDK.shared.services.nodeServices.transactionNodeService
            .transactions(by: address, offset: 0, limit: 100)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe({(history) in
                returnCompletion(history.element?.transactions)
            })
    }
    
    func checkSmart(address: String) {
        
        
        let url = URL(string:  digilira.node.url + "/addresses/scriptInfo/" + address)
        
        var request = URLRequest(url: url!)
        
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
                DispatchQueue.main.async { // Correct
                    
                    //print(json)
                    
                    if json["complexity"] as! Int64 == 0 {
                        self.checkBalance(address: address)
                        
                    }else {
                        print("SMART ACCOUNT")
                    }
                    
                    
                }
            } catch {
                print("error")
            }
        })
        
        task.resume()
        
    }
    
    func getSensitive(pin:Bool) {

        let context = LAContext()
        var error: NSError?
        
        if pin {
            let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
            let seed = digilira.wallet.init(seed: dictionary?["seed"] as? String)
            self.onSensitive!(seed)
        }else {
          
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Transferin gerçekleşebilmesi için biometrik onayınız gerekmektedir!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    
                    if success {
                        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
                        let seed = digilira.wallet.init(seed: dictionary?["seed"] as? String)
                        
                        self!.onSensitive!(seed)
                    } else {
                        // error
                        self!.onError!(authenticationError!.localizedDescription)
                    }
                    
                }
            }
        } else {
            // no biometry
        }
        
        }
    }
    
    
    
    
    
    
    
    
    
    
}

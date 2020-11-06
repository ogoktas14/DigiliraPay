//
//  BitexenAPIView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 28.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//


import Foundation
import UIKit


class BitexenAPIView: UIView {

    @IBOutlet weak var textApiKey: UITextField!
    @IBOutlet weak var textApiSecret: UITextField!
    @IBOutlet weak var textApiPassphrase: UITextField!
    @IBOutlet weak var textUsername: UITextField!
    @IBOutlet weak var labelError: UILabel!

    weak var delegate: BitexenAPIDelegate?

    let digiliraPay = digiliraPayApi()
    let bitexenSign = bitexenSignature()

    @IBAction func btnExit(_ sender: Any) {
        delegate?.dismissBitexen()
    }
    
    
    override func awakeFromNib()
    {
        labelError.text = "";
        if  digiliraPay.isKeyPresentInUserDefaults(key: "bitexenAPI") {
                        
            let defaults = UserDefaults.standard
            if let savedAPI = defaults.object(forKey: "bitexenAPI") as? Data {
                let decoder = JSONDecoder()
                let loadedAPI = try? decoder.decode(digilira.bitexenAPICred.self, from: savedAPI)

                self.textApiKey.text = loadedAPI?.apiKey ?? ""
                self.textApiSecret.text = loadedAPI?.apiSecret ?? ""
                self.textApiPassphrase.text = loadedAPI?.passphrase ?? ""
                self.textUsername.text = loadedAPI?.username ?? ""
            }
        }
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        saveAPI()
       

    }
    
    func saveAPI() {
        
        let res = digilira.bitexenAPICred.init(apiKey: textApiKey.text!,
                                               apiSecret: textApiSecret.text!,
                                               passphrase: textApiPassphrase.text!,
                                               username: textUsername.text!)
        
        bitexenSign.onBitexenBalance = { _, statusCode in
            if statusCode == 200 {
                self.labelError.isHidden = true
                self.delegate?.dismissBitexen()
            } else {
                self.shake()
                self.labelError.isHidden = false
                self.labelError.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
                self.labelError.numberOfLines = 0
                self.labelError.text = "Girdiğiniz bilgileri kontrol edip tekrar deneyin."
            }
            
        }
        bitexenSign.getBalances(keys: res)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(res) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "bitexenAPI")
        }
    }
    

    
}
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
    
    @IBOutlet weak var saveView: UIView!

    weak var delegate: BitexenAPIDelegate?
    weak var errors: ErrorsDelegate?

    weak var del: WarningDelegate?

    let digiliraPay = digiliraPayApi()
    let bitexenSign = bex()

    @IBAction func btnExit(_ sender: Any) {
        delegate?.dismissBitexen()
    }
    
    
    override func awakeFromNib()
    {
        labelError.text = "";
        if  digiliraPay.isKeyPresentInUserDefaults(key: bex.bexApiDefaultKey.key) {
                        
            let defaults = UserDefaults.standard
            if let savedAPI = defaults.object(forKey: bex.bexApiDefaultKey.key) as? Data {
                let decoder = JSONDecoder()
                let loadedAPI = try? decoder.decode(bex.bitexenAPICred.self, from: savedAPI)

                self.textApiKey.text = loadedAPI?.apiKey ?? ""
                self.textApiSecret.text = loadedAPI?.apiSecret ?? ""
                self.textApiPassphrase.text = loadedAPI?.passphrase ?? ""
                self.textUsername.text = loadedAPI?.username ?? ""
            }
        }

        let tapOkGesture = UITapGestureRecognizer(target: self, action: #selector(saveAPI))
        saveView.addGestureRecognizer(tapOkGesture)
        saveView.isUserInteractionEnabled = true

        bitexenSign.onBitexenError = { [self] res, sts in
           
            saveView.alpha = 1
            saveView.isUserInteractionEnabled = true
            
            self.shake()
            
            errors?.errorHandler(message: "Girdiğiniz bilgileri kontrol edip tekrar deneyin.", title: "Bir Hata Oluştu")

            
        }
        
        
    }
    
    @objc func saveAPI() {
        
        saveView.alpha = 0.4
        saveView.isUserInteractionEnabled = false
        
        var res = bex.bitexenAPICred.init(apiKey: textApiKey.text!,
                                               apiSecret: textApiSecret.text!,
                                               passphrase: textApiPassphrase.text!,
                                               username: textUsername.text!,
                                               valid: false)
        
        
        bitexenSign.onBitexenBalance = { [self] _, statusCode in
            
            saveView.alpha = 1
            saveView.isUserInteractionEnabled = true
            
            if statusCode == 200 {  
                self.labelError.isHidden = true
                
                
                res.valid = true
                save2defaults(forKey: bex.bexApiDefaultKey.key, data: res)
                
                errors?.errorHandler(message: "API bilgileriniz kaydedildi.", title: "İşlem Başarılı")
                
            } 
            
        }
        bitexenSign.getBalances(keys: res)
        save2defaults(forKey:bex.bexApiDefaultKey.key, data: res)

    }
    
    func save2defaults (forKey: String, data: bex.bitexenAPICred) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: forKey)
        }
    }
    

    
}

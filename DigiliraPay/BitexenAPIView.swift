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
        
        
        bitexenSign.onBitexenError = { res, sts in
            
            
            self.shake()
            self.labelError.isHidden = false
            self.labelError.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
            self.labelError.numberOfLines = 0
            self.labelError.text = "Girdiğiniz bilgileri kontrol edip tekrar deneyin."
            
            
        }
        
        
    }
    
    @IBAction func btnSave(_ sender: Any) {
        saveAPI() 
    }
    
    func saveAPI() {
        
        var res = bex.bitexenAPICred.init(apiKey: textApiKey.text!,
                                               apiSecret: textApiSecret.text!,
                                               passphrase: textApiPassphrase.text!,
                                               username: textUsername.text!,
                                               valid: false)
        
        
        bitexenSign.onBitexenBalance = { [self] _, statusCode in
            if statusCode == 200 {  
                self.labelError.isHidden = true
                self.delegate?.dismissBitexen()
                
                res.valid = true
                save2defaults(forKey: bex.bexApiDefaultKey.key, data: res)
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

                let alert = UIAlertController(title: "İşlem Başarılı",message:"API bilgileriniz kaydedildi.",
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK",style:UIAlertAction.Style.default,handler: nil))
                window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
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

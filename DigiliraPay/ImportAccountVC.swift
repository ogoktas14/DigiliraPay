//
//  ImportAccountVC.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Locksmith

class ImportAccountVC: UIViewController {
    
    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var nextButtonLabel: UILabel!
    @IBOutlet weak var keyWordsTextView: UITextView!
    
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    
    var isKeyboard = false
    
    @IBAction func resettt(_ sender: Any) {
        try? Locksmith.deleteDataForUserAccount(userAccount: "sensitive")
        try? Locksmith.deleteDataForUserAccount(userAccount: "authenticate")
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        keyWordsTextView.text = ""
        
        nextButtonView.layer.maskedCorners = [.layerMinXMinYCorner]
        nextButtonView.layer.cornerRadius = nextButtonView.frame.height / 2
        nextButtonView.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
        
        let tapGoHome = UITapGestureRecognizer(target: self, action: #selector(goHome))
        nextButtonView.addGestureRecognizer(tapGoHome)
        
        let tapGoBack = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backButtonView.addGestureRecognizer(tapGoBack)
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: (self), action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboard {
            isKeyboard = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboard = false
        self.view.frame.origin.y = 0
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    @objc func goHome()
    {
        let seedTest = NSPredicate(format: "SELF MATCHES %@", digilira.regExp.seedRegex)
        let result = seedTest.evaluate(with: keyWordsTextView.text)
        
        if result {
            let alert = UIAlertController(title: "Lütfen bekleyin", message: "Girdiğiniz anahtar kelimeler kontrol ediliyor.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            digiliraPay.onError = { res, sts in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true, completion: nil)
                    switch sts {
                    case 503:
                        let alert = UIAlertController(title: "Bir Hata Oluştu", message: "Şu anda hizmet veremiyoruz. Lütfen daha sonra yeniden deneyin.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                            exit(1)
                        }))
                        self.present(alert, animated: true)
                        
                        break;
                    case 400, 404:
                        
                        let alert = UIAlertController(title: "Kullanıcı Bulunamadı", message: "Girdiğiniz anahtar kelimelere ait bir cüzdan hesabı bulunamadı. Girdiğiniz kelimeleri kontrol ederek yeniden deneyin.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                            //                    todo
                        }))
                        self.present(alert, animated: true)
                        
                        break
                        
                    default:
                        
                        let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu an işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                            exit(1)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    }
                }
            }
            
            BC.create(imported: true, importedSeed: keyWordsTextView.text) { (seed) in
                if (seed == "TRY AGAIN") {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    self.digiliraPay.onLogin2 = { user, status in
                        DispatchQueue.main.sync {
                            alert.dismiss(animated: true, completion: nil)
                            switch (status) {
                            
                            case 200:
                                UserDefaults.standard.set(false, forKey: "isSecure")
                                let alert = UIAlertController(title: "Cüzdanınız Başarıyla Aktarıldı!", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için KYC sürecini yeniden tamamlamanız gerekmektedir.", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                                    self.performSegue(withIdentifier: "toMainVCFromImport", sender: nil)
                                }))
                                self.present(alert, animated: true)
                                break
                            default:
                                break
                            }
                        }
                    }
                    self.digiliraPay.login2()
                }
            }
        }else {
            
            let alert = UIAlertController(title: "Dikkat", message: "Anahtar kelimeler eksik veya hatalı. Lütfen kontrole ederek tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil ))
            self.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toMainVCFromImport"
        {
            if let vc = segue.destination as? MainScreen {
                vc.pinkodaktivasyon = true
            }
        }
    }
    
    @objc func goBack()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

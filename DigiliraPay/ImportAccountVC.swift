//
//  ImportAccountVC.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class ImportAccountVC: UIViewController {

    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var nextButtonLabel: UILabel!
    @IBOutlet weak var keyWordsTextView: UITextView!
    
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    var kullanici: digilira.user?
    
    var isKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let alert = UIAlertController(title: "Lütfen bekleyin", message: "Cüzdanınız içeri aktarılıyor..", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        BC.create(imported: true, importedSeed: keyWordsTextView.text) { (seed) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                self.digiliraPay.login() { (json, status) in
                    DispatchQueue.main.async {
                        
                        alert.dismiss(animated: true, completion: nil)
                        switch (status) {
                        
                        case 200:
                            let alert = UIAlertController(title: "Cüzdanınız Başarıyla Aktarıldı!", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için KYC sürecini yeniden tamamlamanız gerekmektedir.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                                self.kullanici = json
                                self.performSegue(withIdentifier: "toMainVCFromImport", sender: nil)
                            }))
                            self.present(alert, animated: true)
                            break
                        
                        case 400, 404:
                            
                            let alert = UIAlertController(title: "Kullanıcı Bulunamadı", message: "Girdiğiniz anahtar kelimeler ile eşleşen bir cüzdan bulunamadı lütfen girdiğiniz kelimeleri kontrol ederek yeniden deneyin.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true)
                            
                            break
                        default:
                            break
                        
                        
                        }
                        
                        

                    }
                 }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toMainVCFromImport"
        {
            let vc = segue.destination as? MainScreen
            vc?.kullanici = kullanici
            vc?.pinkodaktivasyon = true
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

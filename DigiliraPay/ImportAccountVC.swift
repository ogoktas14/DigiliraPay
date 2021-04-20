//
//  ImportAccountVC.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 5.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import Locksmith

class ImportAccountVC: UIViewController {
    
    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var nextButtonLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet weak var headerInfoLabel: UILabel!
    @IBOutlet weak var subHeaderInfoLabel: UILabel!
    @IBOutlet weak var topInfoLabel: UILabel!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    @IBOutlet weak var keyWordsTextView: UITextView!
    
    let BC = BlockchainService()
    let throwEngine = ErrorHandling()
    
    let lang = Localize()
    
    var isKeyboard = false
    
    func checkSeed() {
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: Constants.login.self)
            let seed = loginCredits.seed
            
            keyWordsTextView.text = seed
        } catch {
            print (error)
        }
    }
    
    private func setUI() {
    
        nextButtonLabel.text = lang.getLocalizedString(Localize.importAccountVals.start_button.rawValue)
        backButtonLabel.text = lang.getLocalizedString(Localize.importAccountVals.back_button.rawValue)
        headerInfoLabel.text = lang.getLocalizedString(Localize.importAccountVals.header_info.rawValue)
        subHeaderInfoLabel.text = lang.getLocalizedString(Localize.importAccountVals.sub_header_info.rawValue)
        topInfoLabel.text = lang.getLocalizedString(Localize.importAccountVals.top_info.rawValue)
        bottomInfoLabel.text = lang.getLocalizedString(Localize.importAccountVals.bottom_info.rawValue)
    }
    
    override func viewDidLoad() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        if screenSize.height < 600 {
            bottomInfoLabel.isHidden = true
        }
        
        setUI()
        
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
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
        checkSeed()
        
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
        let seedTest = NSPredicate(format: "SELF MATCHES %@", Constants.regExp.seedRegex)
        let result = seedTest.evaluate(with: keyWordsTextView.text)
        
        if result {
            
            throwEngine.alertTransaction(title: "Lütfen bekleyin", message: "Girdiğiniz anahtar kelimeler kontrol ediliyor.", verifying: true)
            
            BC.onError = { [self] res in
                throwEngine.evaluateError(error: res)
            }
            
            BC.onComplete = { [self] res, status in
                
                switch status {
                case 200:
                    if (res) {
                        self.performSegue(withIdentifier: "toMainVCFromImport", sender: nil)
                        UserDefaults.standard.set(false, forKey: "isSecure")
                    }
                case 502:
                    throwEngine.evaluateError(error: Constants.NAError.E_502)
                default:
                    throwEngine.evaluateError(error: Constants.NAError.anErrorOccured)
                }
            }
            BC.createMainnet(imported: true, importedSeed: keyWordsTextView.text)
            
        }else {
            
            throwEngine.alertCaution(title: "Dikkat", message: "Anahtar kelimeler eksik veya hatalı. Lütfen kontrole ederek tekrar deneyin.")
            
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

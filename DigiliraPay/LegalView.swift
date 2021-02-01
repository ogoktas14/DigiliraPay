//
//  LegalView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import Locksmith
class LegalView: UIView {

    
    @IBOutlet weak var resetAppLink: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmAreaView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var davetiye: UITextField!
    @IBOutlet weak var davetiyeLabel: UILabel!

    let throwEngine = ErrorHandling()
    weak var delegate: LegalDelegate?
    var tapOkGesture = UITapGestureRecognizer()
    var m: String?
    var v: Int?
    var isKeyboard: Bool = false
    
    var buffer: CGFloat?
    
    let BC = Blockchain()
    
    override func awakeFromNib()
    {
        self.buffer = self.confirmAreaView.frame.origin.y
        let isMainnet = try! BC.getChain()
        
        if isMainnet == "W" {
            resetAppLink.isHidden=true
        }
        
        confirmView.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardHide(notification:)), name:  UIResponder.keyboardDidHideNotification, object: nil )
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide(notification:)))
        
        self.addGestureRecognizer(tap)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        content.addGestureRecognizer(swipeLeft)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboard {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                self.confirmAreaView.frame.origin.y -= keyboardSize.height
                buffer = keyboardSize.height
                isKeyboard = true
            }
        }
    }
    
    @objc func keyboardHide(notification: NSNotification) {

        isKeyboard = false
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        DispatchQueue.main.async { [self] in
            self.endEditing(true)
            if !isKeyboard {
                return
            }
            
            UIView.animate(withDuration: 0.4, animations: {
                self.confirmAreaView.frame.origin.y += buffer!
                isKeyboard = false
            })
        }
    }
    
    @IBAction func resetApp(_ sender: Any) {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: bex.bexApiDefaultKey.key)
        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "sensitive")

        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "authenticate")

        } catch  {
            print(error)
        }
        UserDefaults.standard.setValue(true, forKey: "environment")
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        throwEngine.resetApp()


        delegate?.dismissLegalView()
        
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .left:
                delegate?.dismissLegalView()
            default:
                break
            }
        }
    }
    
    @IBAction func entry(_ sender: Any) {

    }
    func setView() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        tapOkGesture = UITapGestureRecognizer(target: self, action: #selector(setOK))
        confirmView.addGestureRecognizer(tapOkGesture)
        tapOkGesture.isEnabled = true

        switch titleLabel.text  {
        case digilira.legalView.title:
            m = "isLegalView"
            v = digilira.legalView.version
            davetiyeLabel.isHidden = false
            davetiye.isHidden = false
            davetiye.isEnabled = false
            davetiye.text = "ONAYLI"
            davetiyeLabel.text = "Davetiye Kodu Doğrulandı"

            davetiye.alpha = 0.4

            break
        case digilira.termsOfUse.title:
            m = "isTermsOfUse"
            v = digilira.termsOfUse.version
            davetiye.isHidden = false
            davetiyeLabel.isEnabled = true
            davetiye.isHidden = false
            break
        default:
            return
        }
        
        let version = UserDefaults.standard.value(forKey: m!) as? Int
        
        if (version != nil) {
            if (v! <= version!) {
                confirmAreaView.isHidden = true
                davetiye.isHidden = true

                davetiyeLabel.isHidden = true
                davetiye.isHidden = true
            }
        }
    }
    
    @objc func setOK() {
        
        if titleLabel.text == digilira.termsOfUse.title  {
            if davetiye.text == "" {
                davetiyeLabel.text = "Davetiye Kodu Girmediniz."
                content.shake()
                return
            } else {
                
                let isOk = NSPredicate(format: "SELF MATCHES %@", "DP-[A-Z]{6}$")
                let result = isOk.evaluate(with: davetiye.text)
                if (!result) {
                    davetiyeLabel.text = "Davetiye kodunu hatalı girdiniz."
                    content.shake()
                    return
                }
                
                let array = digilira.codes.code
                
                let prefix = "INVITATION-"
                let inputString = prefix + davetiye.text!
                
                let hashed = inputString.hash256()
                
                if array.contains(where: {$0 == hashed}) {
                UserDefaults.standard.set(davetiye.text, forKey: "invitation")
                } else {
                    davetiyeLabel.text = "Davetiye kodunu hatalı girdiniz."
                    content.shake()
                    return
                }
                
            }
        }
        
        UserDefaults.standard.set(v, forKey: self.m!)
        delegate?.dismissLegalView()
        confirmAreaView.isHidden = true
    }
    
    @IBAction func goBackButton(_ sender: Any)
    {
        delegate?.dismissLegalView()
    }
}

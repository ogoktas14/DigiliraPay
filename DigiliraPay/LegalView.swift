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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var davetiye: UITextField!
    @IBOutlet weak var davetiyeLabel: UILabel!

    let throwEngine = ErrorHandling()
    weak var delegate: LegalDelegate?
    var tapOkGesture = UITapGestureRecognizer()
    var m: String?
    var v: Int?
    
    let BC = Blockchain()
    
    override func awakeFromNib()
    {
        
        let isMainnet = try! BC.getChain()
        
        if isMainnet == "W" {
            resetAppLink.isHidden=true
        }
        
        confirmView.clipsToBounds = true

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        content.addGestureRecognizer(swipeLeft)
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
        throwEngine.resetApp()

        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
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

        switch titleLabel.text {
        case digilira.legalView.title:
            m = "isLegalView"
            v = digilira.legalView.version
            davetiye.isHidden = false
        case digilira.termsOfUse.title:
            m = "isTermsOfUse"
            v = digilira.termsOfUse.version
            davetiye.isHidden = true
        default:
            return
        }
        
        let version = UserDefaults.standard.value(forKey: m!) as? Int
        
        if (version != nil) {
            if (v! <= version!) {
                confirmView.isHidden = true
            }
        }
    }
    
    @objc func setOK() {
        
        if davetiye.isHidden == false {
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
                if array.contains(where: {$0 == davetiye.text}) {
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
        confirmView.isHidden = true
    }
    
    @IBAction func goBackButton(_ sender: Any)
    {
        delegate?.dismissLegalView()
    }
}

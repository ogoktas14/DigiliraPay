//
//  ProfileMenuView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 27.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import LocalAuthentication

class ProfileMenuView: UIView {

    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var profileVerifyImage: UIImageView!
    @IBOutlet weak var biometricSecurityToggle: UISwitch!
    @IBOutlet weak var mainnetTestnet: UISwitch!
    
    @IBOutlet weak var profileVerifyLabel: UILabel!
    @IBOutlet weak var keywordsLabel: UILabel!
    @IBOutlet weak var termsofUseLabel: UILabel!
    @IBOutlet weak var userTextLabel: UILabel!
    @IBOutlet weak var securityLabel: UILabel!
    @IBOutlet weak var securityPinLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
     
    @IBOutlet weak var bitexenAPI: UIView!
    
    @IBOutlet weak var verifyProfileView: UIView!
    @IBOutlet weak var termsofUseView: UIView!
    @IBOutlet weak var legalTextView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var seedView: UIView!
    @IBOutlet weak var commissions: UIView!
    @IBOutlet weak var mnet: UIView!

    @IBOutlet weak var profileWarning: UIImageView!
    @IBOutlet weak var seedBackupWarning: UIImageView!
    @IBOutlet weak var legalViewWarning: UIImageView!
    @IBOutlet weak var termsViewWarning: UIImageView!
    @IBOutlet weak var pinWarning: UIImageView!
    
    let throwEngine = ErrorHandling()

    var currentLanguage: Languages = .TR
    var changeLanguageforEN = UITapGestureRecognizer()
    var changeLanguageforTR = UITapGestureRecognizer()
    
    var frameValue = CGRect()

    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)
    
    weak var delegate: ProfileMenuDelegate?
    
    override func awakeFromNib()
    {
        let verifyProfileTap = UITapGestureRecognizer(target: self, action: #selector(verifyProfile))
        verifyProfileView.addGestureRecognizer(verifyProfileTap)
        
        let showTermsofUseGesture = UITapGestureRecognizer(target: self, action: #selector(termsOfUse))
        termsofUseView.addGestureRecognizer(showTermsofUseGesture)
        
        let showLegalTextGesture = UITapGestureRecognizer(target: self, action: #selector(legalText))
        legalTextView.addGestureRecognizer(showLegalTextGesture)
        
        let showPinViewGesture = UITapGestureRecognizer(target: self, action: #selector(openPinView))
        pinView.addGestureRecognizer(showPinViewGesture)
        
        let showSeedViewGesture = UITapGestureRecognizer(target: self, action: #selector(openSeedView))
        seedView.addGestureRecognizer(showSeedViewGesture)
        
        let showBitexenGesture = UITapGestureRecognizer(target: self, action: #selector(openBitexenAPI))
        bitexenAPI.addGestureRecognizer(showBitexenGesture)
        
        let showCommissions = UITapGestureRecognizer(target: self, action: #selector(openCommissions))
        commissions.addGestureRecognizer(showCommissions)
        
        let authContext = LAContext()
        
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                securityLabel.text = "Pin"
                biometricSecurityToggle.setOn(true, animated: true)
                biometricSecurityToggle.isEnabled = false
            case .touchID:
                securityLabel.text = "Touch ID"
            case .faceID:
                securityLabel.text = "Face ID"
            @unknown default:
                securityLabel.text = "Pin"
                biometricSecurityToggle.setOn(true, animated: true)
                biometricSecurityToggle.isEnabled = false
            }
        
        
        if let isSecure = UserDefaults.standard.value(forKey: "isSecure") as? Bool
        {
            biometricSecurityToggle.isOn = isSecure
        }
        
        if let isMainnet = UserDefaults.standard.value(forKey: "environment") as? Bool
        {
            mainnetTestnet.isOn = isMainnet
        }
    }
    
    func setView() {
        
    }
    @objc func verifyProfile()
    {
        delegate?.verifyProfile()
    }
    @objc func termsOfUse()
    {
        delegate?.showTermsofUse()
    }
    @objc func legalText()
    {
        delegate?.showLegalText()
    }
    @objc func openPinView()
    {
        delegate?.showPinView()
    }
    @objc func openSeedView()
    {
        delegate?.showSeedView()
    }
    @objc func openBitexenAPI()
    {
        delegate?.showBitexenView()
    }
    @objc func openCommissions()
    {
        delegate?.showCommissions()
    }
    
    @IBAction func biometricSecuritySwitch(_ sender: Any)
    {
        UserDefaults.standard.setValue(biometricSecurityToggle.isOn, forKey: "isSecure")
    }
    
    @IBAction func mainnetTestnetSwitch(_ sender: Any)
    {
        UserDefaults.standard.setValue(mainnetTestnet.isOn, forKey: "environment")
        throwEngine.resetApp()
    }
    
 
    @objc func changeLanguage()
    {
        if currentLanguage == .EN
        {
            currentLanguage = .TR
        }
        else if currentLanguage == .TR
        {
            currentLanguage = .EN
        }
    }
}

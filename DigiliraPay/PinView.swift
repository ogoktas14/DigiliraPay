//
//  PinView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 27.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import LocalAuthentication
import Locksmith

class PinView: UIView {

    @IBOutlet weak var pinAreaView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pinArea1: UIView!
    @IBOutlet weak var pinArea2: UIView!
    @IBOutlet weak var pinArea3: UIView!
    @IBOutlet weak var pinArea4: UIView!
    
    @IBOutlet weak var warning1: UILabel!
    @IBOutlet weak var warning2: UILabel!
    @IBOutlet weak var pinArea1Label: UILabel!
    @IBOutlet weak var pinArea2Label: UILabel!
    @IBOutlet weak var pinArea3Label: UILabel!
    @IBOutlet weak var pinArea4Label: UILabel!
    @IBOutlet weak var entryAreaView: UIStackView!

    @IBOutlet weak var goBackButtonView: UIView!
    
    let generator = UINotificationFeedbackGenerator()

    let digiliraPay = DigiliraPayService()
    weak var errors: ErrorsDelegate?

    var tryAgain = 5
    weak var delegate: PinViewDelegate?
    
    let enteredColor =  UIColor(red: 0.8941, green: 0.0941, blue: 0.1686, alpha: 1.0)
    let unEnteredColor = UIColor(red:0.90, green:0.84, blue:0.84, alpha:1.0)
    
    var entered = [false, false, false, false]
    
    private var firstCode = ""
    private var lastCode = ""
    
    var isVerify = false
    var isEntryMode = false
    var isUpdateMode = false
    var isUpdating = false
    var isInit = false
    var isTouchIDCanceled = false
    var wrongEntry = 0
    var isPaymentMode = false
        
    var QR:String?
    let BC = BlockchainService()
    
    func compareHashPressed(pin: String, bcrypt: String) -> Bool {
        if firstCode == lastCode
        {
            do {
                let bcrpyt = try createHashPressed(pin: lastCode)
                delegate?.updatePinCode(code: bcrpyt)
            } catch  {
                print (error)
            }
            UserDefaults.standard.set(0, forKey: "wrongEntry")

            delegate?.closePinView()
            return true
        }
        
        if let compare = BCryptSwift.verifyPassword(pin, matchesHash: bcrypt) {
                if compare {
                    UserDefaults.standard.set(0, forKey: "wrongEntry")

                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }

    func generateSalt() -> String {
        let rounds : Int = Int(5)
        
        var salt : String
        if rounds >= 4 && rounds <= 31 {
            salt = BCryptSwift.generateSaltWithNumberOfRounds(UInt(rounds))
        }
        else {
            salt = BCryptSwift.generateSalt()
        }
        
        return salt
    }
    
    func createHashPressed(pin: String) throws -> String {
        if let hash = BCryptSwift.hashPassword(pin, withSalt: self.generateSalt()) {
            return hash
        }
        throw Constants.NAError.anErrorOccured
    }

    override func awakeFromNib()
    {
        
        if let we = UserDefaults.standard.value(forKey: "wrongEntry") as? Int {
            wrongEntry = we
        }
        setView()
        digiliraPay.onTouchID = { res, err in
            if res == true {
                self.delegate?.closePinView()
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor, UIColor.darkGray.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    func setView()
    {
        pinArea1Label.isHidden = true
        pinArea2Label.isHidden = true
        pinArea3Label.isHidden = true
        pinArea4Label.isHidden = true
        
        pinArea1.backgroundColor = unEnteredColor
        pinArea2.backgroundColor = unEnteredColor
        pinArea3.backgroundColor = unEnteredColor
        pinArea4.backgroundColor = unEnteredColor
        
        pinArea1.clipsToBounds = true
        pinArea2.clipsToBounds = true
        pinArea3.clipsToBounds = true
        pinArea4.clipsToBounds = true
        
        pinArea1.layer.cornerRadius = pinArea1.frame.height / 2
        pinArea2.layer.cornerRadius = pinArea2.frame.height / 2
        pinArea3.layer.cornerRadius = pinArea3.frame.height / 2
        pinArea4.layer.cornerRadius = pinArea4.frame.height / 2
        
        
    }
    
    func enterPin( _ number: Int)
    {
        if (entered[3]) {
            return
        }
        generator.notificationOccurred(.success)
        if isVerify { firstCode = firstCode + String(number)}
        else { lastCode = lastCode + String(number)}
        if !entered[0]
        {
            pinArea1Label.text = String(number)
            UIView.animate(withDuration: 0.3) {
                self.pinArea1.alpha = 0
                self.pinArea1Label.isHidden = false
            }
            entered[0] = true
        }
        else if !entered[1]
        {
            pinArea2Label.text = String(number)
            UIView.animate(withDuration: 0.3) {
                self.pinArea2.alpha = 0
                self.pinArea2Label.isHidden = false
                
                self.pinArea1.backgroundColor = self.enteredColor
                self.pinArea1.alpha = 1
                self.pinArea1Label.isHidden = true
            }
            entered[1] = true
        }
        else if !entered[2]
        {
            pinArea3Label.text = String(number)
            UIView.animate(withDuration: 0.3) {
                self.pinArea3.alpha = 0
                self.pinArea3Label.isHidden = false
                
                self.pinArea2.backgroundColor = self.enteredColor
                self.pinArea2.alpha = 1
                self.pinArea2Label.isHidden = true
            }

            entered[2] = true
        }
        else if !entered[3]
        {
            pinArea4Label.text = String(number)
            entryAreaView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.3, animations: {
                self.pinArea4.alpha = 1
                self.pinArea4.backgroundColor = self.enteredColor

                self.pinArea4Label.isHidden = true
                
                self.pinArea3.backgroundColor = self.enteredColor
                self.pinArea3.alpha = 1
                self.pinArea3Label.isHidden = true
            }, completion: { [self]_ in
                entered[3] = true
                if isVerify {
                    checkVerify()
                }
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.entered[3] { self.goVerify() }
                
            }
        }
    }
    
    func setCode() {
        
        do {
            let user = try secretKeys.userData()
            
            if user.status == 403000 {
                entryAreaView.isUserInteractionEnabled = false
                entryAreaView.alpha = 0.4
                delegate?.checkBlock()
            }
            
            isVerify = isEntryMode

            if isInit {
                titleLabel.text = "Bir Pin Belirleyin"
            }
            
            if isEntryMode && !isTouchIDCanceled {
                digiliraPay.touchID(reason: "Parmak izini okutarak giriş yapabilirsiniz.")
                self.goBackButtonView.isHidden = true
                
                self.lastCode = String((user.pincode))
            }
            if isUpdateMode {
                self.lastCode = String((user.pincode))
                isVerify = true
            }
            if isTouchIDCanceled {
                self.lastCode = String((user.pincode))
                self.goBackButtonView.isHidden = false
            }
            
        } catch {
            print("kullanici bilgileri okunamadı")
        }
        
    }
    
    func goVerify()
    {
        if !isVerify {
            entryAreaView.isUserInteractionEnabled = true
            isUpdating = true
            titleLabel.text = "Pini Doğrulayın"
        }
        entered = [false, false, false, false]
        isVerify = true
        
        pinArea1Label.isHidden = true
        pinArea2Label.isHidden = true
        pinArea3Label.isHidden = true
        pinArea4Label.isHidden = true
        
        pinArea1.alpha = 1
        pinArea2.alpha = 1
        pinArea3.alpha = 1
        pinArea4.alpha = 1
        
        pinArea1.backgroundColor = unEnteredColor
        pinArea2.backgroundColor = unEnteredColor
        pinArea3.backgroundColor = unEnteredColor
        pinArea4.backgroundColor = unEnteredColor
    }
    
    
    func checkVerify()
    {
        guard isVerify else { return }
        if lastCode.count < 4
        {
            
            while lastCode.count < 4  {
                lastCode = "0" + lastCode

            }
   
        
        }
        
        if compareHashPressed(pin: firstCode, bcrypt: lastCode) {
            if (isTouchIDCanceled) {
                isTouchIDCanceled = false
                isUpdateMode = false
                isEntryMode = false
                delegate?.pinSuccess(res:true)
                delegate?.closePinView()
                return
            }
            if isEntryMode {
                delegate?.closePinView()
            } else {
                if !isUpdateMode {
                    return
                }
            }
            
            if isUpdateMode {
                goVerify()
                entryAreaView.isUserInteractionEnabled = true
 
                warning1.isHidden = true
                warning2.isHidden = true
                
                firstCode.removeAll()
                titleLabel.text = "Yeni Pin Belirleyin"
                isVerify = false
                lastCode.removeAll()
                isUpdateMode=false
            }
        } else {
            entryAreaView.isUserInteractionEnabled = true
            
            if !isUpdating {
            wrongEntry += 1
                UserDefaults.standard.set(wrongEntry, forKey: "wrongEntry")

            warning1.isHidden = false
            warning2.isHidden = false
            
            if wrongEntry > 4 {
                   
                entryAreaView.alpha = 0.4
                entryAreaView.isUserInteractionEnabled = false
                warning1.isHidden = true
                warning2.isHidden = true
 
                goBackButtonView.isHidden = true
                delegate?.blockUser()
            }

            warning2.text = "Kalan deneme hakkınız: " + (tryAgain - wrongEntry).description
            }
            generator.notificationOccurred(.error)
            goVerify()
            pinAreaView.shake()
            pinAreaView.isHidden = false
            firstCode.removeAll()
                
            
            if !isEntryMode && !isUpdateMode  {
            titleLabel.text = "Pini Girin"
            isVerify = false
            lastCode.removeAll()
             
            }
        }
 
    }
    
    func deletePin()
    {
        guard entered[0] else { return }
        
        if isVerify { firstCode.removeLast() }
        else { lastCode.removeLast()}
        
        if entered[3]
        {
            pinArea4Label.isHidden = true
            pinArea4.backgroundColor = unEnteredColor
            pinArea4.alpha = 1
            pinArea4.isHidden = false
            entered[3] = false
        }
        else if entered[2]
        {
            pinArea3Label.isHidden = true
            pinArea3.backgroundColor = unEnteredColor
            pinArea3.isHidden = false
            pinArea3.alpha = 1
            entered[2] = false
        }
        else if entered[1]
        {
            pinArea2Label.isHidden = true
            pinArea2.backgroundColor = unEnteredColor
            pinArea2.isHidden = false
            pinArea2.alpha = 1
            entered[1] = false
        }
        else if entered[0]
        {
            pinArea1Label.isHidden = true
            pinArea1.backgroundColor = unEnteredColor
            pinArea1.isHidden = false
            pinArea1.alpha = 1
            entered[0] = false
        }
    }
    
    @IBAction func tap1Button(_ sender: Any)
    { enterPin(1) }
    @IBAction func tap2Button( _ sender: Any)
    { enterPin(2) }
    @IBAction func tap3Button( _ sender: Any)
    { enterPin(3) }
    @IBAction func tap4Button( _ sender: Any)
    { enterPin(4) }
    @IBAction func tap5Button( _ sender: Any)
    { enterPin(5) }
    @IBAction func tap6Button( _ sender: Any)
    { enterPin(6) }
    @IBAction func tap7Button( _ sender: Any)
    { enterPin(7) }
    @IBAction func tap8Button( _ sender: Any)
    { enterPin(8) }
    @IBAction func tap9Button( _ sender: Any)
    { enterPin(9) }
    @IBAction func tap0Button( _ sender: Any)
    { enterPin(0) }
    @IBAction func tapDelButton( _ sender: Any)
    { deletePin() }
    
    
    @IBAction func closeView(_ sender: Any)
    {
        if isTouchIDCanceled {
            delegate?.pinSuccess(res:false)
        }
        delegate?.closePinView()
    }
    @IBAction func goHomeButton(_ sender: Any)
    {
        delegate?.closePinView()
    }
}


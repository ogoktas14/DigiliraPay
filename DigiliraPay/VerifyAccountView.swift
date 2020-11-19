//
//  VerifyAccountView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class VerifyAccountView: UIView, UITextFieldDelegate
{
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var sendAndContiuneView: UIView!
    @IBOutlet weak var cameraButtonView: UIView!
    @IBOutlet weak var galleryButtonView: UIView!
    @IBOutlet weak var goHomeView: UIView!
    
    @IBOutlet weak var enterInfoView: UIView!
    @IBOutlet weak var sendIDPhotoView: UIView!
    @IBOutlet weak var finishedView: UIView!
    
    weak var delegate: VerifyAccountDelegate?
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var mailText: UITextField!
 
    let digiliraPay = digiliraPayApi()
    var onUpdate: ((_ result: [String:Any])->())?

    var kullanici: digilira.auth?

    override func didMoveToSuperview() {
        
        switch kullanici?.status {
        case 0:
           nameText.text = kullanici?.firstName
           surnameText.text = kullanici?.lastName
            tcText.text = kullanici?.tcno
           telText.text = kullanici?.tel
           mailText.text = kullanici?.mail
            break
        case 1:
           nameText.text = kullanici?.firstName
           surnameText.text = kullanici?.lastName
           tcText.text = kullanici?.tcno
           telText.text = kullanici?.tel
           mailText.text = kullanici?.mail
            
            nameText.isEnabled = false
            surnameText.isEnabled = false
            tcText.isEnabled = false
            break
        default:
            break
        }

    }
    
    
    @IBAction func btnExit(_ sender: Any) {
        goHome()
    }
    
    
    
    func validateEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if textField == tcText {return count <= 11}
        return count <= 40
    }
    
    override func awakeFromNib()
    {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor, UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.frame = galleryButtonView.bounds
        galleryButtonView.layer.addSublayer(gradient)
        
        sendAndContiuneView.clipsToBounds = true
        sendAndContiuneView.layer.cornerRadius = 6
        
        galleryButtonView.clipsToBounds = true
        galleryButtonView.layer.cornerRadius = 6
        
        cameraButtonView.clipsToBounds = true
        cameraButtonView.layer.cornerRadius = 6
        
        goHomeView.layer.addSublayer(gradient)
        goHomeView.clipsToBounds = true
        goHomeView.layer.cornerRadius = 6
        
        let sendAndContiuneGesture = UITapGestureRecognizer(target: self, action: #selector(sendAndContiune))
        
        let openCameraGesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        
        let openGalleryGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        
        let goHomeGesture = UITapGestureRecognizer(target: self, action: #selector(goHome))
        
        sendAndContiuneView.addGestureRecognizer(sendAndContiuneGesture)
        sendAndContiuneView.isUserInteractionEnabled = true
        
        cameraButtonView.addGestureRecognizer(openCameraGesture)
        cameraButtonView.isUserInteractionEnabled = true
        
        galleryButtonView.addGestureRecognizer(openGalleryGesture)
        galleryButtonView.isUserInteractionEnabled = true
        
        goHomeView.isUserInteractionEnabled = true
        goHomeView.addGestureRecognizer(goHomeGesture)
        
        nameText.delegate = self
        surnameText.delegate = self
        tcText.delegate = self
        tcText.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        telText.delegate = self
        
        mailText.delegate = self
        

        
    }
    
    func validate(value: String) -> Bool {
            let tcrgx = "^\\d{11}$"
            let tcTest = NSPredicate(format: "SELF MATCHES %@", tcrgx)
            let result = tcTest.evaluate(with: value)
            return result
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .white
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case nameText:
            surnameText.becomeFirstResponder()
        case surnameText:
            tcText.becomeFirstResponder()
        case tcText:
            telText.becomeFirstResponder()
        case telText:
            mailText.becomeFirstResponder()
        case mailText:
            delegate?.dismissKeyboard()
        default:
            delegate?.dismissKeyboard()
        }
 
        return true
    }
    
    func KYC() {
        digiliraPay.onUpdate = { res in

            self.digiliraPay.onLogin2 = { user, status in
                self.delegate?.dismissVErifyAccountView(user: user)
                self.kullanici = user
            }
            
            self.digiliraPay.login2()
        }
        
        let b64 = digiliraPay.convertImageToBase64String(img: UIImage(named: "test.jpg")!)

        delegate?.dismissKeyboard()
 
        let user = digilira.exUser.init(
            firstName: nameText.text,
            lastName: surnameText.text,
            tcno: tcText.text,
            tel: telText.text,
            mail: mailText.text, 
            status: 1,
            id1: b64
        )
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(user)
        
        digiliraPay.updateUser(user: data)
    }
    
    @objc func sendAndContiune()
    {
        let emailVal = validateEmail(enteredEmail: mailText.text!)
        let tcVal = validate(value: tcText.text!)
        
        var error = false
        
        if (emailVal == false) {
            mailText.textColor = .red
            error = true
        }
        
        if (tcVal == false) {
            tcText.textColor = .red
            error = true
        }
         
        if error {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

            let alert = UIAlertController(title: "Bilgilerinizi kontrol edin",message:"Hatalı girilen alanlar bulunmaktadır.",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertAction.Style.default,handler: nil))
            window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        enterInfoView.translatesAutoresizingMaskIntoConstraints = true
        sendIDPhotoView.translatesAutoresizingMaskIntoConstraints = true
        
        
        sendIDPhotoView.frame.origin.y = self.frame.height
        
        
        UIView.animate(withDuration: 0.3) {
            self.enterInfoView.frame.origin.y = self.self.frame.height
            self.sendIDPhotoView.frame.origin.y = 0
            self.sendIDPhotoView.alpha = 1
        }
    }
    
    @objc func openCamera()
    {
        KYC()
        
        finishedView.translatesAutoresizingMaskIntoConstraints = true
        finishedView.frame.origin.y = self.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.sendIDPhotoView.frame.origin.y = self.self.frame.height
            self.finishedView.frame.origin.y = 0
            self.finishedView.alpha = 1
        }
    }
    
    @objc func openGallery()
    {
        finishedView.translatesAutoresizingMaskIntoConstraints = true
        finishedView.frame.origin.y = self.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.enterInfoView.frame.origin.y = self.self.frame.height
            self.sendIDPhotoView.frame.origin.y = 0
            self.finishedView.alpha = 1
        }
    }
    
    @objc func goHome()
    {
        delegate?.dismissVErifyAccountView(user: kullanici!)
    }
}

//
//  VerifyAccountView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class VerifyAccountView: UIView
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

    var kullanici: digilira.user?

    override func didMoveToSuperview() {
        
        switch kullanici?.status {
        case 0:
           nameText.text = kullanici?.firstName
           surnameText.text = kullanici?.lastName
           tcText.text = kullanici?.tcno
           telText.text = kullanici?.tel
           mailText.text = kullanici?.mail
        case 1:
            
           nameText.text = kullanici?.firstName
           surnameText.text = kullanici?.lastName
           tcText.text = kullanici?.tcno
           telText.text = kullanici?.tel
           mailText.text = kullanici?.mail
            
        nameText.isEnabled = false
        surnameText.isEnabled = false
        tcText.isEnabled = false
        default:
            print(kullanici?.status)
        }
        
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
    }
    
    func KYC() {
        digiliraPay.onUpdate = { res in
            self.digiliraPay.login() { (json, status) in
                DispatchQueue.main.async {
                    print(json)
                    self.kullanici = json
                }
             }
        }
        
        let b64 = digiliraPay.convertImageToBase64String(img: UIImage(named: "test.jpg")!)

        delegate?.dismissKeyboard()
 
        let user = digilira.user.init(
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

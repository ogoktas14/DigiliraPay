//
//  ProfilUpgradeView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class ProfilUpgradeView: UIView {
    @IBOutlet weak var sendInfoView: UIView!
    @IBOutlet weak var FinishedView: UIView!
    @IBOutlet weak var verifiedPRofileView: UIView!
    
    @IBOutlet weak var cameraButtonView: UIView!
    @IBOutlet weak var galleryButtonView: UIView!
    @IBOutlet weak var goHomeView: UIView!
    @IBOutlet weak var verifiedGoHomeView: UIView!
    
    weak var delegate: VerifyAccountDelegate?
     
        override func awakeFromNib()
        {
            FinishedView.alpha = 0
            verifiedPRofileView.alpha = 1
            sendInfoView.alpha = 0
             
             
            let openCameraGesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
            
            let openGalleryGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
            
            let goHomeGesture = UITapGestureRecognizer(target: self, action: #selector(goHome))
            
            let goHomeGesture1 = UITapGestureRecognizer(target: self, action: #selector(goHome))

            
            cameraButtonView.addGestureRecognizer(openCameraGesture)
            cameraButtonView.isUserInteractionEnabled = true
            
            galleryButtonView.addGestureRecognizer(openGalleryGesture)
            galleryButtonView.isUserInteractionEnabled = true
            
            goHomeView.isUserInteractionEnabled = true
            goHomeView.addGestureRecognizer(goHomeGesture)
            
            verifiedGoHomeView.isUserInteractionEnabled = true
            verifiedGoHomeView.addGestureRecognizer(goHomeGesture1)
        }
        
        @objc func openCamera()
        {
            FinishedView.translatesAutoresizingMaskIntoConstraints = true
            FinishedView.frame.origin.y = self.frame.height
            
            UIView.animate(withDuration: 0.3) {
                self.sendInfoView.frame.origin.y = self.self.frame.height
                self.FinishedView.frame.origin.y = 0
                self.FinishedView.alpha = 1
            }
        }
        
        @objc func openGallery()
        {
            FinishedView.translatesAutoresizingMaskIntoConstraints = true
            FinishedView.frame.origin.y = self.frame.height
            
            UIView.animate(withDuration: 0.3) {
                self.sendInfoView.frame.origin.y = 0
                self.FinishedView.alpha = 1
            }
        }
        
        @objc func goHome()
        {
            delegate?.dismissVErifyAccountView()
        }
    }

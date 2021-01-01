//
//  ProfilUpgradeView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 5.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class ProfilUpgradeView: UIView {
    @IBOutlet weak var sendInfoView: UIView!
    @IBOutlet weak var galleryButtonView: UIView!
    weak var delegate: VerifyAccountDelegate?
    var verifying: Bool = false
    
    @IBAction func btnExit(_ sender: Any) {
        goHome()
    }
    
    override func awakeFromNib()
    {
        galleryButtonView.layer.cornerRadius = 25
        let openGalleryGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        galleryButtonView.addGestureRecognizer(openGalleryGesture)
        galleryButtonView.isUserInteractionEnabled = true
    }
  
    func setSendId() {
        sendInfoView.alpha = 1
    }
    
    @objc func openGallery()
    {
        delegate?.uploadImage()
        delegate?.dismissVErifyAccountView()
    }
    
    @objc func goHome()
    {
        delegate?.dismissVErifyAccountView()
    }
}

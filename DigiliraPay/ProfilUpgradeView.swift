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
    @IBOutlet weak var image: UIImageView!
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

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

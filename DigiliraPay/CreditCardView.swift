//
//  CreditCardView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 7.12.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit

class CreditCardView : UIView {
    
   @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var adsoyad: UILabel!
    @IBOutlet weak var address: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    func setView(tokenName: String, wallet: String, qr: UIImage, ad:String)
    {
        coinName.text = tokenName
        address.setTitle(wallet, for: .normal)
        imageView.image = qr
        adsoyad.text = ad
    }
    
    
    override func awakeFromNib() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        bottomView.layer.cornerRadius = 10
        
    }
    
    private func setShad(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
    
    
}

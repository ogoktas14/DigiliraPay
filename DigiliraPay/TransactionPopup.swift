//
//  TransactionPopup.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 3.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class TransactionPopup: UIView {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var remainingAmountInfoLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var buttonLabrl: UILabel!
    
    weak var delegate: TransactionPopupDelegate2?

    
    override func awakeFromNib()
    {
        buttonImage.setImageColor(color: .white)
        buttonView.clipsToBounds = true
        buttonView.layer.cornerRadius = 10
        
        titleLabel.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
        remainingAmount.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
        remainingAmountInfoLabel.textColor = UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.0)
        infoLabel.textColor = UIColor(red:0.32, green:0.32, blue:0.32, alpha:1.0)
    }
    
    @IBAction func button(_ sender: Any)
    {
        delegate?.close()
    }
    
    
}



extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
 

class TRXTRX: UIView {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var remainingAmountInfoLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    weak var delegate: TRXTRXDel?


    
       @IBAction func slideGesture(_ sender: UIPanGestureRecognizer)
        {
            delegate?.closeDetail()
        }
    
    
    
    override func awakeFromNib()
    {
 
    }
    
    
    
    
}

 

//
//  QRView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 3.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class QRView: UIView {

    @IBOutlet weak var adressInfoLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var speratorView: UIView!
    @IBOutlet weak var copyLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var delegate: LoadCoinDelegate?
    override func awakeFromNib()
    {
        speratorView.backgroundColor = UIColor(red:0.61, green:0.77, blue:0.99, alpha:1.0)
        copyLabel.textColor = UIColor(red:0.61, green:0.77, blue:0.99, alpha:1.0)
        
        shareButtonView.clipsToBounds = true
        shareButtonView.layer.cornerRadius = 6
        
        
    }

    @IBAction func shareButton(_ sender: Any)
    {
        delegate?.dismissLoadView()
    }
}

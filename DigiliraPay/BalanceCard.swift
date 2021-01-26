//
//  BalanceCardView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 25.11.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


class BalanceCard: UIView {
    
    @IBOutlet weak var onBoardingDesc: UILabel!
    @IBOutlet weak var balanceTL: UILabel!
    @IBOutlet weak var balanceTLicon: UILabel!
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var balanceCoin: UILabel!
    @IBOutlet weak var willPaidCoin: UILabel!
    @IBOutlet weak var paidCoin: UILabel!
    @IBOutlet weak var imgCoin: UIImageView!
    @IBOutlet weak var container: UIView! 
    
    func setView(desc: String, tl: String, amount: String, price: String, symbol: String, icon: UIImage!)
    {
        var coinIcon = icon
        if coinIcon == nil {
            coinIcon = UIImage(named: "ico2")
        }
        onBoardingDesc.text = desc
        balanceTL.text = tl
        balanceCoin.text = amount
        willPaidCoin.text = price
        paidCoin.text = symbol
        imgCoin.image = coinIcon
        
    }
    
    override func awakeFromNib() {
        setShad2(view: container, cornerRad: 10, mask: false)
    }
    
    func setShad2(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
}

//
//  BalanceCardView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 25.11.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit


class BalanceCard: UIView {
    
   @IBOutlet weak var onBoardingDesc: UILabel!
    @IBOutlet weak var balanceTL: UILabel!
    @IBOutlet weak var balanceCoin: UILabel!
    @IBOutlet weak var willPaidCoin: UILabel!
    @IBOutlet weak var paidCoin: UILabel!
    @IBOutlet weak var imgCoin: UIImageView! 
    
    func setView(desc: String, tl: String, amount: String, price: String, symbol: String)
    {
        onBoardingDesc.text = desc
        balanceTL.text = tl
        balanceCoin.text = amount
        willPaidCoin.text = price
        paidCoin.text = symbol
    }
    
    override class func awakeFromNib() { 
    }
    
}

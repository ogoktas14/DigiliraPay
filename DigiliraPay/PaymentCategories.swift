//
//  PaymentCategories.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import UIKit
import Wallet

class PaymentCat: WalletView1 {
    

    @IBOutlet weak var contentView: UIView!
    weak var delegate: PaymentCatViewsDelegate?
    var tableView = UITableView()
    var frameValue = CGRect()
    
    var cardCount = 1

    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setView() {
        self.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        var coloredCardViews = [ColoredCardView]()
        for index in 1...cardCount {
            let cardView = ColoredCardView.nibForClass()
            cardView.index = index
            coloredCardViews.append(cardView)
        }
        
        self.reload(cardViews: coloredCardViews)
        
        self.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            
        }
    }
    
 
    
    

    
}

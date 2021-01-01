//
//  PaymentCategories.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.10.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import UIKit
import Wallet

class PaymentCat: WalletView1, ColoredCardViewDelegate {
    func passData(data: String) {
        delegate?.passData(data: data)
    }
    
    @IBOutlet weak var contentView: UIView!
    weak var delegate: PaymentCatViewsDelegate?
    var tableView = UITableView()
    var frameValue = CGRect()
    
    var cardCount = 1
    var cards: [digilira.cardData] = []
    
    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setView() {
        self.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        var coloredCardViews = [ColoredCardView]()
        
        for item in cards {
            let cardView = ColoredCardView.nibForClass()
            cardView.delegate = self
            cardView.index = 1
            cardView.cardInfo = item
            if let bg = item.bg {
                cardView.bgView.image = UIImage(named: bg)
                cardView.bgView.isHidden = false

            }
            coloredCardViews.append(cardView)
            
        }
        
        self.reload(cardViews: coloredCardViews)
        self.didUpdatePresentedCardViewBlock = { (_) in
            
        }
    } 
}

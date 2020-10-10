//
//  PaymentCategories.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import UIKit
import Wallet

class PaymentCat: UIView {
    
    @IBOutlet weak var walletPane: WalletView1!


    var contentScrollView = UIScrollView()

    @IBOutlet weak var contentView: UIView!
    weak var delegate: PaymentCatViewsDelegate?
    var tableView = UITableView()
    var frameValue = CGRect()

    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        setScrollView()
        
        walletPane.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        var coloredCardViews = [ColoredCardView]()
        for index in 1...5 {
            let cardView = ColoredCardView.nibForClass()
            cardView.index = index
            coloredCardViews.append(cardView)
        }
        
        walletPane.reload(cardViews: coloredCardViews)
        
        walletPane.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            
        }
        
    }
    
    
    func setScrollView() // Ana sayfadaki içeriklerin gösterildiği scrollView
    {
        contentScrollView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: contentView.frame.width,
                                         height: contentView.frame.height)        
        
        contentScrollView.isScrollEnabled = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        if (contentView.subviews.count > 0) {
            contentView.willRemoveSubview(contentView.subviews[0])
        }
        contentView.addSubview(contentScrollView)
        
        
    }
    
    

    
}

//
//  PaymentCategories.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import UIKit

class PaymentCat: UIView, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().loadXib(name: "transactionHistoryCell") as! transactionHistoryCell
        return cell
    }
    

    var contentScrollView = UIScrollView()

    @IBOutlet weak var contentView: UIView!
    weak var delegate: PaymentCatViewsDelegate?
    var tableView = UITableView()
    var frameValue = CGRect()

    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        setScrollView()
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
    
    
    func setView()
    {
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: frameValue.width,
                                 height: frameValue.height)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
}

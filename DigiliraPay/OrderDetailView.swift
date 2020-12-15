//
//  OrderDetailView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 13.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

class OrderDetailView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    @IBOutlet weak var ok: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var msg: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var shoppingCart: [digilira.shoppingCart] = []

    let generator = UINotificationFeedbackGenerator()

    var title: String  = "Dikkat"
    var message: String  = "Dikkat"
    var isError: Bool = true
    var isTransaction: Bool = false
    var order:digilira.order?
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        self.layer.cornerRadius = 10
        titleView.layer.cornerRadius = 10
        
        ok.layer.cornerRadius = 25
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitView))
        ok.isUserInteractionEnabled = true
        ok.addGestureRecognizer(tap)
        
        self.frame.size.width = 0
        self.frame.size.height = 0
        
        msg.alpha = 0
        msg.frame.origin.y = self.frame.height
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: { [self] in
            msg.frame.origin.y = 0
            msg.alpha = 1
            
            self.frame.size.width = 0
            self.frame.size.height = 0
        }, completion: {_ in

        })
        
    }
    
    @objc func exitView() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: { [self] in
            self.alpha = 0
        }, completion: { [self]_ in
            self.removeFromSuperview()
        })

    }
    
    
    override func didMoveToSuperview() {
        shoppingCart = []
        setTableView()
    }
    
    
    func setTableView()
    {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = CGRect(x: 0,
                                 y: tableView.frame.height,
                                 width: msg.frame.width,
                                 height: msg.frame.height)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        msg.addSubview(tableView)
        
        UIView.animate(withDuration: 0.7)
        {
            self.msg.frame.origin.y = 0
            self.msg.alpha = 1
        }
    }

}


extension OrderDetailView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingCart = []
        if let order = order {
            if let products = order.products {
                for product in products {
                    if let productName = product.order_pname {
                        if let productPrice = product.order_price {
                            shoppingCart.append(digilira.shoppingCart.init(label: productName, price: productPrice, mode: 1))
                            
                        }
                    }
                }
                
                if  let kargo = order.order_shipping {
                    shoppingCart.append(digilira.shoppingCart.init(label: "Kargo Ücreti", price: kargo, mode: 1))
                }
                
                if  let total = order.totalPrice {
                    shoppingCart.append(digilira.shoppingCart.init(label: "Toplam", price: total, mode: 1))
                }
            }
            messageLabel.text = order.merchant
        }
        return shoppingCart.count
    }
    
    @objc func handleTap(recognizer: MyTapGesture) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = UITableViewCell().loadXib(name: "PayTableViewCell") as? PayTableViewCell
        {
            let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
            
            tapped.floatValue = indexPath[1]
            cell.addGestureRecognizer(tapped)
            
            cell.prodName.text = shoppingCart[indexPath[1]].label
            cell.prodPrice.text = "₺" + MainScreen.df2so(shoppingCart[indexPath[1]].price)
            
            
            switch shoppingCart[indexPath[1]].mode {
            case 2:
                cell.BGView.backgroundColor = .systemGreen
                break
            case -1:
                cell.discountView.isHidden = false
                break
            default:
                cell.BGView.backgroundColor = .clear
            }
            return cell
            
        }else
        { return UITableViewCell() }
    }
}

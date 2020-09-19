//
//  CoinSendView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class CoinSendView: UIView {

    @IBOutlet weak var receiptAdress: UILabel!
    @IBOutlet weak var receiptTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountEquivalent: UILabel!
    @IBOutlet weak var totalQuantity: UILabel!
    @IBOutlet weak var commissionAmount: UILabel!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var qrView: UIView!
    
    weak var delegate: SendCoinDelegate?
    
    var transaction: SendTrx?
    
    override func awakeFromNib()
    {
        receiptAdress.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
        amountLabel.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
        amountEquivalent.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
        totalQuantity.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:0.7)
        commissionAmount.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:0.7)
        
        amountTextField.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1)
        receiptTextField.textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1)
        
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(send))
        sendView.addGestureRecognizer(sendGesture)
        sendView.isUserInteractionEnabled = true
        
        sendView.clipsToBounds = true
        sendView.layer.cornerRadius = 10
        
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            receiptTextField.textColor = .white
            amountTextField.textColor = .white
        }
    }

    @objc func send()
    {
        if !(receiptTextField.text!.isEmpty && amountTextField.text!.isEmpty)
        {
            delegate?.sendCoin(params: transaction!)
        }
    }
}

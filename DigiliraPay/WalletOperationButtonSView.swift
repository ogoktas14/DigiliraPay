//
//  WalletOperationButtonSView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 30.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class WalletOperationButtonSView: UIView {

    @IBOutlet weak var sendMoneyView: UIView!
    @IBOutlet weak var loadMoneyView: UIView!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    
    weak var delegate: OperationButtonsDelegate?
    override func awakeFromNib()
    {
        sendMoneyView.layer.cornerRadius = 21
        loadMoneyView.layer.cornerRadius = 21
        
        sendMoneyView.layer.shadowColor = UIColor.black.cgColor
        sendMoneyView.layer.shadowOpacity = 0.15
        sendMoneyView.layer.shadowOffset = .zero
        sendMoneyView.layer.shadowRadius = 5
        
        loadMoneyView.layer.shadowColor = UIColor.black.cgColor
        loadMoneyView.layer.shadowOpacity = 0.15
        loadMoneyView.layer.shadowOffset = .zero
        loadMoneyView.layer.shadowRadius = 5
        
        let sendButtonTap = UITapGestureRecognizer(target: self, action: #selector(sendButton))
        sendMoneyView.addGestureRecognizer(sendButtonTap)
        sendMoneyView.isUserInteractionEnabled = true
        
        let loadButtonTap = UITapGestureRecognizer(target: self, action: #selector(loadButton))
        loadMoneyView.addGestureRecognizer(loadButtonTap)
        loadMoneyView.isUserInteractionEnabled = true
    }
    @objc func sendButton()
    {
        let empty = SendTrx.init(
            merchant: "",
            recipient: "",
            assetId: "",
            amount: 0,
            fee: 900000,
            fiat: 0,
            attachment: "",
            network: "")
        delegate?.send(params: empty)
    }
    @objc func loadButton()
    {
        delegate?.load()
    }
}

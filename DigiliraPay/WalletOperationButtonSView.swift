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
    @IBOutlet weak var send: UIView!
    @IBOutlet weak var load: UIView!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var balance: UIView!
    @IBOutlet weak var balanceText: UILabel!
    
    var blnx:String?
    
    weak var delegate: OperationButtonsDelegate?
    override func awakeFromNib()
    {
        send.layer.cornerRadius = 25
        load.layer.cornerRadius = 25
        sendMoneyView.layer.cornerRadius = 25
        loadMoneyView.layer.cornerRadius = 25
        balance.layer.cornerRadius = 25
         
        balance.clipsToBounds = true
        
        let sendButtonTap = UITapGestureRecognizer(target: self, action: #selector(sendButton))
        sendMoneyView.addGestureRecognizer(sendButtonTap)
        sendMoneyView.isUserInteractionEnabled = true
        
        let loadButtonTap = UITapGestureRecognizer(target: self, action: #selector(loadButton))
        loadMoneyView.addGestureRecognizer(loadButtonTap)
        loadMoneyView.isUserInteractionEnabled = true
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 1, options: .allowUserInteraction, animations: {
            self.sendLabel.alpha = 0
            self.sendMoneyView.backgroundColor = .clear 
            self.loadLabel.alpha = 0
            self.loadMoneyView.backgroundColor = .clear
            
        }, completion: { [self]_ in
            UIView.animate(withDuration: 0.3, animations: {
                self.balance.backgroundColor = .white
            }, completion: {_ in
                UILabel.animate(withDuration: 0.2, animations: {
                    balanceText.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
                    sendLabel.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
                    loadLabel.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
                    balanceText.frame.origin.y = 100
                    if let bal = blnx {
                        self.balanceText.text  = bal
                    }
                })
            })

        })
        
    }
    @objc func sendButton()
    {
        let empty = SendTrx.init(
            merchant: "",
            recipient: "",
            assetId: "",
            amount: 0,
            fee: digilira.sponsorTokenFee,
            fiat: 0,
            attachment: "",
            network: "")
        delegate?.send(params: empty)
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            self.send.alpha = 0
            self.sendLabel.alpha = 0
            self.sendMoneyView.alpha = 0
            self.send.frame.origin.x = 100
            self.sendMoneyView.frame.origin.x = 100
        }, completion: { [self]_ in
            self.send.alpha = 1
            self.sendMoneyView.alpha = 1
            self.send.frame.origin.x = 0
            self.sendMoneyView.frame.origin.x = 0
        })

    }
    @objc func loadButton()
    {
        
        let x1 = self.load.frame.origin.x
        let x2 = self.loadMoneyView.frame.origin.x
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            self.load.alpha = 0
            self.loadLabel.alpha = 0
            self.loadMoneyView.alpha = 0
            self.load.frame.origin.x = -100
            self.loadMoneyView.frame.origin.x = 0
        }, completion: { [self]_ in
            self.load.alpha = 1
            self.loadMoneyView.alpha = 1
            self.load.frame.origin.x = x1
            self.loadMoneyView.frame.origin.x = x2
        })
        
        
            delegate?.load()
    }
}

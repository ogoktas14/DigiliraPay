//
//  TransferConfirmationView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 18.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

class TransferConfirmationView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var yes: UIView!
    @IBOutlet weak var no: UIView!
    @IBOutlet weak var ok: UIView!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var msg: UIView!
    @IBOutlet weak var l1: UIButton!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var t2: UILabel!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var c2: UIImageView!

    var params: Constants.txConfMsg?
    var confirmation: Bool = false

    let generator = UINotificationFeedbackGenerator()

    var title: String  = "Dikkat"
    var message: String  = "Dikkat"
    var isError: Bool = true
    var isCaution: Bool = false
    var isTransaction: Bool = false
    var notifyDest: NSNotification.Name?
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        self.layer.cornerRadius = 10
        titleView.layer.cornerRadius = 10

        yes.layer.cornerRadius = 25
        let tapYes: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(confView(_:)))
        yes.isUserInteractionEnabled = true
        yes.addGestureRecognizer(tapYes)
        
        no.layer.cornerRadius = 25
        let tapNo: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitView(_:)))
        no.isUserInteractionEnabled = true
        no.addGestureRecognizer(tapNo)
        
        ok.layer.cornerRadius = 25
        ok.isUserInteractionEnabled = true
        let tapOk: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitView(_:)))
        ok.addGestureRecognizer(tapOk)
        
        self.frame.size.width = 0
        self.frame.size.height = 0
        
        msg.alpha = 0
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: { [self] in
            msg.alpha = 1
            
            self.frame.size.width = 0
            self.frame.size.height = 0
        }, completion: {_ in

        })
    }
    
    @objc func exitView(_ sender: UIView) {
        no.isUserInteractionEnabled = false
        no.alpha = 0.4
        notify(res: false)
    }
    
    @objc func confView(_ sender: UIView) {
        yes.isUserInteractionEnabled = false
        yes.alpha = 0.4
        notify(res: true)
    }
    
    func notify(res: Bool) {
        let result:[String: Bool] = ["confirmation": res]
        
        if let destination = notifyDest {
            NotificationCenter.default.post(name: destination, object: nil, userInfo: result )
        }

        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: { [self] in
            self.alpha = 0
        }, completion: { [self]_ in
            self.removeFromSuperview()
        })
    }
    
    func setMessage() {
        
        guard let p = params else {
            return
        }
        
        titleLabel.text = p.title
        messageLabel.text = p.message
        l1.setTitle(p.l1.description, for: .normal)
        sender.text = p.sender
        l2.text = p.l2
        l3.text = p.l3
        l4.text = p.l4
        t2.text = p.t2
        remark.text = p.remark
        c2.image = UIImage(named: p.c2 ?? "")

        if let customConfirm = p.yes {
            yesLabel.text = customConfirm
        }
        if p.no == "" {
            no.isHidden = true
            yes.isHidden = true
            ok.isHidden = false
        }
        if let customReject = p.no {
            noLabel.text = customReject
        }
        
        icon.image = UIImage(named: p.icon)
    }
}

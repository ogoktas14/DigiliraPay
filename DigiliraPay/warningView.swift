//
//  warningView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 12.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

class WarningView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var ok: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var msg: UIView!
    @IBOutlet weak var icon: UIImageView!

    var title: String  = "Dikkat"
    var message: String  = "Dikkat"
    var isError: Bool = true
    
    override func awakeFromNib() {

        self.layer.cornerRadius = 10
        titleView.layer.cornerRadius = 10
//        msg.frame.origin.y = 0 - self.frame.height
        
        ok.layer.cornerRadius = 25
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitView))
        ok.isUserInteractionEnabled = true
        ok.addGestureRecognizer(tap)
        
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
    
    
    @objc func exitView() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: { [self] in
            self.alpha = 0
        }, completion: { [self]_ in
            self.removeFromSuperview()
        })

    }
    
    
    func setMessage() {
        
        if !isError {
            icon.image = UIImage(named: "success")
        }
            titleLabel.text = title
            messageLabel.text = message
    }
}

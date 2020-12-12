//
//  warningView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 12.12.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit

class WarningView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    weak var delegate: WarningDelegate?

    @IBOutlet weak var titleView: UIView!

    var title: String  = "Dikkat"
    var message: String  = "Dikkat"
    
    override func awakeFromNib() {

        titleView.layer.cornerRadius = 25
        self.frame.origin.y = 0 - self.frame.height
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.frame.origin.y = 0
        }, completion: {_ in
            UIView.animateKeyframes(withDuration: 0.5, delay: 3, options: .allowUserInteraction, animations: {
                self.alpha = 0
                self.frame.origin.y = 0 - self.frame.height
            }, completion: {_ in
                self.removeFromSuperview()
            })
        })
        
    }
    
    
    func setMessage() { 
            titleLabel.text = title
            messageLabel.text = message
    }
}

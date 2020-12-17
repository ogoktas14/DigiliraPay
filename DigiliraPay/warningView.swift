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
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var loading: UIProgressView!

    @IBOutlet weak var ok: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var msg: UIView!
    @IBOutlet weak var icon: UIImageView!

    let generator = UINotificationFeedbackGenerator()

    var title: String  = "Dikkat"
    var message: String  = "Dikkat"
    var isError: Bool = true
    var isCaution: Bool = false
    var isTransaction: Bool = false
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
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
    
    func incProgress() {
        
        if loading.progress > 0.95 {
            loading.isHidden = true
            warningLabel.isHidden = true
            messageLabel.text = "İşleminiz normalden uzun sürüyor. İşlem sonuçlandığında bildirim yapılacaktır."
            ok.isHidden = false
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loading.progress = self.loading.progress + 0.01
                self.incProgress()
        }
    }
    
    
    func setMessage() {
        loading.isHidden = true
        if !isError {
            icon.image = UIImage(named: "success")
            generator.notificationOccurred(.success)
        }
        
        if isError {
            generator.notificationOccurred(.error)
        }
        
        if isTransaction {
            ok.isHidden = true
            loading.isHidden = false
            icon.image = UIImage(named: "verifying")
            warningLabel.isHidden = false
            
            incProgress()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.ok.isHidden = false
                self.warningLabel.isHidden = true
                self.removeFromSuperview()
            }
        }
        
        if isCaution {
            icon.image = UIImage(named: "caution") 
        }
        
        titleLabel.text = title
        messageLabel.text = message
    }
}

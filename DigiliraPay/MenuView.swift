//
//  MenuView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 25.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class MenuView: UIView {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var paymentsView: UIView!
    @IBOutlet weak var othersView: UIView!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var walletIcon: UIImageView!
    @IBOutlet weak var paymentsIcon: UIImageView!
    @IBOutlet weak var othersIcon: UIImageView!
    @IBOutlet weak var qrIcon: UIImageView!
    
    @IBOutlet weak var btn1: UIImageView!
    
    var delegate: MenuViewDelegate?
    
    override func awakeFromNib()
    {
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(goHome))
        let walletTapGesture = UITapGestureRecognizer(target: self, action: #selector(goWallet))
        let qrTapGesture = UITapGestureRecognizer(target: self, action: #selector(goQR))
        let settingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(goSettings))
        let paymentTapGesture = UITapGestureRecognizer(target: self, action: #selector(goPayments))
        
        homeIcon.addGestureRecognizer(homeTapGesture)
        walletIcon.addGestureRecognizer(walletTapGesture)
        qrIcon.addGestureRecognizer(qrTapGesture)
        paymentsIcon.addGestureRecognizer(paymentTapGesture)
        othersIcon.addGestureRecognizer(settingsTapGesture)
        
        selectorView.layer.cornerRadius = 3
        
        
    }
    func setView(mode: ())
    {
        
    }
    
    func home() {
        UIView.animate(withDuration: 0.3)
        { [self] in
            homeIcon.alpha = 1
            walletIcon.alpha = 0.3
            paymentsIcon.alpha = 0.3
            othersIcon.alpha = 0.3
            
            self.selectorView.center.x = self.homeIcon.center.x
        }
    }
    
    func wallet() {
        UIView.animate(withDuration: 0.3)
        { [self] in
            homeIcon.alpha = 0.3
            walletIcon.alpha = 1
            paymentsIcon.alpha = 0.3
            othersIcon.alpha = 0.3
            self.selectorView.center.x = self.walletIcon.center.x
        }
    }
    
    func payments () {
        UIView.animate(withDuration: 0.3)
        { [self] in
            
            homeIcon.alpha = 0.3
            walletIcon.alpha = 0.3
            paymentsIcon.alpha = 1
            othersIcon.alpha = 0.3
            
            self.selectorView.center.x = self.paymentsIcon.center.x
        }
    }
    
    func settings() {
        UIView.animate(withDuration: 0.3)
        { [self] in
            
            homeIcon.alpha = 0.3
            walletIcon.alpha = 0.3
            paymentsIcon.alpha = 0.3
            othersIcon.alpha = 1
            
            self.selectorView.center.x = self.othersIcon.center.x
        }
    }
    @objc func goHome()
    {
        home()
        delegate?.goHomeScreen()
    }
    
    
    @objc func goWallet()
    {
        wallet()
        delegate?.goWalletScreen(coin: "")
    }
    
    
    @objc func goPayments()
    {
        delegate?.goPayments()
        payments()
    }
    
    
    @objc func goSettings()
    {
        delegate?.goSettings()
        settings()
        
    }
    
    @objc func goQR()
    {
        delegate?.goQRScreen()
    }
    
    
}

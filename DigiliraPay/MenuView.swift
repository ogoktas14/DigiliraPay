//
//  MenuView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 25.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
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
        
        
    }
    func setView()
    {
    }

    @objc func goHome()
    {
        delegate?.goHomeScreen()
        
        homeIcon.image = UIImage(named: "homeSelected")
        walletIcon.image = UIImage(named: "walletNotSelected")
        paymentsIcon.image = UIImage(named: "kartDeselect")
        othersIcon.image = UIImage(named: "settingsNotSelected")
    }
    
    
    @objc func goWallet()
    {
        delegate?.goWalletScreen(coin: 0)
        
        
        homeIcon.image = UIImage(named: "homeNotSelected")
        walletIcon.image = UIImage(named: "walletSelected")
        paymentsIcon.image = UIImage(named: "kartDeselect")
        othersIcon.image = UIImage(named: "settingsNotSelected")
    }
    
    
    @objc func goPayments()
    {
        delegate?.goPayments()
        
        
        homeIcon.image = UIImage(named: "homeNotSelected")
        walletIcon.image = UIImage(named: "walletNotSelected")
        paymentsIcon.image = UIImage(named: "kart")
        othersIcon.image = UIImage(named: "settingsNotSelected")
    }
    
    
    @objc func goSettings()
    {
        delegate?.goSettings()
        
        
        homeIcon.image = UIImage(named: "homeNotSelected")
        walletIcon.image = UIImage(named: "walletNotSelected")
        paymentsIcon.image = UIImage(named: "kartDeselect")
        othersIcon.image = UIImage(named: "settingsSelected")
    }
    
    @objc func goQR()
    {
        delegate?.goQRScreen()
    }
    

}

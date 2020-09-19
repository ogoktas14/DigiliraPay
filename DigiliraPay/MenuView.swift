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
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var walletIcon: UIImageView!
    
    var delegate: MenuViewDelegate?
    
    override func awakeFromNib()
    {
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(goHome))
        let walletTapGesture = UITapGestureRecognizer(target: self, action: #selector(goWallet))
        let qrTapGesture = UITapGestureRecognizer(target: self, action: #selector(goQR))
        
        homeView.addGestureRecognizer(homeTapGesture)
        walletView.addGestureRecognizer(walletTapGesture)
        qrView.addGestureRecognizer(qrTapGesture)
        
        
    }
    func setView()
    {
        setSelector(view: homeView)
    }

    @objc func goHome()
    {
        setSelector(view: homeView)
        delegate?.goHomeScreen()
        
        homeIcon.image = UIImage(named: "homeSelected")
        walletIcon.image = UIImage(named: "walletNotSelected")
    }
    
    
    @objc func goWallet()
    {
        setSelector(view: walletView)
        delegate?.goWalletScreen(coin: 0)
        
        
        homeIcon.image = UIImage(named: "homeNotSelected")
        walletIcon.image = UIImage(named: "walletSelected")
    }
    
    @objc func goQR()
    {
        delegate?.goQRScreen()
    }
    
    func setSelector(view: UIView)
    {
        UIView.animate(withDuration: 0.3) {
            self.selectorView.frame.origin.x = view.frame.origin.x
        }
    }
}

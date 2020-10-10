//
//  CardView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 10.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//


import UIKit
import Wallet

class ViewController: UIViewController {

    @IBOutlet weak var walletView: WalletView1!

    @IBOutlet weak var addCardViewButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        walletView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        var coloredCardViews = [ColoredCardView]()
        for index in 1...3 {
            let cardView = ColoredCardView.nibForClass()
            cardView.index = index
            coloredCardViews.append(cardView)
        }
        
        walletView.reload(cardViews: coloredCardViews)
        
        walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            //self?.showAddCardViewButtonIfNeeded()
            //self?.addCardViewButton.addTransitionFade()
        }
        
    }
    
    func showAddCardViewButtonIfNeeded() {
        addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        walletView.insert(cardView: ColoredCardView.nibForClass(), animated: true, presented: true)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    
}

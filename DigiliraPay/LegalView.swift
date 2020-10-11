//
//  LegalView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Locksmith
class LegalView: UIView {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var confirmView: UIView!
    
    weak var delegate: LegalDelegate?
    var tapOkGesture = UITapGestureRecognizer()
    var m: String?
    var v: Int?
    
    override func awakeFromNib()
    {
        confirmView.clipsToBounds = true
        confirmView.layer.cornerRadius = 6
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                delegate?.dismissLegalView()
            case .down:
                delegate?.dismissLegalView()
            default:
                break
            }
        }
    }
    
    func setView() {
        
        tapOkGesture = UITapGestureRecognizer(target: self, action: #selector(setOK))
        confirmView.addGestureRecognizer(tapOkGesture)
        tapOkGesture.isEnabled = true

        switch titleLabel.text {
        case digilira.legalView.title:
            m = "isLegalView"
            v = digilira.legalView.version
        case digilira.termsOfUse.title:
            m = "isTermsOfUse"
            v = digilira.termsOfUse.version
        default:
            return
        }
        
        let version = UserDefaults.standard.value(forKey: m!) as? Int
        
        if (version != nil) {
            if (v! <= version!) {
                confirmView.isHidden = true
            }
            
        }
    }
    
    @objc func setOK() {
        UserDefaults.standard.set(v, forKey: self.m!)
        confirmView.isHidden = true
    }
    
    @IBAction func goBackButton(_ sender: Any)
    {
        delegate?.dismissLegalView()
    }
}

//
//  OnBoardingView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 10.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class OnBoardingView: UIView {
    @IBOutlet weak var onBoardingImage: UIImageView!
    @IBOutlet weak var onBoardingTitleFirst: UILabel!
    @IBOutlet weak var onBoardingTitleSecond: UILabel!
    @IBOutlet weak var onBoardingDesc: UILabel!
    
    
    func setView(image: UIImage, titleFirst: String, titleSecond: String, desc: String)
    {
        let screenSize: CGRect = UIScreen.main.bounds
        if screenSize.height < 600 {
            onBoardingDesc.isHidden = true
        }
        onBoardingImage.image = image
        onBoardingTitleFirst.text = titleFirst
        onBoardingTitleSecond.text = titleSecond
        onBoardingDesc.text = desc
        
    }
    func makeWhiteBackground()
    {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .light
            {
                onBoardingTitleFirst.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
                onBoardingTitleSecond.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
                onBoardingDesc.textColor = UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0)
            }
        }
        else
        {
            onBoardingTitleFirst.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
            onBoardingTitleSecond.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
            onBoardingDesc.textColor = UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0)
        }
        
    }
    
}

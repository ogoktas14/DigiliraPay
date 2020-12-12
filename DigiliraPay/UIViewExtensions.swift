//
//  UIViewExtensions.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func loadOnBoardingNib() -> OnBoardingView
    {
        return Bundle.main.loadNibNamed("OnBoardingView", owner: self, options: nil)?.first as! OnBoardingView
    }
    func loadNib(name: String) -> UIView
    {
        return Bundle.main.loadNibNamed(name, owner: self, options: nil)?.first as! UIView
    }
}

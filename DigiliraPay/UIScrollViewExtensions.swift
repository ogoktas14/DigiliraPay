//
//  UIScrollViewExtensions.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView
{
    func scrollToPage(index: UInt8)
    {
        UIView.animate(withDuration: 0.3) {
            self.contentOffset.x = self.frame.width * CGFloat(index)
        }
    }
}

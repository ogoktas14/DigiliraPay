//
//  LogoAnimation.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 20.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

class LogoAnimation: UIView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var view: UIView!

    func setImage() {
        rotate()
    }
    
    func rotate() {
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi)
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        view.layer.add(rotation, forKey: "rotationAnimation")
    }
    
}

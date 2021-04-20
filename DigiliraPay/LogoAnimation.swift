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
        view.rotate()
    }
}

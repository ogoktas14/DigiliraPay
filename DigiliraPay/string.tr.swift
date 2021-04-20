//
//  string.tr.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 15.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

struct turkish {
    
    static let bitexenCard = Constants.cardData.init(
        org: "Bitexen",
        bgColor: UIColor(red: 0.1882, green: 0.2588, blue: 0.3804, alpha: 1.0),
        logoName: "logo_bitexen",
        cardHolder:  "",
        cardNumber:  NSLocalizedString(Localize.messages.add_bitexen.rawValue, comment: ""),
        line1:  NSLocalizedString(Localize.messages.add_bitexen_message.rawValue, comment: ""),
        apiSet: false,
        bg: "bitexen_hover-1"
    )
    
    static let oneTower = Constants.cardData.init(
        org: "One Tower",
        bgColor:  UIColor(red: 0.549, green: 0.9765, blue: 1, alpha: 1.0),
        logoName: "one_tower_logo",
        cardHolder:  "",
        cardNumber: "One Tower",
        line1: NSLocalizedString(Localize.messages.one_tower_message.rawValue, comment: ""),
        apiSet: false
        
    )
    
}

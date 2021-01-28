//
//  Localization.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 27.01.2021.
//  Copyright © 2021 DigiliraPay. All rights reserved.
//

import Foundation

class Localize: NSObject {
    
    enum keys: String, CodingKey {
        case touch_id_reason, attention, no_camera, an_error_occured
    }
    
    struct tr {
        static let touch_id_reason = "Transferin gerçekleşebilmesi için biometrik onayınız gerekmektedir!"
        static let attention = "Dikkat"
        static let no_camera = "Kameranız bulunmamaktadır."
        static let an_error_occured = "Bir Hata Oluştu"
        

    }
    
    public func const(x: String) -> String{
        switch x {
        case "touch_id_reason":
            return tr.touch_id_reason
        case "attention":
            return tr.attention
        case "no_camera":
            return tr.no_camera
        case "an_error_occured":
            return tr.an_error_occured
        default:
            return "-"
        }
    }
    
    
}

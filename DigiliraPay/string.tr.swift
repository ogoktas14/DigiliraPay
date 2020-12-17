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
    
    static let bitexenCard = digilira.cardData.init(
        org: "Bitexen",
        bgColor: UIColor(red: 0.1882, green: 0.2588, blue: 0.3804, alpha: 1.0),
        logoName: "logo_bitexen",
        cardHolder:  "",
        cardNumber: "Bitexen Hesabı Ekle",
        line1: "Bitexen hesabınızı DigiliraPay'e bağlayın ve doğrudan borsa cüzdanınızdan ödeme yapın",
        line2: "Bitexen web sayfasındaki erişim ayaları sekmesinden API erişimi oluşturun. Oluşturduğunuz bilgileri Bitexen Hesabı ekle seçeneğini kullanarak DigiliraPay uygulamasına tanımlayın.",
        line3: "API bilgileriniz DigiliraPay sunucularına kaydedilmez sadece uygulamanızda kaydedilir.",
        apiSet: false,
        bg: "bitexen_hover-1"
    )
    static let okexCard = digilira.cardData.init(
        org: "Okex",
        bgColor:  UIColor(red: 0.0431, green: 0.1294, blue: 0.3843, alpha: 1.0), /* #0b2162 */
        logoName: "okex-1",
        cardHolder:  "",
        cardNumber: "Okex Hesabı Ekle",
        apiSet: false,
        bg: "okex_logo"
        
    )
    
    static let kizilayCard = digilira.cardData.init(
        org: "Kızılay",
        bgColor:  UIColor(red: 0.7529, green: 0.0039, blue: 0, alpha: 1.0), /* #c00100 */
        logoName: "logo_kizilay",
        cardHolder:  "",
        cardNumber: "Kızılay",
        line1: "Kızılay'a kripto varlıklarınızı kullanarak bağış yapabilirsiniz.",
        apiSet: false
        
    )
    
    struct messages {
        static let touchIDAuthorization = ""
    }
 
    
    
}

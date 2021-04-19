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
        cardNumber: "Bitexen Hesabı Ekle",
        line1: "bitexen hesabınızı DigiliraPay'e bağlayın, bitexen borsasında bulunan bakiyelerinizi görüntüleyin ve dilerseniz alışveriş yapın.\n\nbitexen hesabınızı bağlamak için sırası ile Ayarlar -> Erişim Ayarları sayfasına gidin. Yeni API oluştur butonuna tıklayarak 'İzleme İşlemleri' ve 'Yatırma-Çekme' işlemlerine izin verin. API erişimi için bir 'Parola' belirleyerek 'API Erişimi Oluştur' butonuna tıklayın.\n\nOluşturacağınız parola bitexen veya DigiliraPay sunucularına kaydedilmez sadece uygulamanıza kaydedilir.\n\nAPI erişimi oluştur butonuna tıkladıktan sonra bitexen tarafından e-posta adresinize gönderilen API Erişim Onayı linkine tıklayın.\n\nBilgileri kaybetmeniz durumunda yeni API erişimi oluşturmanız gerekmektedir.",
        apiSet: false,
        bg: "bitexen_hover-1"
    )
    
    static let oneTower = Constants.cardData.init(
        org: "One Tower",
        bgColor:  UIColor(red: 0.549, green: 0.9765, blue: 1, alpha: 1.0),
        logoName: "one_tower_logo",
        cardHolder:  "",
        cardNumber: "One Tower",
        line1: "One Tower AVM resmi sadakat jetonudur.\n\nOne Tower AVM içerisinde yer alan standlarda One Tower jetonlarınız ile alışveriş yapabilirsiniz.\n\nOne Tower jetonları başka DigiliraPay kullanıcıları arasında ücretsiz olarak transfer edebilir, birleştirerek harcanabilir.\n\nOne Tower jetonlarının nakdi bir karşılığı bulunmamaktadır. AVM'nin kendisi tarafından belirlenen promosyon ürünler, yine AVM tarafından belirlenen jeton bedelleri ile satın alınabilmektedir.\n\nOne Tower jetonları hakkında bilgiye onetoweravm.com.tr adresinden ulaşabilirsiniz.",
        apiSet: false
        
    )
      
    struct messages {
        static let touchIDAuthorization = ""
    }
 
    
    
}

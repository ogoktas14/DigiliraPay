//
//  ErrorHandling.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import WavesSDK

class ErrorHandling: NSObject {
     
    weak var errors: ErrorsDelegate?

    func evaluateError(error: Error) {
        switch error {
        case digilira.NAError.emptyAuth:
            alertWarning(title: "Bir Hata Oluştu", message: "Kullanıcı bilgileri okunamadı")
            break
        case digilira.NAError.emptyPassword:
            alertWarning(title: "Bir Hata Oluştu", message: "Kullanıcı bilgileri okunamadı")
            break
        case digilira.NAError.notListedToken:
            break
        case digilira.NAError.sponsorToken:
            return
        case NetworkError.negativeBalance:
            alertWarning(title: "Yetersiz Bakiye", message: "Bakiyeniz bu transferi gerçekleştirebilmek için yeterli değil.")
            break
        case NetworkError.internetNotWorking:
            alertWarning(title: "Bağlantı Hatası", message: "İnternet bağlantınızın olduğundan emin olup tekrar deneyiniz.")
            break
        case NetworkError.scriptError:
            alertWarning(title: "Yetkisiz İşlem", message: "Akıllı kontrat bu işleme izin vermemektedir.")
            break
        case NetworkError.serverError:
            alertWarning(title: "Bağlantı Hatası", message: "Blokzincir kaynaklı problemlerden dolayı işleminiz gerçekleşmemiştir.")
            break
        default:
            alertWarning(title: "Bağlantı Hatası", message: "İnternet bağlantınızın olduğundan emin olup tekrar deneyiniz.")
            break
        }
    }
    var warningView = WarningView()

    func alertWarning (title: String, message: String) {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
          
            warningView = UIView().loadNib(name: "warningView") as! WarningView
            warningView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: window.frame.width,
                                       height: window.frame.height)
            

            warningView.title = title
            warningView.message = message
            warningView.setMessage()
            
            window.addSubview(warningView)
        }

        
    }
}

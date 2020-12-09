//
//  ErrorHandling.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.12.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import WavesSDK

class ErrorHandling: NSObject {
     
    
    func evaluateError(error: Error) {
        switch error {
        case digilira.NAError.emptyAuth:
            showWarning(message: "Kullanıcı bilgileri okunamadı")
            break
        case digilira.NAError.emptyPassword:
            showWarning(message: "Kullanıcı bilgileri okunamadı")
            break
        case digilira.NAError.notListedToken:
            break
        case digilira.NAError.sponsorToken:
            return
        case NetworkError.negativeBalance:
            showWarning(message: "Bakiyeniz bu transferi gerçekleştirebilmek için yeterli değil.")
            break
        case NetworkError.internetNotWorking:
            showWarning(message: "İnternet bağlantınızın olduğundan emin olup tekrar deneyiniz.")
            break
        case NetworkError.scriptError:
            showWarning(message: "Akıllı kontrat bu işleme izin vermemektedir.")
            break
        case NetworkError.serverError:
            showWarning(message: "Blokzincir kaynaklı problemlerden dolayı işleminiz gerçekleşmemiştir.")
            break
        default:
            showWarning(message: "İnternet bağlantınızın olduğundan emin olup tekrar deneyiniz.")
            break
        }
    }
    
    func showWarning(message: String) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let alert = UIAlertController(title: "Bir Hata Oloştu", message:message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Tamam" ,style:UIAlertAction.Style.default,handler: nil))
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    
}

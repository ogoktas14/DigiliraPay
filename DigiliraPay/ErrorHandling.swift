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
            break
        case digilira.NAError.emptyPassword:
            break
        case digilira.NAError.notListedToken:
            break
        case digilira.NAError.sponsorToken:
            return
        case NetworkError.negativeBalance:
            break
        case NetworkError.internetNotWorking:
            break
        case NetworkError.scriptError:
            break
        case NetworkError.serverError:
            break
        default:
            break
        }
        showWarning(message: error.localizedDescription)
    }
    
    func showWarning(message: String) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let alert = UIAlertController(title: "Bir Hata Oloştu", message:message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Tamam" ,style:UIAlertAction.Style.default,handler: nil))
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    
}

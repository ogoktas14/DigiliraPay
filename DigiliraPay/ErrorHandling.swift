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
    var win = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
    var isOn:Bool = false
    var warningView = WarningView()
    var orderDetailView = OrderDetailView()
    var transferConfirmationView = TransferConfirmationView()
    
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
        case digilira.NAError.noBalance:
            alertWarning(title: "Blokzincir Hatası", message: "Blokzincir kaynaklı problemlerden dolayı işleminiz gerçekleşmemiştir. Lütfen daha sonra yeniden deneyin.")
            break
        default:
            DispatchQueue.main.async {
                
                self.warningView.removeFromSuperview()
                self.alertWarning(title: "Bir Hata Oluştu", message: "Geçersiz işlem")
            }
            break
        }
    }
    
    func alertWarning (title: String, message: String, error: Bool = true) {
        
        
        orderDetailView.removeFromSuperview()
        warningView.removeFromSuperview()
        transferConfirmationView.removeFromSuperview()

        
        DispatchQueue.main.async { [self] in
            
            warningView = UIView().loadNib(name: "warningView") as! WarningView
            warningView.frame = win!.frame
            
            warningView.isError = error
            warningView.title = title
            warningView.message = message
            warningView.setMessage()
            
            win?.addSubview(warningView)
            
        }
    }
    
    
    func alertCaution (title: String, message: String) {
        
        
        orderDetailView.removeFromSuperview()
        warningView.removeFromSuperview()
        transferConfirmationView.removeFromSuperview()

        
        DispatchQueue.main.async { [self] in
            
            warningView = UIView().loadNib(name: "warningView") as! WarningView
            warningView.frame = win!.frame
            
            warningView.isError = false
            warningView.isCaution = true
            warningView.title = title
            warningView.message = message
            warningView.setMessage()
            
            win?.addSubview(warningView)
            
        }
    }
    
    func alertTransaction (title: String, message: String, verifying: Bool) {
        
        DispatchQueue.main.async { [self] in
            orderDetailView.removeFromSuperview()
            warningView.removeFromSuperview()
            transferConfirmationView.removeFromSuperview()

            warningView = UIView().loadNib(name: "warningView") as! WarningView
            warningView.frame = win!.frame
            
            warningView.isTransaction = verifying
            warningView.title = title
            warningView.message = message
            warningView.setMessage()
            
            win?.addSubview(warningView)
            
        }
    }
    
    func transferConfirmation (txConMsg: digilira.txConfMsg, destination: NSNotification.Name) {
        
        DispatchQueue.main.async { [self] in
            orderDetailView.removeFromSuperview()
            warningView.removeFromSuperview()
            transferConfirmationView.removeFromSuperview()
            
            transferConfirmationView = UIView().loadNib(name: "TransferConfirmationView") as! TransferConfirmationView
            transferConfirmationView.frame = win!.frame
            
            transferConfirmationView.params = txConMsg
            transferConfirmationView.notifyDest = destination
            transferConfirmationView.setMessage()
            
            win?.addSubview(transferConfirmationView)
            
        }
    }
    
    func alertOrder (order: digilira.order) {
        DispatchQueue.main.async { [self] in
            
            orderDetailView.removeFromSuperview()
            warningView.removeFromSuperview()
              
            orderDetailView = UIView().loadNib(name: "OrderDetailView") as! OrderDetailView
            orderDetailView.frame = win!.frame

            orderDetailView.order = order
            win?.addSubview(orderDetailView)

        }
    }
    
    func resetApp () {

        for views in win!.subviews {
            views.removeFromSuperview()
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OnBoard")
        win?.rootViewController = vc
    }
}

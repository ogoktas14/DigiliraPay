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
    var logoAnimation = LogoAnimation()
    var orderDetailView = OrderDetailView()
    var transferConfirmationView = TransferConfirmationView()
    
    weak var errors: ErrorsDelegate?
    
    func evaluateError(error: Error) {
        switch error {
        
        case digilira.NAError.E_502:
            alertWarning(title: "Bir Hata Oluştu", message: "Şu anda işleminizi gerçekleştiremiyoruz. Lütfen daha sonra tekrar deneyin.", error: true)
            break
            
        case digilira.NAError.missingParameters:
            alertWarning(title: "Bir Hata Oluştu", message: "Girdiğiniz bilgileri kontrol ederek tekrar deneyin.", error: true)
            break
        case digilira.NAError.anErrorOccured:
            alertWarning(title: "Bir Hata Oluştu", message: "Lütfen tekrar deneyin.", error: true)
            break
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
        case digilira.NAError.noAmount:
            alertWarning(title: "Miktar Giriniz", message: "Gödermek istediğiniz miktarı giriniz.")
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
                print(error)
                self.warningView.removeFromSuperview()
                self.alertWarning(title: "Bir Hata Oluştu", message: "Geçersiz işlem")
            }
            break
        }
    }
    
    func waitPlease () {
        DispatchQueue.main.async { [self] in
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                logoAnimation.removeFromSuperview()
                
                logoAnimation = UIView().loadNib(name: "LogoAnimation") as! LogoAnimation
                logoAnimation.frame = w.frame
                
                logoAnimation.setImage()
                
                w.addSubview(logoAnimation)
            }
        }
    }
    
    func alertWarning (title: String, message: String, error: Bool = true) {
        DispatchQueue.main.async { [self] in
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                logoAnimation.removeFromSuperview()
                
                warningView = UIView().loadNib(name: "warningView") as! WarningView
                warningView.frame = w.frame
                
                warningView.isError = error
                warningView.title = title
                warningView.message = message
                warningView.setMessage()
                
                w.addSubview(warningView)
            }
        }
    }
    
    
    func alertCaution (title: String, message: String) {
        DispatchQueue.main.async { [self] in
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                logoAnimation.removeFromSuperview()
                
                warningView = UIView().loadNib(name: "warningView") as! WarningView
                warningView.frame = w.frame
                
                warningView.isError = false
                warningView.isCaution = true
                warningView.title = title
                warningView.message = message
                warningView.setMessage()
                
                w.addSubview(warningView)
            }
            
        }
    }
    
    func alertTransaction (title: String, message: String, verifying: Bool) {
        
        DispatchQueue.main.async { [self] in
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                logoAnimation.removeFromSuperview()
                
                warningView = UIView().loadNib(name: "warningView") as! WarningView
                warningView.frame = w.frame
                
                warningView.isTransaction = verifying
                warningView.title = title
                warningView.message = message
                warningView.setMessage()
                
                w.addSubview(warningView)
            }
            
        }
    }
    
    func removeWait() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [self] in
            UIView.animate(withDuration: 0.5, animations: {
                logoAnimation.alpha = 0
                
            },completion: {_ in
                logoAnimation.removeFromSuperview()
                
                logoAnimation.alpha = 1
                
            })
        })
    }
    
    func removeAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [self] in
            UIView.animate(withDuration: 0.5, animations: {
                orderDetailView.alpha = 0
                warningView.alpha = 0
                transferConfirmationView.alpha = 0
                logoAnimation.alpha = 0
                
            },completion: {_ in
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                logoAnimation.removeFromSuperview()
                
                orderDetailView.alpha = 1
                warningView.alpha = 1
                transferConfirmationView.alpha = 1
                logoAnimation.alpha = 1
                
            })
        }) 
    }
    
    func transferConfirmation (txConMsg: digilira.txConfMsg, destination: NSNotification.Name) {
        
        DispatchQueue.main.async { [self] in
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                transferConfirmationView.removeFromSuperview()
                
                transferConfirmationView = UIView().loadNib(name: "TransferConfirmationView") as! TransferConfirmationView
                transferConfirmationView.frame = w.frame
                
                transferConfirmationView.params = txConMsg
                transferConfirmationView.notifyDest = destination
                transferConfirmationView.setMessage()
                
                w.addSubview(transferConfirmationView)
            }
        }
    }
    
    func alertOrder (order: PaymentModel) {
        DispatchQueue.main.async { [self] in
            
            if let w = win {
                orderDetailView.removeFromSuperview()
                warningView.removeFromSuperview()
                
                orderDetailView = UIView().loadNib(name: "OrderDetailView") as! OrderDetailView
                orderDetailView.frame = w.frame
                
                orderDetailView.order = order
                w.addSubview(orderDetailView)
            }
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


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
    
    let lang = Localize()
    
    weak var errors: ErrorsDelegate?
    
    func evaluateError(error: Error) {
        switch error {
        
        case Constants.NAError.E_502:
            alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Şu anda işleminizi gerçekleştiremiyoruz. Lütfen daha sonra tekrar deneyin.", error: true)
            break
            
        case Constants.NAError.missingParameters:
            alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Girdiğiniz bilgileri kontrol ederek tekrar deneyin.", error: true)
            break
        case Constants.NAError.anErrorOccured:
            alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Lütfen tekrar deneyin.", error: true)
            break
        case Constants.NAError.emptyAuth:
            alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Kullanıcı bilgileri okunamadı")
            break
        case Constants.NAError.emptyPassword:
            alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Kullanıcı bilgileri okunamadı")
            break
        case Constants.NAError.notListedToken:
            break
        case Constants.NAError.sponsorToken:
            return
        case Constants.NAError.tokenNotFound:
            return
        case Constants.NAError.noAmount:
            alertWarning(title: "Miktar Giriniz", message: "Minimum gönderme tutarının altında bir miktar girdiniz.")
            return
        case NetworkError.negativeBalance:
            alertWarning(title: "Yetersiz Bakiye", message: "Bakiyeniz bu transferi gerçekleştirebilmek için yeterli değil.")
            break
        case NetworkError.internetNotWorking:
            alertWarning(title: "Bağlantı Hatası", message: "İnternet bağlantınızın olduğundan emin olup tekrar deneyiniz.")
            break
        case NetworkError.message("Error while executing token-script: The recipient is not authorized to possess this SmartAsset!"):
            alertWarning(title: "Yetkisiz İşlem", message: "Göndermeye çalıştığınız akıllı token bu adrese gönderilememektedir.")
            break
            
        case NetworkError.message("This asset has special requirements 2"):
            alertWarning(title: "Yetkisiz İşlem", message: "Bu token ile ödeme yapabilmeniz için. Kullanıcı onayından geçmeniz gerekmektedir.")
            break
        case NetworkError.message("Error while executing account-script: Can not transfer this asset 4"):
            alertWarning(title: "Yetkisiz İşlem", message: "Bu token ile ödeme yapamazsınız.")
            break
            
        case NetworkError.message("Error while executing account-script: Cannot use this token for none DigiliraPay users transfers."):
            alertWarning(title: "Yetkisiz İşlem", message: "Akıllı kontrat bu işleme izin vermemektedir.")
            break
        case NetworkError.scriptError:
            alertWarning(title: "Yetkisiz İşlem", message: "Akıllı kontrat bu işleme izin vermemektedir.")
            break
        case NetworkError.serverError:
            alertWarning(title: "Bağlantı Hatası", message: "Blokzincir kaynaklı problemlerden dolayı işleminiz gerçekleşmemiştir.")
            break
        case Constants.NAError.noBalance:
            alertWarning(title: "Blokzincir Hatası", message: "Blokzincir kaynaklı problemlerden dolayı işleminiz gerçekleşmemiştir. Lütfen daha sonra yeniden deneyin.")
            break
        case Constants.NAError.minBalance:
            
            alertWarning(title: "Blokzincir Hatası", message: "Minimum miktarın altında transfer gerçekleştiremezsiniz." .debugDescription)
            break
        case Constants.NAError.noPhone:
            
            alertWarning(title: "Hatalı Giriş", message: "Telefon numarası bilgisini eksik veya hatalı girdiniz.")
            break
        case Constants.NAError.noEmail:
            alertWarning(title: "Hatalı Giriş", message: "E-posta bilgisini eksik veya hatalı girdiniz.")
            break
        case Constants.NAError.noTC:
            alertWarning(title: "Hatalı Giriş", message: "TC kimlik numaranızı eksik veya hatalı girdiniz.")
            break
        case Constants.NAError.noName:
            alertWarning(title: "Hatalı Giriş", message: "Ad bilgisi hatalı.")
            break
        case Constants.NAError.noSurname:
            alertWarning(title: "Hatalı Giriş", message: "Soyad bilgisi hatalı.")
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
                removeWait()
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
    
    func transferConfirmation (txConMsg: Constants.txConfMsg, destination: NSNotification.Name) {
        
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


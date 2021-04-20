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
            alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue), message: lang.getLocalizedString(Localize.keys.cannot_perform_this_action_try_again.rawValue), error: true)
            break
            
        case Constants.NAError.missingParameters:
            alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                         message: lang.getLocalizedString(Localize.messages.missing_parameters.rawValue),
                         error: true)
            break
        case Constants.NAError.anErrorOccured:
            alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                         message: lang.getLocalizedString(Localize.messages.try_again.rawValue),
                         error: true)
            break
        case Constants.NAError.emptyAuth:
            alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                         message: lang.getLocalizedString(Localize.messages.empty_auth.rawValue))
            break
        case Constants.NAError.emptyPassword:
            alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                         message: lang.getLocalizedString(Localize.messages.empty_auth.rawValue))
            break
        case Constants.NAError.notListedToken:
            break
        case Constants.NAError.sponsorToken:
            return
        case Constants.NAError.tokenNotFound:
            return
        case Constants.NAError.noAmount:
            alertWarning(title:lang.getLocalizedString(Localize.messages.enter_amount.rawValue),
                         message: lang.getLocalizedString(Localize.messages.below_minimum.rawValue))
            return
        case NetworkError.negativeBalance:
            alertWarning(title: lang.getLocalizedString(Localize.keys.out_of_balance_header.rawValue),
                         message: lang.getLocalizedString(Localize.keys.out_of_balance_message.rawValue))
            break
        case NetworkError.internetNotWorking:
            alertWarning(title: lang.getLocalizedString(Localize.messages.connection_problem.rawValue),
                         message: lang.getLocalizedString(Localize.messages.no_internet.rawValue))
            break
        case NetworkError.message("Error while executing token-script: The recipient is not authorized to possess this SmartAsset!"):
            alertWarning(title: lang.getLocalizedString(Localize.messages.access_denied.rawValue),
                         message: lang.getLocalizedString(Localize.messages.cannot_send_this_token.rawValue))
            break
            
        case NetworkError.message("This asset has special requirements 2"):
            alertWarning(title: lang.getLocalizedString(Localize.messages.access_denied.rawValue),
                         message: lang.getLocalizedString(Localize.messages.verify_profile_to_make_payment.rawValue))
            break
        case NetworkError.message("Error while executing account-script: Can not transfer this asset 4"):
            alertWarning(title: lang.getLocalizedString(Localize.messages.access_denied.rawValue),
                         message: lang.getLocalizedString(Localize.messages.cannot_pay_with_this_token.rawValue))
            break
            
        case NetworkError.message("Error while executing account-script: Cannot use this token for none DigiliraPay users transfers."):
            alertWarning(title: lang.getLocalizedString(Localize.messages.access_denied.rawValue),
                         message: lang.getLocalizedString(Localize.messages.smart_account_not_allowed.rawValue))
            break
        case NetworkError.scriptError:
            alertWarning(title:lang.getLocalizedString(Localize.messages.access_denied.rawValue),
                         message: lang.getLocalizedString(Localize.messages.smart_account_not_allowed.rawValue))
            break
        case NetworkError.serverError:
            alertWarning(title:lang.getLocalizedString(Localize.messages.connection_problem.rawValue),
                         message: lang.getLocalizedString(Localize.messages.blockchain_error_message.rawValue))
            break
        case Constants.NAError.noBalance:
            alertWarning(title: lang.getLocalizedString(Localize.messages.blockchain_error.rawValue),
                         message: lang.getLocalizedString(Localize.messages.blockchain_error_message_try_again.rawValue))
            break
        case Constants.NAError.minBalance:
            
            alertWarning(title: lang.getLocalizedString(Localize.messages.blockchain_error.rawValue),
                         message: lang.getLocalizedString(Localize.messages.not_allowed_below_minimum.rawValue))
            break
        case Constants.NAError.noPhone:
            
            alertWarning(title: lang.getLocalizedString(Localize.keys.wrong_entry_header.rawValue),
                         message: lang.getLocalizedString(Localize.messages.tel_missing.rawValue))
            break
        case Constants.NAError.noEmail:
            alertWarning(title: lang.getLocalizedString(Localize.keys.wrong_entry_header.rawValue),
                         message: lang.getLocalizedString(Localize.messages.e_mail_missing.rawValue))
            break
        case Constants.NAError.noTC:
            alertWarning(title: lang.getLocalizedString(Localize.keys.wrong_entry_header.rawValue),
                         message: lang.getLocalizedString(Localize.messages.tc_missing.rawValue))
            break
        case Constants.NAError.noName:
            alertWarning(title: lang.getLocalizedString(Localize.keys.wrong_entry_header.rawValue),
                         message: lang.getLocalizedString(Localize.messages.name_missing.rawValue))
            break
        case Constants.NAError.noSurname:
            alertWarning(title: lang.getLocalizedString(Localize.keys.wrong_entry_header.rawValue),
                         message: lang.getLocalizedString(Localize.messages.surname_missing.rawValue))
            break
        default:
            DispatchQueue.main.async {
                print(error)
                self.warningView.removeFromSuperview()
                self.alertWarning(title: self.lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                                  message: self.lang.getLocalizedString(Localize.messages.undefined.rawValue))
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


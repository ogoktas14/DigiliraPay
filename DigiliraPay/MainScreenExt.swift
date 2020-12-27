//
//  MainScreenExt.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 20.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


extension MainScreen: NewCoinSendDelegate
{
    func dismissNewSend()
    {
        isNewSendScreen = false
        menuView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }, completion: {_ in
            for subView in self.sendWithQRView.subviews
            { subView.removeFromSuperview() }
        })

    }
    
    func sendCoinNew(params:SendTrx) // gelen parametrelerle birlikte gönder butonuna basıldı.
    {
        let ifPin = kullanici.pincode
        
        if ifPin == "-1" {
            openPinView()
        }else {
            
            
            BC.onSensitive = { [self] wallet, err in
                switch err {
                case "ok":
                    self.dismissNewSend()
                    switch params.destination {
                    case digilira.transactionDestination.domestic:
                        BC.sendTransaction2(name: params.merchant!, recipient: params.recipient!, fee: digilira.sponsorTokenFee, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment, wallet:wallet, blob: params)
                        break
                    case digilira.transactionDestination.foreign:
                        
                        BC.getWavesToken(wallet:wallet)
                        
                        BC.massTransferTx(name: params.merchant!, recipient: params.recipient!, fee: digilira.sponsorTokenFeeMass, amount: params.amount!, assetId: params.assetId!, attachment: "", wallet: wallet, blob: params)
             
                        break
                    case digilira.transactionDestination.interwallets:
                        BC.massTransferTx(name: params.merchant!, recipient: params.recipient!, fee: digilira.sponsorTokenFeeMass, amount: params.amount!, assetId: params.assetId!, attachment: "", wallet: wallet, blob: params)
         
                        break
                    default:
                        return
                    }
                    
                    break
                case "Canceled by user.":
                    self.shake()
                    self.throwEngine.alertWarning(title: "Dikkat", message: "İşleminiz iptal edilmiştir.", error: true)
                
                    //self.dismissNewSend()
                    return
                    
                case "Fallback authentication mechanism selected.":
                    self.isTouchIDCanceled = true
                    self.openPinView()
                    break
                default: break
                    
                }
                
            }
            
            self.onPinSuccess = { [self] res in
                switch res {
                case true:
                    BC.getSensitive(pin:res)
                    break
                case false:
                    if isShowSendCoinView {
                        self.shake()
                        self.throwEngine.alertWarning(title: "Hatalı Pin Kodu", message: "İşleminiz iptal edilmiştir.", error: true)
                    }
                    break
                }
                
            }
            
            
            BC.getSensitive(pin:false)
            
        }
        
        
        
    }
    
    func readAddressQR() {
        goQRScreen()
    }
     
}


extension MainScreen: PageCardViewDeleGate
{
    func cancel1(id: String) {
        fetch()
        isNewSendScreen = false
        menuView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }, completion: {_ in
            for subView in self.sendWithQRView.subviews
            { subView.removeFromSuperview() }
        })
        
        let odeme = digilira.odemeStatus.init(
            id: id,
            status: "5"
        )
        
        self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
        
    }
    func dismissNewSend1(params: PaymentModel) {
        //fetch()
        isNewSendScreen = false
        menuView.isHidden = false
        
        var name = digilira.dummyName
        
        if let f = kullanici.firstName {
            if let l = kullanici.lastName {
                name = f + " " + l
            }
        }
        
        let data = SendTrx.init(merchant: params.merchant,
                                recipient: digilira.gatewayAddress,
                                assetId: params.currency,
                                amount: params.rate,
                                fee: digilira.sponsorTokenFee,
                                fiat: params.totalPrice,
                                attachment: params.paymentModelID,
                                network: digilira.transactionDestination.domestic,
                                destination: digilira.transactionDestination.domestic,
                                products: params.products,
                                me: name,
                                blockchainFee: 0,
                                merchantId: params.user
                                
        )
        
        sendCoinNew(params: data)
        
    }
    
    func selectCoin1(params: String) {
        print(params)
    }
    
}
  
extension MainScreen: PinViewDelegate
{
    func openPinView()
    {
        closeProfileView()
        for view in sendWithQRView.subviews
        { view.removeFromSuperview() }
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        let pinView = UIView().loadNib(name: "PinView") as! PinView
        
        if isTouchIDCanceled {
            pinView.isTouchIDCanceled = true
            self.isTouchIDCanceled = false
        }
        
        if !isNewPin {
            
            if kullanici.pincode != "-1" {
                
                pinView.isEntryMode = true
            }else {
                self.throwEngine.alertWarning(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", error: false)
                
                pinView.isInit = true
            }
        }else {
            
            if kullanici.pincode != "-1" {
                pinView.isEntryMode = false
                pinView.isUpdateMode = true
            }else{
                self.throwEngine.alertWarning(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", error: false)
                
                pinView.isInit = true
            }
            
        }
        pinView.setCode()
        
        pinView.delegate = self
        pinView.frame = CGRect(x: 0,
                               y: 0,
                               width: sendWithQRView.frame.width,
                               height: sendWithQRView.frame.height)
        sendWithQRView.addSubview(pinView)
        sendWithQRView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
    }
    
    func pinSuccess(res: Bool) {
        self.onPinSuccess!(res)
    }
    
    func closePinView() {
        curtain.isHidden = true

        self.isPinEntered = true
        self.onB!()


        
        if isSeedScreen {
            isSeedScreen = false
            return
        }
        
        if isBitexenAPI {
            isBitexenAPI = false
            return
        }
        
        if isNewSendScreen {
            isNewSendScreen = false
            walletOperationView.isUserInteractionEnabled = true
//            goNewSendView()
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }, completion: {_ in
            for subView in self.sendWithQRView.subviews
            { subView.removeFromSuperview() }
        })

        menuView.isHidden = false
        
        
    }
    
    func updatePinCode (code:Int32) {
        let user = digilira.pin.init(
            pincode:code
        )
        
        digiliraPay.onResponse = { res, sts in
            DispatchQueue.main.async {
                self.throwEngine.alertWarning(title: "Pin Kodu Güncellendi", message: "Pin kodunuzu unutmayın, cüzdanınızı başka bir cihaza aktarırken ihtiyacınız olacaktır.", error: false)
                
                self.profileMenuView.pinWarning.isHidden = true
                self.digiliraPay.onLogin2 = { user, status in
                    DispatchQueue.main.sync {
                        self.kullanici = user
                    }
                }
                
                self.digiliraPay.login2()
            }
        }
        
        digiliraPay.request2(rURL: digiliraPay.getApiURL() + digilira.api.userUpdate, JSON: try? digiliraPay.jsonEncoder.encode(user), METHOD: digilira.requestMethod.put, AUTH: true)
    }
}

extension MainScreen: ProfileSettingsViewDelegate
{
    func dismissProfileMenu() // profil ayarlarının kapatılması
    {
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.frame.origin.y = self.view.frame.height
        }) { (_) in
            
        }
    }
}

extension MainScreen: LoadCoinDelegate
{
    func dismissLoadView() // para yükleme sayfasının gizlenmesi
    {
        isShowLoadCoinView = false
        sendMoneyBackButton.isHidden = true
        dismissKeyboard()
        UIView.animate(withDuration: 0.3, animations: {
            self.qrView.frame.origin.y = self.view.frame.height
        }, completion: {_ in
            for subView in self.qrView.subviews
            { subView.removeFromSuperview() }
        })
        
        menuView.isHidden = false
    }
    
    func shareQR(image: UIImage?) {
        popup(image: image)
    }
    
}

extension MainScreen: ErrorsDelegate {
    func removeAlert() {
        throwEngine.removeAlert()
    }
    
    func removeWait() {
        throwEngine.removeWait()
    }
    
    func waitPlease() {
        throwEngine.waitPlease()
    }
    
    func evaluate(error: digilira.NAError) {
        self.dismissKeyboard()
        throwEngine.evaluateError(error: error)
    }
    
    func transferConfirmation(txConMsg: digilira.txConfMsg, destination: NSNotification.Name) {
        
            self.dismissKeyboard()
            throwEngine.transferConfirmation(txConMsg: txConMsg, destination: destination)
    }
    
    func errorCaution(message: String, title: String) {
        
            self.dismissKeyboard()
            throwEngine.alertCaution(title: title, message: message)
    }
    
    func errorHandler(message: String, title: String, error: Bool) {
        self.dismissKeyboard()
        throwEngine.alertWarning(title: title, message: message, error: error)
    }
     
     
}

extension MainScreen: VerifyAccountDelegate
{
    func removeWarning() {
    }
    
    func uploadImage() {
        isProfileImageUpload = true
        openGallery()
    }
    
    func disableEntry() {
        DispatchQueue.main.async {
            self.profileMenuView.verifyProfileView.alpha = 0.5
            self.profileMenuView.verifyProfileView.isUserInteractionEnabled = false
        }
    }
    
    func enableEntry(user:digilira.auth) {
        DispatchQueue.main.async {
            self.kullanici = user
            self.profileMenuView.verifyProfileView.alpha = 1
            self.profileMenuView.verifyProfileView.isUserInteractionEnabled = true
            if user.status != 0 {
                self.profileMenuView.profileWarning.image = UIImage(named: "success")
            }
        }


    }
    
    func dismissVErifyAccountView() // profil doğrulama sayfasının kapatılması
    {
        if kullanici.status != 0 {
            self.profileMenuView.profileWarning.image = UIImage(named: "success")
        }
                
        if QR.address != nil {
            UserDefaults.standard.set(nil, forKey: "QRARRAY2")
            getOrder(address: self.QR)
            self.QR = digilira.QR.init()
            
        }
        dismissKeyboard()
        do {
            try self.kullanici = secretKeys.userData()
        } catch {
            print(error)
        }
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.3) {
                self.qrView.frame.origin.y = self.view.frame.height
                self.qrView.alpha = 0
            }
            menuView.isHidden = false
            bottomView.isHidden = false
            isVerifyAccount = false
            
        }
    }
}



extension MainScreen: LegalDelegate // kullanım sözleşmesi gibi view'ların gösterilmesi
{
    func showLegal(mode: digilira.terms)
    {
        profileSettingsView.frame.origin.y = 0
        profileSettingsView.frame.origin.x = 0 - view.frame.height
        let legalXib = UIView().loadNib(name: "LegalView") as! LegalView
        legalXib.delegate = self
        legalXib.frame = CGRect(x: 0,
                                y: 0,
                                width: profileSettingsView.frame.width,
                                height: profileSettingsView.frame.height)
        
        
        legalXib.titleLabel.text = mode.title
        legalXib.contentLabel.text = mode.text
        legalXib.setView()
        for subView in profileSettingsView.subviews
        { subView.removeFromSuperview() }
        
        profileSettingsView.addSubview(legalXib)
        closeProfileView()
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.alpha = 1
            self.profileSettingsView.frame.origin.x = 0
            self.profileSettingsView.frame.origin.y = 0
        }) { (_) in
            
        }
    }
    
    func dismissLegalView()
    {
        checkEssentials()
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.frame.origin.x = 0 - self.view.frame.width
        }, completion: { [self]_ in
            for subView in profileSettingsView.subviews
            { subView.removeFromSuperview() }
        })
    }
}


extension MainScreen: PaymentCatViewsDelegate {
    func dismiss() {
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.frame.origin.y = self.view.frame.height
        }) { (_) in
            
        }    }
    func passData(data: String) {
        
        switch data {
        case "Bitexen":
            showBitexenView()
        case "Okex":
            throwEngine.alertWarning(title: "Yapım Aşamasında", message: "OKEX API bağlantısı yapım aşamasındadır.", error: true)
        default:
            break
        }
        print(data)
    }
}


extension MainScreen: LetsStartSkipDelegate {
    func skipTap() {
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
        }
    }
    
    func dogrula() {
        UserDefaults.standard.set(true, forKey: "seedRecovery")
        profileMenuView.seedBackupWarning.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
        }
    }
  
    
    
}


extension MainScreen: SendWithQrDelegate
{
    func sendWithQRError(error: Error) {
        self.throwEngine.evaluateError(error: error)
    }
    
    func dismissSendWithQr(url: String)
    {
        if (url != "") {
            OpenUrlManager.onURL = { [self] res in
                getOrder(address: res)
            }
            OpenUrlManager.parseUrlParams(openUrl: URL(string: url))
        }
        
        isNewSendScreen = false
        isShowQRButton = false
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
            self.menuView.isHidden = false
        }
    }
    
    func alertError () {
        let alert = UIAlertController(title: digilira.messages.profileUpdateHeader, message: digilira.messages.profileUpdateMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Güncelle", style: .default, handler: { action in
            self.verifyProfile()
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}


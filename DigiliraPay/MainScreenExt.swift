//
//  MainScreenExt.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 20.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


extension MainScreen: SeedBackupDelegate
{
    func dismissSeedBackup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }, completion: {_ in
            for subView in self.sendWithQRView.subviews
            { subView.removeFromSuperview() }
        })
    }
    
    func seedBackedUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }, completion: { [self]_ in
            for subView in self.sendWithQRView.subviews
            { subView.removeFromSuperview() }
            throwEngine.alertWarning(title: "Yedekleme Tamamlandı", message: "Anahtar kelimeleriniz başarıyla yedeklendi.", error: false)
            UserDefaults.standard.set(true, forKey: "seedRecovery")
            checkEssentials()
        })
    }
    
    func alertSomething(title: String, message: String) {
        throwEngine.alertCaution(title: title, message: message)
    }
    
}

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
    
    func sendCoinNew(params:SendTrx)
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
                    case Constants.transactionDestination.domestic, Constants.transactionDestination.unregistered:
                        
                        switch params.network {
                        case "bitexen":
                            //TODO - BC.sendBitexen()
                            
                            if let api = decodeDefaults(forKey: digiliraPay.returnBexChain(), conformance: BexSign.bitexenAPICred.self) {
                                if (api.valid) { // if bitexen api valid
                                    
                                    //let double = Double(truncating: pow(10,8) as NSNumber)
                                    
                                    //bitexenSign.makePayment(payment: p, keys: api)

                                    isBitexenFetched = false
                                }else {
                                    isBitexenFetched = true //is bex not valid do not wait
                                    isBitexenReload = true
                                }
                            }else {
                                isBitexenFetched = true //is bex not valid do not wait
                                isBitexenReload = true
                            }
                            
                            break
                        default:
                            BC.sendTransaction2(name: params.merchant!, recipient: params.recipient!, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment, wallet:wallet, blob: params)
                        }
                        break
                    case Constants.transactionDestination.foreign:
                        
                        if params.network == Constants.wavesNetwork {
                            BC.sendTransaction2(name: params.merchant!, recipient: params.recipient!, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment, wallet:wallet, blob: params)
                        } else {
                            BC.createWithdrawRequest(wallet: wallet,
                                                     address: params.externalAddress!,
                                                     currency: params.assetId!,
                                                     amount: params.amount!,
                                                     blob: params)
                        }
                        

                        break
                    case Constants.transactionDestination.interwallets:
                        BC.sendTransaction2(name: params.merchant!, recipient: params.recipient!, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment, wallet:wallet, blob: params)
                         
                        break
                    default:
                        return
                    }
                    
                    break
                case "Canceled by user.":
                    view.shake()
                    self.throwEngine.alertWarning(title: "Dikkat", message: "İşleminiz iptal edilmiştir.", error: true)
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
                        view.shake()
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
    }
    
    func dismissNewSend1(params: PaymentModel, network: String) {
        //fetch()
        isNewSendScreen = false
        menuView.isHidden = false
        
        var name = Constants.dummyName
        
        if let f = kullanici.firstName {
            if let l = kullanici.lastName {
                name = f + " " + l
            }
        }
        let data = SendTrx.init(merchant: params.merchant,
                                recipient: BC.returnGatewayAddress(),
                                assetId: params.currency,
                                amount: params.rate,
                                fee: Constants.sponsorTokenFee,
                                fiat: params.totalPrice,
                                attachment: params.paymentModelID,
                                network: network,
                                destination: Constants.transactionDestination.domestic,
                                products: params.products,
                                me: name,
                                blockchainFee: 0,
                                merchantId: params.user,
                                feeAssetId: Constants.paymentToken
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
        
        do {
            let k: Constants.auth = try secretKeys.userData()
            
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
                
                if k.pincode != "-1" {
                    
                    pinView.isEntryMode = true
                }else {
                    self.throwEngine.alertWarning(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", error: false)
                    
                    pinView.isInit = true
                }
            }else {
                
                if k.pincode != "-1" {
                    pinView.isEntryMode = false
                    pinView.isUpdateMode = true
                }else{
                    self.throwEngine.alertWarning(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", error: false)
                    
                    pinView.isInit = true
                }
                
            }
            pinView.setCode()
            
            pinView.errors = self
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
        } catch {
            throwEngine.evaluateError(error: Constants.NAError.emptyAuth)
        }
        
    }
    
    func pinSuccess(res: Bool) {
        self.onPinSuccess!(res)
    }
    
    func checkBlock() {
        curtain.isHidden = false
        checkIfBlocked()
    }
    
    func blockUser () {
        UserDefaults.standard.setValue(false, forKey: "isSecure")
        throwEngine.alertWarning(title: "Hesabınız Bloke Edildi", message: "Pin kodunuzu sıfırlamak için www.digilirapay.com/pin adresini ziyaret ediniz.", error: true)
        
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000

        if let sign = try? BC.bytization([kullanici.id, 403000.description], timestamp) {
            let user = Constants.exUser.init(
                id: kullanici.id,
                wallet: sign.wallet,
                status: 403000,
                signed: sign.signature,
                publicKey: sign.publicKey,
                timestamp: timestamp
            )
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(user)
            digiliraPay.updateUser(user: data, signature: sign.signature)
        }
    }
    
    func closePinView() {
        
        
        self.isPinEntered = true
        self.onBalancesReady!()
        
        
        
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
    
    func updatePinCode (code:String) {
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
 
        do {
            let u = try secretKeys.userData()
            
            if let sign = try? BC.bytization([u.apnToken,
                                              u.btcAddress ?? "",
                                              u.dogum ?? "",
                                              u.ethAddress ?? "",
                                              u.firstName ?? "",
                                              u.lastName ?? "",
                                              u.ltcAddress ?? "",
                                              u.mail ?? "",
                                              code.description,
                                              u.status.description,
                                              u.tcno ?? "", u.tel ?? "",
                                              u.tetherAddress ?? ""
            ], timestamp) {
                let user = Constants.exUser.init(firstName: u.firstName,
                                                 lastName: u.lastName,
                                                 tcno: u.tcno,
                                                 dogum: u.dogum,
                                                 tel: u.tel,
                                                 mail: u.mail,
                                                 btcAddress: u.btcAddress,
                                                 ethAddress: u.ethAddress,
                                                 ltcAddress: u.ltcAddress,
                                                 tetherAddress: u.tetherAddress,
                                                 wallet: sign.wallet,
                                                 status: u.status,
                                                 pincode: code.description,
                                                 apnToken: u.apnToken,
                                                 signed: sign.signature,
                                                 publicKey: sign.publicKey,
                                                 timestamp: timestamp
                )
              
                crud.onResponse = { data, sts in
                    DispatchQueue.main.async { [self] in
                        if sts == 200 {
                            if digiliraPay.validateUser(user: data) {
                                isInformed = true
                                if secretKeys.LocksmithSave(forKey: try! BC.getKeyChainSource().authenticateData, data: data) {
                                    self.throwEngine.alertWarning(title: "Pin Kodu Güncellendi", message: "Pin kodunuzu unutmayın, cüzdanınızı başka bir cihaza aktarırken ihtiyacınız olacaktır.", error: false)
                                    
                                    self.profileMenuView.pinWarning.isHidden = true
                                    self.checkEssentials()
                                } else {
                                    throwEngine.evaluateError(error: Constants.NAError.E_500)
                                }
                            }

                        }
                    }
                }
                crud.request(rURL: crud.getApiURL() + Constants.api.userUpdate, postData: try? JSONEncoder().encode(user), method: req.method.put, signature: sign.signature)

            }
        } catch {
            print(error)
        }
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
    
    func evaluate(error: Constants.NAError) {
        self.dismissKeyboard()
        throwEngine.evaluateError(error: error)
    }
    
    func transferConfirmation(txConMsg: Constants.txConfMsg, destination: NSNotification.Name) {
        
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
     
    func uploadIdentity() {
        isIdentityUpload = true
        isProfileImageUpload = true
        openGallery()
    }
    
    func disableEntry() {
        DispatchQueue.main.async {
            self.profileMenuView.verifyProfileView.alpha = 0.5
            self.profileMenuView.verifyProfileView.isUserInteractionEnabled = false
        }
    }
    
    func loadEssentials() {
        DispatchQueue.main.async {
            self.checkEssentials()
        }
    }
    
    func enableEntry(user:Constants.auth) {
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
            self.QR = Constants.QR.init()
            
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
    func showLegal(mode: Constants.terms)
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
        legalXib.contentText.text = mode.text
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
    
    func warnUser() {
        throwEngine.alertWarning(title: "Dikkat", message: "Ekran görüntüsü alarak anahtar kelimeleri yedeklemeniz durumunda, anahtar kelimeleriniz sizden başka birisinin eline geçebilir ve kripto paralarınızı kaybedebilirsiniz. Lütfen daha güvenli bir yedekleme metodu gerçekleştiriniz.")
    }
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
            OpenUrlManager.notSupportedYet = { [self] res, network in
                if !res {
                    throwEngine.alertWarning(title: "Geçersiz Cüzdan", message: "Cüzdan adresi geçersiz veya desteklenmemektedir.")
                } else {
                    throwEngine.alertCaution(title: network, message: network + " blokzinciri henüz desteklenmemektedir.")
                }
            }
            
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
        let alert = UIAlertController(title: Constants.messages.profileUpdateHeader, message: Constants.messages.profileUpdateMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Güncelle", style: .default, handler: { action in
            self.verifyProfile()
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}


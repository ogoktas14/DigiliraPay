//
//  MainScreen.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 25.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
//import IQKeyboardManagerSwift

import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions
import RxSwift
import Locksmith
import Foundation
import Wallet
import UserNotifications
import Photos

public let kNotification = Notification.Name("kNotification")


class MainScreen: UIViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var profileView: UIView!
    //@IBOutlet weak var profileMenuButton: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var homeAmountLabel: UILabel!
    @IBOutlet weak var profileSettingsView: UIView!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var accountButton: UIImageView!
    @IBOutlet weak var headerInfoLabel: UILabel!
    @IBOutlet weak var sendMoneyBackButton: UIImageView!
    @IBOutlet weak var sendWithQRView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var emptyBG: UIImageView!
    @IBOutlet weak var curtain: UIView!

    @IBOutlet var mainView: UIView!
    var profileViewXib: ProfileMenuView = ProfileMenuView()
    
    let lang = Localize()

    var warningView = WarningView()
    var orderDetailView = OrderDetailView()
    var contentScrollView = UIScrollView()
    var coinTableView = UITableView()
    var walletOperationView = WalletOperationButtonSView()
    var walletView: WalletView = WalletView()
    var menuXib: MenuView = MenuView()
    var seedView = Verify_StartView()
    var paymentCat = PaymentCat()
    var profileMenuView = ProfileMenuView()
    let imagePicker = UIImagePickerController()
    var newSendMoneyView = newSendView()
    var commissionsView = CommissionsView()

    var pageCardView = PageCardView()
    var paraYatirView = ParaYatirView()
    var bitexenAPIView = BitexenAPIView()
    var headerExitView = HeaderExitView()

    var tapProfileMenuGesture = UITapGestureRecognizer()
    var tapCloseProfileMenuGesture = UITapGestureRecognizer()
    
    var isShowProfileMenu = false
    var isShowWallet = false
    var isShowSendCoinView = false
    var isShowSettings = false
    var isShowQRButton = false
    var isShowLoadCoinView = false
    var isSuccessView = false
    var isSeedScreen = false
    var isPayments = false
    var isHomeScreen = false

    var isNewSendScreen = false
    var isBitexenAPI = false
    var isVerifyAccount = false
    
    var isBitexenFetched = false
    var isBinanceFetched = false
    var isPinEntered = false
    
    var isBitexenReload = false
    var isBinanceReload = false
    var isWavesReloaded = false
    var isHomeTapped = false

    var isWalletOperationLoaded = false
    
    var isFetching = false
    var headerAnimation = false
    var isInformed = false
    
    var lastBitexenCheck: Date = Date()
    var lastBinanceCheck: Date = Date()
    
    var isKeyboard = false
    
    var ethAddress: String?
    var btcAddress: String?
    var ltcAddress: String?
    var wavesAddress: String?
    
    var coinSymbol: String?
    var selectedCoin : String?
    var network : String?
    
    var totalBalance: Double = 0.0
    var bitexenBalance: Double = 0.0

    private let refreshControl = UIRefreshControl()
        
    var isAlive = false
    var isNewPin = false
    var isFirstLaunch = true
    var isTouchIDCanceled = false
    var isProfileImageUpload:Bool = false
    var isIdentityUpload:Bool = false

    var walletOperationsViewOrigin = CGPoint(x: 0, y: 0)
    
    var kullanici: digilira.auth = try! secretKeys.userData()
    var pinkodaktivasyon: Bool? = false
    
    var Balances: NodeService.DTO.AddressAssetsBalance?
    var Ticker: binance.BinanceMarketInfo = []
    var Filtered: [digilira.DigiliraPayBalance] = []
    
    var tableViewFiltered: [digilira.DigiliraPayBalance] = []
        
    var Bitexen: [digilira.DigiliraPayBalance] = []
    var Waves: [digilira.DigiliraPayBalance] = []
    
    var BitexenBalances:[bex.BalanceValue?] = []
    
    var bexTicker: bex.bexAllTicker?
    var bexMarketInfo: bex.bexMarketInfo?
    
    var onPinSuccess: ((_ result: Bool)->())?
    var onB: (()->())?
    var onMessage: ((_ result: Bool)->())?

    
    var headerHeightBuffer: CGFloat?
    var headerHomeBuffer: CGFloat?
    
    var QR:digilira.QR = digilira.QR.init()
    
    let defaults = UserDefaults.standard
    
    let BC = Blockchain()
    let bitexenSign = bex()
    let binanceAPI = binance()
    let throwEngine = ErrorHandling()
    
    let digiliraPay = digiliraPayApi()
    var crud = centralRequest()

    func checkEssentials() {
        
        let isT = BC.returnEnv()
        
        do {
            let k = try secretKeys.userData()
            kullanici = k
             
            if k.status == 403000 {
                checkIfBlocked()
            }
            
            if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
                if selfied {
                    checkStatus()
                }
            }
            
            BC.onWavesDataResponse = { [self] res, sts in
                switch sts {
                case 200:
                    
                    do {
                        let dataKey = try crud.decodeDefaults(forKey: res, conformance: WavesDataTransaction.self)
                        var serial: Data;
                        if #available(iOS 13.0, *) {
                            serial = dataKey.value.data!
                            let isauthorized = try crud.decodeDefaults(forKey: serial, conformance: Int.self)
                            
                            DispatchQueue.main.async {
                                if isT == "mainnet" {
                                    if isauthorized != 299 {
                                        profileMenuView.mnet.isHidden = true
                                    }
                                }
                            }
                            
                            UserDefaults.standard.set(isauthorized, forKey: "isAuthorized")
                        } else {
                            // Fallback on earlier versions
                            let str = String(describing: dataKey.value)
                            let data = str.components(separatedBy: "integer(")
                            let data2 = data[1].components(separatedBy: ")")
                            
                            DispatchQueue.main.async {
                                if isT == "mainnet" {
                                    if data2[0] != "299" {
                                        profileMenuView.mnet.isHidden = true
                                    }
                                }
                            }
                            
                            UserDefaults.standard.set(data2[0], forKey: "isAuthorized")
                        }
                        

 
                    } catch {
                        print(error)
                    }
                default:
                    throwEngine.evaluateError(error: digilira.NAError.anErrorOccured)
                }
            }
            
            BC.getDataTrx(key: k.wallet)
            
            if let deviceToken = UserDefaults.standard.value(forKey: "deviceToken") as? String
            {
                if deviceToken != "" {
                    if k.apnToken != deviceToken {
                        
                        digiliraPay.onUpdate = { [self] res, sts in
                            if let user = res {
                                userStatus(user: user)
                            }
                        }
                        
                        let timestamp = Int64(Date().timeIntervalSince1970) * 1000

                        do {
                            let sign = try BC.bytization([deviceToken], timestamp)
                                let user = digilira.exUser.init(
                                    wallet: sign.wallet,
                                    apnToken: deviceToken,
                                    signed: sign.signature,
                                    publicKey: sign.publicKey,
                                    timestamp: timestamp
                                )
                                  
                            digiliraPay.updateUser(user: try JSONEncoder().encode(user), signature: sign.signature)
                        } catch { print(error) }
                    }
                }
            }
            
            if let versionLegal = UserDefaults.standard.value(forKey: "isLegalView") as? Int {
                let v = digilira.legalView.version
                if (versionLegal < v) {
                    isInformed = true
                    profileMenuView.legalViewWarning.isHidden = false
                    showLegalText()
                } else {
                    profileMenuView.legalViewWarning.isHidden = true
                }
            }
            
            if let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse") as? Int {
                let v = digilira.termsOfUse.version
                if (versionTerms < v) {
                    isInformed = true
                    profileMenuView.termsViewWarning.isHidden = false
                    showTermsofUse()
                }else {
                    profileMenuView.termsViewWarning.isHidden = true
                }
            }
            
            if let isVerified = UserDefaults.standard.value(forKey: "seedRecovery") as? Bool {
                if isVerified {
                    profileMenuView.seedBackupWarning.isHidden = true
                }
            }
            
            switch k.status {
            case 0:
           
                profileMenuView.profileWarning.image = UIImage(named: "warning")
                break
            case 1:
   
                profileMenuView.profileWarning.image = UIImage(named: "success")
                break
            case 2:
          
                profileMenuView.profileWarning.image = UIImage(named: "success")
                break
            case 3:
       
                profileMenuView.profileWarning.image = UIImage(named: "success")
                profileMenuView.profileVerifyLabel.text = "Profilim"
                break
            default:
             
                break
            }
            
        } catch {
            print(error)
        }
    }
    
    @objc func checkIfBlocked() {
        
        digiliraPay.onUpdate = { [self] res, sts in
            if let user = res {
                userStatus(user: user)
            }
       }
        
        DispatchQueue.main.async { [self] in
            if let user = try? secretKeys.userData() {
                switch user.status {
                case 403000:
                    let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                    
                    if let sign = try? BC.bytization([user.id, 403000.description], timestamp) {
                        let user = digilira.exUser.init(
                            id: user.id,
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
                    return
                default:
                    curtain.isHidden = true
                }
                return
            }
        }
    }
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        self.headerHomeBuffer = self.headerView.frame.size.height

        coinTableView.refreshControl = refreshControl
        coinTableView.showsVerticalScrollIndicator = false
        menuView.isUserInteractionEnabled = false
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        
        self.contentView.addGestureRecognizer(swipeRight)
        self.contentView.addGestureRecognizer(swipeLeft)
        
        headerHeightBuffer =  headerView.frame.size.height 
        
        self.onB = { [self] in
            if (isBitexenReload && isWavesReloaded && isPinEntered) {
                
                if let isVerified = UserDefaults.standard.value(forKey: "seedRecovery") as? Bool {
                    if !isVerified {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                            if !isInformed {
                                isInformed = true
                                throwEngine.alertCaution(title: "Anahtar Kelimeler", message: "Anahtar kelimelerinizi sizden başka kimse bilemez. Buna biz de dahiliz. Lütfen anahtar kelimelerinizi yedekleyin. Cüzdanınızın silinmesi veya telefonunuzu değiştirmeniz durumunda bu kelimeleri kullanarak hesabınıza erişebileceksiniz. Bu uyarıyı almak istemiyorsanız yedekleme işlemini doğrulamanız gerekmektedir.")
                            }
                            
                            
                        }
                        
                    }
                }
                if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
                    QR = qr
                    self.getOrder(address: QR)
                }
                
                checkIfBlocked()
                //curtain.isHidden = true
                
                
                isBitexenReload = false
                isWavesReloaded = false
                
                Filtered.removeAll()

                Filtered.append(contentsOf: Waves)
                Filtered.append(contentsOf: Bitexen)
                
                let seperatorBalanceBitexen = digilira.DigiliraPayBalance.init(tokenName: "Seperator",
                                                                        tokenSymbol: "",
                                                                        availableBalance: 0,
                                                                        decimal: 0,
                                                                        balance: 0,
                                                                        tlExchange: 0.0,
                                                                        network: "Bitexen",
                                                                        wallet:"")
                let seperatorBalanceWaves = digilira.DigiliraPayBalance.init(tokenName: "Seperator",
                                                                        tokenSymbol: "",
                                                                        availableBalance: 0,
                                                                        decimal: 0,
                                                                        balance: 0,
                                                                        tlExchange: 0.0,
                                                                        network: "DigiliraPay",
                                                                        wallet:"")
                
                if Bitexen.count > 0 {
                    tableViewFiltered.removeAll()
                    tableViewFiltered.append(seperatorBalanceWaves)
                    tableViewFiltered.append(contentsOf: Waves)
                    tableViewFiltered.append(seperatorBalanceBitexen)
                    tableViewFiltered.append(contentsOf: Bitexen)
                } else {
                    
                    tableViewFiltered.removeAll()
                    tableViewFiltered.append(contentsOf: Waves)
                }
                

                
                self.checkHeaderExist()
            }
        }
        
        bitexenSign.onBitexenBalance = { [self] balances, statusCode in
            if statusCode == 200 {
                bitexenBalance = 0
                Bitexen.removeAll()
                for bakiye in balances.data.balances {
                    if Double(bakiye.value.balance)! > 0 {
                        if bakiye.value.currencyCode == "TRY" {
                            let lastPrice = Double(bakiye.value.availableBalance)! * 1
                            
                            let double = Double(truncating: pow(10,8) as NSNumber)
                            let digiliraBalance = digilira.DigiliraPayBalance.init(
                                tokenName: bakiye.value.currencyCode,
                                tokenSymbol: "Bitexen " + bakiye.value.currencyCode,
                                availableBalance: Int64(Double(bakiye.value.availableBalance)! * double),
                                decimal: 8,
                                balance: Int64(Double(bakiye.value.balance)! * double),
                                tlExchange: 1, network: "bitexen",
                                wallet: "")
                            
                            bitexenBalance += lastPrice

                            Bitexen.append(digiliraBalance)
                            
                            self.BitexenBalances.append(bakiye.value)
                        } else {
                            for mrkt in (bexMarketInfo?.data.markets)! {
                                if bakiye.value.currencyCode == mrkt.baseCurrency {
                                    let coinPrice = bexTicker?.data.ticker[mrkt.marketCode]
                                    let lastPrice = Double(bakiye.value.availableBalance)! * Double(coinPrice!.lastPrice)!
                                    
                                    let double = Double(truncating: pow(10,8) as NSNumber)
                                    let digiliraBalance = digilira.DigiliraPayBalance.init(
                                        tokenName: bakiye.value.currencyCode,
                                        tokenSymbol: "Bitexen " + bakiye.value.currencyCode,
                                        availableBalance: Int64(Double(bakiye.value.availableBalance)! * double),
                                        decimal: 8,
                                        balance: Int64(Double(bakiye.value.balance)! * double),
                                        tlExchange: lastPrice, network: "bitexen",
                                        wallet: "")
                                    
                                    bitexenBalance += lastPrice

                                    Bitexen.append(digiliraBalance)
                                    
                                    self.BitexenBalances.append(bakiye.value)
                                }
                            }
                        }
                       
                    }
                }
                self.isBitexenReload = true
                self.onB!()
//                self.checkHeaderExist()
                //coinTableView.reloadData()
                
            }else{
                print("error")
            }
        }
        
        BC.onAssetBalance = { [self] assets, waves in
            construct(assets: assets, waves:waves)
        }
        
        BC.onTransferTransaction = { res, t in
   
            do {
                let data = try JSONEncoder().encode(res)
                let type = try JSONDecoder().decode(TransactionType.self, from: data)
                print(type.type)
                if type.type == 4 {
                    let transaction = try JSONDecoder().decode(TransferTransactionModel.self, from: data)

                    DispatchQueue.global(qos: .background).async  {
                        self.BC.verifyTrx(txid: transaction.id, t: t)
                    }
                    
                    DispatchQueue.main.async {
                        do {
                            let value = try JSONDecoder().decode(TransferTransactionModel.self, from: res.data!)
                            self.showSuccess(mode: 1, transaction: value)

                        }catch {
                            print(error)
                        }
                    }
                    self.bottomView.isHidden = true
                    self.goHomeScreen()
                }
            }catch{
                
            }
            
            
        }
        
        BC.onVerified = { res, t in

            NotificationCenter.default.post(name: .didCompleteTask, object: nil)
            DispatchQueue.main.async {
                self.showSuccess(mode: 2, transaction: res)
            }
            
            switch res.type {
            case 11:
                return
            default:
                let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res.attachment!)!), as: UTF8.self)
                
                do {
                    let json = try JSONEncoder().encode(t)
                    self.digiliraPay.saveTransactionTransfer(JSON: json, signature: t.signed)
                } catch {
                    print(error)
                }
                
                if (attachment == "DIGILIRAPAY TRANSFER") {
                    //wallet to wallet transfer
                    return
                }
            } 
        }
        
        crud.onError = { res, sts in
            self.throwEngine.evaluateError(error: res)
        }
        
        BC.onError = { [self] res in
            if isFirstLaunch {
                loadScreen()
            }
            self.throwEngine.evaluateError(error: res)
        }
        
        bitexenSign.onBitexenError = { res, sts in
            self.throwEngine.alertWarning(title: "Bitexen API", message: "Bitexen API bilgileriniz doğrulanamadı.", error: true)
            self.isBitexenReload = true
        }
        refreshControl.alpha = 0
        refreshControl.attributedTitle = NSAttributedString(string: "Güncellemek için çekiniz..")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkStatus), name: Notification.Name(.bar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfBlocked), name: Notification.Name(.foo), object: nil)

        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCompleteTask(_:)), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrxCompleted), name: .didCompleteTask, object: nil)
         
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark{
            mainView.backgroundColor = UIColor.white
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    func userStatus(user: digilira.auth) {
        kullanici = user
        switch user.status {
        case 0,1,2:
            DispatchQueue.main.async { [self] in

                if let isBlocked = UserDefaults.standard.value(forKey: "isBlocked") as? Bool {
                    if isBlocked {
                        curtain.isHidden = true
                        closePinView()
                        isInformed = true
                        
                        UserDefaults.standard.set(false, forKey: "isBlocked")
                        self.throwEngine.alertWarning(title: "Hesabınız Aktif Edildi", message: "Hesabınız yeniden kullanıma açılmıştır. Yeni bir pin kodu ayarlayabilirsiniz.", error: false)
                    }
                } 
            }
            break
            case 3:
                DispatchQueue.main.async { [self] in
                    if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
                        if selfied {
                            UserDefaults.standard.set(false, forKey: "isSelfied")
                            self.throwEngine.alertWarning(title: "Hesabınız Onaylandı", message: "Hesabınız Onaylanmıştır", error: false)
                        }
                    } 
                }
                break
            case 403000:
                UserDefaults.standard.setValue(false, forKey: "isSecure")

                DispatchQueue.main.async { [self] in
                    UserDefaults.standard.set(true, forKey: "isBlocked")
                    throwEngine.alertWarning(title: "Hesabınız Bloke Edildi", message: "Pin kodunuzu sıfırlamak için www.digilirapay.com/pin adresini ziyaret ediniz.", error: true)
                }
                break
            default:
                break
            }
     
    }
    
    @objc func checkStatus() {
        
        digiliraPay.onUpdate = { [self] res, sts in
            if let user = res {
                userStatus(user: user)
            }
        }
        
        if let user = try? secretKeys.userData() {
            
            switch user.status {
            case 1:
                
                if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
                    if selfied {
                        throwEngine.alertWarning(title: "Hesabınız Onaylanmadı", message: "Lütfen kurallara uygun olarak yeniden görsel yükleyin.", error: true)
                        UserDefaults.standard.set(false, forKey: "isSelfied")
                    }
                }
                
                if let identity = UserDefaults.standard.value(forKey: "isIdentity") as? Bool {
                    if identity {
                        throwEngine.alertWarning(title: "Profiliniz Güncellendi", message: "Kimlik bilgileriniz doğrulandı, ancak KYC sürecini tamamlamak için kimliğinizin ön yüzü görünecek biçimde boş bir kağıda günün tarihini ve DigiliraPay yazarak Profil Onayı sayfasına yükleyin.", error: false)
                        UserDefaults.standard.set(false, forKey: "isIdentity")
                        
                    }
                }
                 
                break
          
            case 3:
                throwEngine.alertWarning(title: "Hesabınız Onaylandı", message: "Hesabınız Onaylanmıştır", error: false)
                UserDefaults.standard.set(false, forKey: "isSelfied")
                break
            default:
                let timestamp = Int64(Date().timeIntervalSince1970) * 1000

                if let sign = try? BC.bytization([user.id, user.status.description], timestamp) {
                    let user = digilira.exUser.init(
                        id: user.id,
                        wallet: sign.wallet,
                        status: user.status,
                        signed: sign.signature,
                        publicKey: sign.publicKey,
                        timestamp: timestamp
                    )
                    
                    let encoder = JSONEncoder()
                    let data = try? encoder.encode(user)
                    
                    digiliraPay.updateUser(user: data, signature: sign.signature)
                }
                return
            }
      
             
        }
         
        
    }
    
    func construct(assets: NodeService.DTO.AddressAssetsBalance, waves: NodeService.DTO.AddressBalance) {
        let ticker = digiliraPay.ticker(ticker: Ticker)
        totalBalance = 0
        Waves.removeAll()
        
        do {
            let k = try secretKeys.userData()
            
            var wallet = k.wallet
            let double = Double(truncating: pow(10,8) as NSNumber)
            let coinPrice = (ticker.wavesUSDPrice)! * (ticker.usdTLPrice)! * Double(waves.balance) / double
            
            let digiliraBalance = digilira.DigiliraPayBalance.init(
                tokenName: "Waves",
                tokenSymbol: "Waves",
                availableBalance: waves.balance,
                decimal: 8,
                balance: waves.balance,
                tlExchange: coinPrice,
                network: "waves",
                wallet: wallet)
            
            totalBalance += coinPrice
            
            Waves.append(digiliraBalance)

            for asset1 in assets.balances {
                do {
                    let asset = try BC.returnAsset(assetId: asset1.assetId)
                    var coinPrice:Double = 0
                    let double = Double(truncating: pow(10,asset.decimal) as NSNumber)
                    
                    switch asset.tokenName {
                    case "Bitcoin":
                        coinPrice = (ticker.btcUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / double
                        if let w = k.btcAddress {
                            wallet = w
                        }
                        break
                    case "Ethereum":
                        coinPrice = (ticker.ethUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / double
                        if let w = k.ethAddress {
                            wallet = w
                        }
                        break
                    case "Tether USDT":
                        coinPrice = (ticker.usdTLPrice)! * Double(asset1.balance) / double
                        if let w = k.tetherAddress {
                            wallet = w
                        }
                        break
                    default:
                        coinPrice = 1
                        break
                    }
                    
                    var ts = "XXX"
                    if let itrx = asset1.issueTransaction {
                        ts = itrx.name
                    }
                    
                    let digiliraBalance = digilira.DigiliraPayBalance.init(
                        tokenName: asset.tokenName,
                        tokenSymbol: ts,
                        availableBalance: asset1.balance,
                        decimal: asset.decimal,
                        balance: asset1.balance,
                        tlExchange: coinPrice,
                        network: "waves",
                        wallet: wallet)
                    
                    totalBalance += coinPrice
                    
                    Waves.append(digiliraBalance)
                } catch {
                    throwEngine.evaluateError(error: error)
                }
                
            }
            
            loadScreen()
        } catch  {
            throwEngine.evaluateError(error: digilira.NAError.anErrorOccured)
        }
    }
    
    func loadScreen() {
        self.isWavesReloaded = true
        self.onB!()
        //self.coinTableView.reloadData()

        self.goHomeScreen()
        
        if isFirstLaunch {
            self.setTableView()
            self.setWalletView()
            self.setPaymentView()
            self.setSettingsView()
        }
        if isFirstLaunch {
            isFirstLaunch = false
            checkEssentials()
            
        }
        
        menuView.isUserInteractionEnabled = true
        emptyBG.isHidden = true
        if isPinEntered {
            if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
                QR = qr
                self.getOrder(address: QR)
            }
        }
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
 
    @objc func onDidCompleteTask(_ sender: Notification) {

    }
    
    static func df2so(_ price: Double, digits: Int = 2) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = "."
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = ","
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = digits
  
        let res = numberFormatter.string(from: price as NSNumber)!

        return res
    }
    
    static func int2so(_ price: Int64, digits: Int) -> String{
        let double = Double(price) / Double(truncating: pow(10,digits) as NSNumber)
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = digits
        return numberFormatter.string(from: double as NSNumber)!
    }
    
    static func decimal2Int64(_ price: Double, digits: Int = 8) -> Int64{
        let double = Int64(Double(price) * Double(truncating: pow(10,digits) as NSNumber))
        return double
    }
    
    func setHeaderTotal() {

        if headerAnimation {
            return
        }
        coinTableView.reloadData()
        headerAnimation = true
        let walletY = walletOperationView.frame.origin.y
        
        walletOperationView.frame.origin.y = 0
        walletOperationView.alpha = 0
        var bakiye = MainScreen.df2so(totalBalance + bitexenBalance)
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
 
            logoView.isHidden = false
            
            walletOperationView.frame.origin.y = walletY
            walletOperationView.alpha = 1
        }, completion: { [self]_ in
            let numChars = bakiye.count
            if numChars > 11 {
                let w = bakiye.split(separator: ",")
                bakiye = String(w[0])
            }
            self.walletOperationView.blnx = "₺" + bakiye
            self.headerAnimation = false
                if !isHomeScreen {
                    self.walletOperationView.isHidden = true

                }
        })
    }
    
    func setLogoView() {
        if logoView.isHidden == false {
            return
        }
        let y = logoView.frame.origin.y
        logoView.frame.origin.y = 0
        logoView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { [self] in
                logoView.isHidden = false
            logoView.frame.origin.y = y
            logoView.alpha = 1
           
        })
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: contentView.center.x - 10, y: contentView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: contentView.center.x + 10, y: contentView.center.y))
        
        contentView.layer.add(animation, forKey: "position")
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if (isSuccessView) {
                shake()
                return
            }
            
            switch swipeGesture.direction {
            case .right:
                if (isHomeScreen) {
                    shake()
                    return
                }
                if (isPayments) {
                    goWalletScreen(coin: "")
                    return
                }
                if (isShowWallet) {
                    goHomeScreen()
                    return
                }
                if (isShowSettings) {
                    goPayments()
                    return
                }
            case .left:
                if (isShowWallet) {
                    goPayments()
                    return
                }
                if (isPayments) {
                    goSettings()
                    return
                }
                if (isHomeScreen) {
                    goWalletScreen(coin: "")
                    return
                }
                if (isShowSettings) {
                    shake()
                    return
                }
            default:
                break
            }
        }
    }
    
    func getOrder(address: digilira.QR) {
                 
        guard let adres = address.address else { return }
        
        if address.network == "digilirapay" {
            crud.onResponse = { [self] data, sts in
                DispatchQueue.main.async {
                    switch sts {
                    case 200:
                        do {
                            let pm = try crud.decodeDefaults(forKey: data, conformance: PaymentModel.self)
                            
                            if pm.status == 2 {
                                self.errorCaution(message: "Bu ödeme kodu daha önce kullanılmış. Lütfen yeni bir QR kod okutunuz.", title: "Hatalı QR Kod")
                            } else {
                                self.goPageCardView(ORDER: pm)
                            }
                        } catch {
                            print(error)
                            self.evaluate(error: digilira.NAError.anErrorOccured)
                        }
                        break
                        
                    case 400:
                        do {
                            let pm = try crud.decodeDefaults(forKey: data, conformance: digilira.NodeError.self)
                            self.throwEngine.alertCaution(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: pm.message)
                             
                        } catch {
                            print(error)
                            self.evaluate(error: digilira.NAError.anErrorOccured)
                        }
                        break
                        
                    default:
                        break
                    }

                }
            }
            do {
                
                if kullanici.pincode == "-1" {
                    openPinView()
                    return
                }
                
                let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                
                let sign = try BC.bytization(["payment", adres, kullanici.id], timestamp)
                
                let data = digilira.transferGetModel.init(mode: "payment",
                                                          user: kullanici.id,
                                                          transactionId: adres,
                                                          signed: sign.signature,
                                                          publicKey: sign.publicKey,
                                                          timestamp: timestamp,
                                                          wallet: sign.wallet)
                
                crud.request(rURL: crud.getApiURL() + digilira.api.transferGet, postData: try JSONEncoder().encode(data), signature: sign.signature)
            } catch {
                self.evaluate(error: digilira.NAError.anErrorOccured)
            }
        } else {
            do {
                let token = try BC.returnAsset(assetId: address.network)
                switch address.network {
                case digilira.bitcoinNetwork:
                    let external = digilira.externalTransaction(network: address.network, address: address.address, amount: address.amount, message: address.address!, assetId:token.token)
                    sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                    break
                case digilira.wavesNetwork:
                    let external = digilira.externalTransaction(network: address.network,
                                                                address: address.address,
                                                                amount: address.amount,
                                                                message: address.address!,
                                                                assetId: address.assetId!)
                    sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                    break
                case digilira.ethereumNetwork:
                    let external = digilira.externalTransaction(network: address.network,
                                                                address: address.address,
                                                                amount: address.amount,
                                                                message: address.address!,
                                                                assetId:token.token)
                    sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                    break
                default:
                    break
                }
            } catch  {
                print(error)
            }
            
        }
         
        }
       
    @objc func onDidReceiveData(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        
        if isPinEntered {
            if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
                QR = qr
                self.getOrder(address: QR)
            }
            
            self.throwEngine.warningView.removeFromSuperview()
        }
         
        if isVerifyAccount {
            self.dismissVErifyAccountView()
        }
        
    }
    
    @objc func onTrxCompleted(_ sender: Notification) {
        // Do what you need, including updating IBOutlets

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboard {
            isKeyboard = true
            if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                //self.view.frame.origin.y -= 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboard = false
        self.view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [self] in
            refreshControl.endRefreshing()
        }
        if isSuccessView {
            refreshControl.endRefreshing() // dogrulama ekraninda guncelleme yapilmasin
            return
        }
        let lamda = Date()
        let differenceInSeconds = lamda.timeIntervalSince(lastBinanceCheck)
        
        if differenceInSeconds > 2  {
            fetch()
            lastBinanceCheck = lamda
        } else {
            refreshControl.endRefreshing() // dogrulama ekraninda guncelleme yapilmasin
        }
        
    }
    
    func decodeDefaults<T>(forKey: String, conformance: T.Type, setNil: Bool = false ) -> T? where T: Decodable  {
        if let savedAPI = defaults.object(forKey: forKey) as? Data {
            let decoder = JSONDecoder()
            let loadedAPI = try? decoder.decode(conformance.self, from: savedAPI)
            
            if setNil {
                defaults.set(nil, forKey: forKey)
            }
            return loadedAPI!
        }
        return nil
    }
    
    func fetch() {
        if isFetching {
            
        }
        
        isFetching = true
        if isPinEntered {
            throwEngine.waitPlease()
        }
        
        if let api = decodeDefaults(forKey: digiliraPay.returnBexChain(), conformance: bex.bitexenAPICred.self) {
            if (api.valid) { // if bitexen api valid
                bitexenSign.onBitexenMarketInfo = { [self] res, sts in
                    if sts == 200 {
                        bexMarketInfo = res
                        bitexenSign.onBitexenTicker = { [self] res, sts in
                            if sts == 200 {
                                bexTicker = res
                                bitexenSign.getBalances(keys: api)
                                isBitexenFetched = true
                                self.endRefresh()
                            }else{
                                print("error")
                            }
                        }
                    }else{
                        print("error")
                    }
                    bitexenSign.getTicker()
                }
                bitexenSign.getMarketInfo()
                isBitexenFetched = false
            }else {
                isBitexenFetched = true //is bex not valid do not wait
                isBitexenReload = true
            }
        }else {
            isBitexenFetched = true //is bex not valid do not wait
            isBitexenReload = true
        }
        
        binanceAPI.onBinanceError = { res, sts in
            print("error")
        }
        
        binanceAPI.onBinanceTicker = { res, sts in
            self.Ticker = res
            self.BC.checkAssetBalance(address: self.kullanici.wallet)
            self.isBinanceFetched = true
            self.endRefresh()
        }
        binanceAPI.getTicker()
        
        self.isBinanceFetched = false
    }
    
    func endRefresh() {
        throwEngine.removeWait()
        if isBitexenFetched && isBinanceFetched {
            self.isBinanceFetched = false
            self.isBitexenFetched = false
            self.isFetching = false
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadMenu()
        
        headerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.4
        headerView.layer.shadowOffset = .zero
        headerView.layer.shadowRadius = 3
        
        contentView.layer.zPosition = -1
        
        tapProfileMenuGesture = UITapGestureRecognizer(target: self, action: #selector(openProfileView))
        tapCloseProfileMenuGesture = UITapGestureRecognizer(target: self, action: #selector(closeProfileView))
        let accountTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAccountButton))
        accountButton.addGestureRecognizer(accountTapGesture)
        accountButton.isUserInteractionEnabled = true
        
        //profileMenuButton.isUserInteractionEnabled = true
        //profileMenuButton.addGestureRecognizer(tapProfileMenuGesture)
        view.addGestureRecognizer(tapCloseProfileMenuGesture)
        
        tapCloseProfileMenuGesture.isEnabled = false
        
        let tapProfileMenuViewGesture = UITapGestureRecognizer(target: self, action: #selector(tapProfileMenuView))
        menuView.addGestureRecognizer(tapProfileMenuViewGesture)
        
        let closeSendCoinViewGesture = UITapGestureRecognizer(target: self, action: #selector(closeSendView))
        //let closeLoadCoinViewGesture = UITapGestureRecognizer(target: self, action: #selector(closeSendView))
        sendMoneyBackButton.addGestureRecognizer(closeSendCoinViewGesture)
        //sendMoneyBackButton.addGestureRecognizer(closeLoadCoinViewGesture)
        sendMoneyBackButton.isUserInteractionEnabled = true
        
        profileView.translatesAutoresizingMaskIntoConstraints = true
        profileView.center.x = -profileView.frame.width / 2
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        openPinView()
        setScrollView()
        headerView.translatesAutoresizingMaskIntoConstraints = true
        profileSettingsView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func setScrollView() // Ana sayfadaki içeriklerin gösterildiği scrollView
    {
        contentScrollView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: contentView.frame.width,
                                         height: contentView.frame.height)
        
        contentScrollView.isScrollEnabled = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        if (contentView.subviews.count > 0) {
            contentView.willRemoveSubview(contentView.subviews[0])
        }
        contentView.addSubview(contentScrollView)
        
        fetch()
    }
    
    func setTableView() // ana sayfa coinler tableview, paralar burada listeleniyor
    {
        coinTableView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: contentView.frame.width,
                                     height: contentView.frame.height)
        coinTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        coinTableView.delegate = self
        coinTableView.dataSource = self
        coinTableView.separatorColor = .gray
        coinTableView.tableFooterView = GradientView()
        contentScrollView.addSubview(coinTableView)
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
        
    }
    
    func setWalletView() // Wallet ekranı detayları aşağıda
    {
        walletView = UIView().loadNib(name: "WalletView") as! WalletView
        walletView.frame = CGRect(x: contentView.frame.width,
                                  y: 0,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height)
        
        walletView.wallet = kullanici.wallet
        
        walletView.ad_soyad = getName()
        //walletView.layer.zPosition = 0
        
        walletView.frameValue = walletView.frame
        walletView.setView()
        walletView.ViewOriginMaxXValue.y = menuView.frame.height
        contentScrollView.addSubview(walletView)
        
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
    }
    
    func setSettingsView() {
        profileMenuView = UIView().loadNib(name: "ProfileMenuview") as! ProfileMenuView
        profileMenuView.frame = CGRect(x: contentView.frame.width * 3,
                                       y: 0,
                                       width: contentView.frame.width,
                                       height: contentView.frame.height)
        
        if kullanici.pincode != "-1" {
            profileMenuView.pinWarning.isHidden = true
        }
        
        if kullanici.status != 0 {
            profileMenuView.profileWarning.image = UIImage(named: "success")
        }
        
        profileMenuView.layer.zPosition = 1
        profileMenuView.delegate = self
        
        profileMenuView.frameValue = walletView.frame
        profileMenuView.setView()
        profileMenuView.ViewOriginMaxXValue.y = menuView.frame.height
        contentScrollView.addSubview(profileMenuView)
        
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
    }
    
    func getName() -> String {
        var name: String = digilira.dummyName
        
        do {
            let k = try secretKeys.userData()
            if let n = k.firstName {
                name = n
                if let s = k.lastName {
                    name = n + " " + s
                }
            }
        }catch{
            return name
        }
        return name 
    }
    
    func setPaymentView() // payments ekranı
    {
        var cards: [digilira.cardData] = []
        
        var bitexen = turkish.bitexenCard
        let oneTower = turkish.oneTower
        
        if let api = decodeDefaults(forKey: digiliraPay.returnBexChain(), conformance: bex.bitexenAPICred.self) {
            bitexen.cardNumber = "Hesap Bilgilerini Düzenle"
            if (api.valid) { // if bitexen api valid
                bitexen.apiSet = true
                bitexen.cardNumber = "Hesap Aktif"
                bitexen.cardHolder = getName()
            }
        }
        
        cards.append(bitexen)
        cards.append(oneTower)
        
        if !isFirstLaunch {
            paymentCat.cards = cards
            paymentCat.setView()
        }
        
        paymentCat = UIView().loadNib(name: "PaymentCategories") as! PaymentCat
        paymentCat.cardCount = 1
        paymentCat.frame = CGRect(x: contentView.frame.width * 2,
                                  y: 0,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height)
        
        paymentCat.layer.zPosition = 1
        paymentCat.delegate = self
        paymentCat.cards = cards
        paymentCat.frameValue = walletView.frame
        paymentCat.ViewOriginMaxXValue.y = menuView.frame.height
        paymentCat.setView()
        
        contentScrollView.addSubview(paymentCat)
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
    }
    
    @objc func openProfileView() // yan profil menüsünün açılması işlemi
    {
        if !isShowProfileMenu
        {
            isShowProfileMenu = !isShowProfileMenu
            
            self.profileView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.profileView.center.x = self.profileView.frame.width / 2
            })
            
            headerView.isUserInteractionEnabled = false
            tapProfileMenuGesture.isEnabled = false
            tapCloseProfileMenuGesture.isEnabled = true
        }
    }
    
    @objc func closeProfileView() // yan profil menüsünün kapanması işlemi
    {
        if isShowProfileMenu
        {
            isShowProfileMenu = !isShowProfileMenu
            UIView.animate(withDuration: 0.3, animations: {
                self.profileView.center.x = -self.profileView.frame.width / 2
            }) { (_) in
            }
            headerView.isUserInteractionEnabled = true
            tapProfileMenuGesture.isEnabled = true
            tapCloseProfileMenuGesture.isEnabled = false
        }
    }
    
    @objc func closeSendView()
    {
        self.QR = digilira.QR.init()
        UserDefaults.standard.set(nil, forKey: "QRARRAY2")
        dismissLoadView()
        
    }
    
    @objc func tapAccountButton()
    {
        goSettingsScreen()
    }
    
    @objc func tapProfileMenuView()
    { /* Block menu view close tap action */ }
    
    func loadMenu() // alt menü view
    {
        menuXib = UIView().loadNib(name: "MenuView") as! MenuView
        menuXib.delegate = self
        menuXib.frame = menuView.frame
        menuXib.frame.origin.x = 0
        menuXib.frame.origin.y = 0
        menuView.addSubview(menuXib)
        menuView.backgroundColor = .clear
    }
    
    @IBAction func menuViewPanGesture(_ sender: UIPanGestureRecognizer) // yan profil menüsünün kaydırarak kapaılması işlemi
    {
        guard let menuview = sender.view else { return }
        let shift = sender.translation(in: menuview)
        guard shift.x < 0 else { return }
        UIView.animate(withDuration: 0.05) {
            menuview.center.x = menuview.frame.width / 2 + shift.x
        }
        if sender.state == .ended
        {
            if menuview.center.x < menuview.center.x / 2
            {
                closeProfileView()
            }
            else
            {
                UIView.animate(withDuration: 0.3) {
                    self.profileView.center.x = self.profileView.frame.width / 2
                }
            }
        }
    }
    
    func chooseQRSource () {
        let alert = UIAlertController(title: "QR Kod Seçin", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Galeri", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "İptal", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera () {
        
        isShowSettings = false
        dismissProfileMenu()
        dismissLoadView()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if !isShowQRButton
        {
            isShowQRButton = true
            sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
            sendWithQRView.frame.origin.y = self.view.frame.height
            let sendWithQRXib = UIView().loadNib(name: "sendWithQR") as! sendWithQR
            sendWithQRXib.delegate = self
            sendWithQRXib.frame = CGRect(x: 0,
                                         y: 0,
                                         width: sendWithQRView.frame.width,
                                         height: sendWithQRView.frame.height)
            
            for subView in sendWithQRView.subviews
            { subView.removeFromSuperview() }
            sendWithQRXib.openCamera()
            sendWithQRView.addSubview(sendWithQRXib)
            UIView.animate(withDuration: 0.3) {
                self.sendWithQRView.frame.origin.y = 0
                self.sendWithQRView.alpha = 1
            }
        }
    }
}

extension MainScreen: UITableViewDelegate, UITableViewDataSource // Tableview ayarları, coinlerin listelenmesinde bu fonksiyonlar kullanılır.
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewFiltered.count == 1 {
            return 3
        }
        return tableViewFiltered.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSuccessView { //eger basarili ekrani aciksa kapat
            return
        }
        goWalletScreen(coin: "")
        
    }
    
    @objc func handleTap(recognizer: MyTapGesture) {
        if isSuccessView { //eger basarili ekrani aciksa kapat
            return
        }
        if let token = try? BC.returnAsset(assetId: recognizer.assetName) {
            let tokenArray = [token]
            showMyFQr(coin: tokenArray);
        }
        
        
        //goWalletScreen(coin: recognizer.assetName)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = UITableViewCell().loadXib(name: "CoinTableViewCell") as? CoinTableViewCell
        {
            let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
            tapped.floatValue = indexPath[1]
            cell.addGestureRecognizer(tapped)
            
            if tableViewFiltered.count > 1 {
                
                if tableViewFiltered[indexPath[1]].tokenName == "Seperator" {
                    if let seperator = UITableViewCell().loadXib(name: "CoinTableSeperator") as? CoinTableSeperator {
                    
                        seperator.network.text = tableViewFiltered[indexPath[1]].network
                        return seperator
                        
                    }
                }
                
                let asset = tableViewFiltered[indexPath[1]]
                
                if ((UIImage(named: asset.tokenSymbol) == nil)) {
                    cell.emptyIcon.isHidden = false
                    cell.emptyCoin.text = asset.tokenSymbol.first?.description
                    cell.emptyIcon.backgroundColor = .random()
                } else {
                    cell.coinIcon.isHidden = false
                    cell.coinIcon.image = UIImage(named: asset.tokenSymbol)
                }
                
                let cp = asset.tlExchange
                var text = "₺" + MainScreen.df2so(asset.tlExchange)
                if cp == 1 {
                    text = "₺"
                }
                
                cell.coinName.text = asset.tokenName
                cell.type.text = text
                tapped.assetName = asset.tokenName
                
                let double = MainScreen.int2so(asset.balance, digits: asset.decimal)
                
                cell.coinAmount.text = double
                
            }
            

            if tableViewFiltered.count == 1 {
                let demoin = digilira.demo[indexPath[1]]
                                 
                if demoin == tableViewFiltered[0].tokenName {
                    let asset = tableViewFiltered[0]
                    cell.coinIcon.image = UIImage(named: asset.tokenSymbol)
                    cell.coinName.text = asset.tokenName
                    cell.type.text = "₺" + MainScreen.df2so(asset.tlExchange)
                    
                    let double = MainScreen.int2so(asset.balance, digits: asset.decimal)
                    tapped.assetName = double
                    cell.coinAmount.text = double
                    return cell
                }
                      
                let demoCoin = digilira.demoIcon[indexPath[1]]
                cell.coinIcon.image = UIImage(named: demoCoin)
                cell.coinName.text = demoin
                cell.type.text = "₺" + MainScreen.df2so(0)
                tapped.assetName = demoin

                let double = MainScreen.int2so(0, digits: 8)

                cell.coinAmount.text = double
            }
            
            return cell
            
        }
        else
        {
            return UITableViewCell()
            
        }
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   CGFloat.random(in: 0.5...0.9),
           green: CGFloat.random(in: 0.5...0.9),
           blue:  CGFloat.random(in: 0.5...0.9),
           alpha: 1.0
        )
    }
}

extension MainScreen: MenuViewDelegate // alt menünün butonlara tıklama kısmı
{
    func goPayments() {
        menuXib.payments()
                
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        walletOperationView.isHidden = true
        
        if isShowWallet
        {
            headerInfoLabel.isHidden = true
            isShowWallet = false
            walletView.removeDetail()
        }
        
        if isHomeScreen {
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.walletOperationView.isHidden = true
                self.contentScrollView.contentOffset.x = 0
            }
        }
        
        headerInfoLabel.isHidden = true
        homeAmountLabel.isHidden = true
        setLogoView()
        menuView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.contentScrollView.contentOffset.x = self.view.frame.width * 2
        }) { (_) in
            self.walletOperationView.isHidden = true
        }
        isShowSettings = false
        isPayments = true
        isHomeScreen = false
    }
    
    func goSettings() {
        menuXib.settings()
        walletOperationView.isHidden = true
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if isShowWallet
        {
            headerInfoLabel.isHidden = true
            isShowWallet = false
            walletView.removeDetail()
        }
        if isHomeScreen {
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.walletOperationView.isHidden = true
                self.contentScrollView.contentOffset.x = 0
            }
            isHomeScreen = false
        }
        headerInfoLabel.isHidden = true
        homeAmountLabel.isHidden = true
        setLogoView()
        menuView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.contentScrollView.contentOffset.x = self.view.frame.width * 3
        }) { (_) in
            self.walletOperationsViewOrigin = self.walletOperationView.frame.origin
        }
        
        isShowSettings = true
        isPayments = false
        
    }
    
    func goHomeScreen()
    {
        menuXib.isUserInteractionEnabled = false
        menuXib.home()

        if isPayments || isShowSettings {
            isPayments = false
            isShowSettings = false
        }
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if isShowWallet
        {
            walletView.removeDetail()
            headerInfoLabel.isHidden = true
            isShowWallet = false
        }
     
        UIView.animate(withDuration: 0.3, animations: {
            self.contentScrollView.contentOffset.x = 0
            self.headerView.frame.size.height =  self.headerHomeBuffer! + 70
            
        }, completion: { [self]_ in
            if !isPayments && !isShowWallet && !isShowSettings {
                UIView.animate(withDuration: 1, animations: {
                     self.walletOperationView.isHidden = false
                })
            }
        })
 
        if !isSuccessView {
            bottomView.isHidden = false
        }
         
        headerInfoLabel.isHidden = true
        headerInfoLabel.textColor = .black
        homeAmountLabel.isHidden = true
         
        menuView.isHidden = false
        
        isHomeScreen = true
        menuXib.isUserInteractionEnabled = true

    }
    
    
    func checkHeaderExist() {
        if !isWalletOperationLoaded {
            isWalletOperationLoaded = true
            walletOperationView = UIView().loadNib(name: "WalletOperationButtonSView") as! WalletOperationButtonSView
            walletOperationView.frame = CGRect(x: 0,
                                               y: homeAmountLabel.frame.maxY + 10,
                                               width: view.frame.width,
                                               height: 70)
            walletOperationView.delegate = self
            walletOperationView.alpha = 0
           
            UIView.animate(withDuration: 0.3, animations: {
                
                    self.headerView.addSubview(self.walletOperationView)
                    self.headerView.frame.size.height =  self.headerHomeBuffer! + 70
                
            }, completion: { [self]_ in
                    setHeaderTotal()
            })
             

        } else {
            UIView.animate(withDuration: 0.3, animations: {
                    self.headerView.frame.size.height =  self.headerHomeBuffer! + 70
            }, completion: { [self]_ in
                
                        setHeaderTotal()
                    
            })
            
        }
    }
    
    func goWalletScreen(coin: String)
    {
        if isShowWallet {
            return
        }
        
        if isHomeScreen {
            UIView.animate(withDuration: 0.3, animations: {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.contentScrollView.contentOffset.x = 0
                self.walletOperationView.isHidden = true
            }, completion: {_ in
                

            })
        }
        
        walletView.onSight = true
        menuXib.wallet()
        walletView.coin = coin
        walletView.readHistory()
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
         
        if !isShowWallet
        {
            isShowWallet = true
            setLogoView()
            
            isShowSettings = false
            isPayments = false
            isHomeScreen = false
            
            UIView.animate(withDuration: 0.3, animations: { [self] in
                self.contentScrollView.contentOffset.x = self.contentScrollView.frame.width
            }) { (_) in
                self.walletOperationsViewOrigin = self.walletOperationView.frame.origin
            }
        }
    }
    
    func goSettingsScreen()
    {
        walletOperationView.isHidden = true

        if !isShowSettings
        {
            isShowSettings = true
            dismissLoadView()
            goProfileSettings()
        }
    }
    
    internal func openCommissions() {

        commissionsView = UIView().loadNib(name: "CommisionsView") as! CommissionsView
        sendWithQRView.frame.origin.y = self.view.frame.height
        commissionsView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: view.frame.width,
                                      height: view.frame.height)
        commissionsView.delegate = self
        commissionsView.errors = self
        
        commissionsView.tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: self.view.frame.width,
                                 height: self.view.frame.height)
        commissionsView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let line1 = digilira.line.init(mode: "text", text: "DigiliraPay kullanıcıları arasındaki transferler")
        let btc1 = digilira.line.init(mode: "coin", text: "Bitcoin", icon: UIImage(named: "WBTC"), l1: "Ücretsiz", l2: "Ücretsiz", minSend: "0.00000300 BTC", minReceive: "-")
        let eth1 = digilira.line.init(mode: "coin", text: "Ethereum", icon: UIImage(named: "WETH"), l1: "Ücretsiz", l2: "Ücretsiz", minSend: "0.0001 ETH", minReceive: "-")
        let waves1 = digilira.line.init(mode: "coin", text: "Waves", icon: UIImage(named: "Waves"), l1: "Ücretsiz", l2: "Ücretsiz", minSend: "0.01 WAVES", minReceive: "-")
        let usd1 = digilira.line.init(mode: "coin", text: "Tether USDT", icon: UIImage(named: "USDT"), l1: "Ücretsiz", l2: "Ücretsiz", minSend: "0.1 USDT", minReceive: "-")
        let onet1 = digilira.line.init(mode: "coin", text: "One Tower", icon: UIImage(named: "One Tower"), l1: "Ücretsiz", l2: "Ücretsiz", minSend: "1 ONET", minReceive: "-")
        
        let sep1 = digilira.line.init(mode: "text", text: "")
        
        let line2 = digilira.line.init(mode: "text", text: "DigiliraPay kullanıcılarının Waves blokzinciri üzerindeki transferleri")
        
        let head2 = digilira.line.init(mode: "header", text: "TOKEN", icon: UIImage(named: ""), l1: "Gönderme", l2: "Alma", minSend: "(min)", minReceive: "(min)")
        
        let btc2 = digilira.line.init(mode: "coin", text: "Bitcoin", icon: UIImage(named: "WBTC"), l1: "0.005 Waves", l2: "Ücretsiz", minSend: "0.00000300 BTC", minReceive: "-")
        let eth2 = digilira.line.init(mode: "coin", text: "Ethereum", icon: UIImage(named: "WETH"), l1: "0.005 Waves", l2: "Ücretsiz", minSend: "0.0001 ETH", minReceive: "-")
        let waves2 = digilira.line.init(mode: "coin", text: "Waves", icon: UIImage(named: "Waves"), l1: "0.005 Waves", l2: "Ücretsiz", minSend: "0.01 WAVES", minReceive: "-")
        let usd2 = digilira.line.init(mode: "coin", text: "Tether USDT", icon: UIImage(named: "USDT"), l1: "0.005 Waves", l2: "Ücretsiz", minSend: "0.1 USDT", minReceive: "-")
        let onet2 = digilira.line.init(mode: "coin", text: "One Tower", icon: UIImage(named: "One Tower"), l1: "Gönderilmez", l2: "Gönderilmez", minSend: "-", minReceive: "-")
        let sep2 = digilira.line.init(mode: "text", text: "")
        
        let line3 = digilira.line.init(mode: "text", text: "DigiliraPay kullanıcılarının Waves blokzinciri dışındaki transferleri")
        
        let btc3 = digilira.line.init(mode: "coin", text: "Bitcoin", icon: UIImage(named: "WBTC"), l1: "0.001 BTC", l2: "Ücretsiz", minSend: "0.001 BTC", minReceive: "0.001 BTC")
        let eth3 = digilira.line.init(mode: "coin", text: "Ethereum", icon: UIImage(named: "WETH"), l1: "0.02 ETH", l2: "Ücretsiz", minSend: "0.01 ETH", minReceive: "0.01 ETH")
        let waves3 = digilira.line.init(mode: "coin", text: "Waves", icon: UIImage(named: "Waves"), l1: "2 WAVES", l2: "Ücretsiz", minSend: "1 WAVES", minReceive: "1 WAVES")
        let usd3 = digilira.line.init(mode: "coin", text: "Tether USDT", icon: UIImage(named: "USDT"), l1: "20 USDT", l2: "Ücretsiz", minSend: "10 USDT", minReceive: "10 USDT")
        let onet3 = digilira.line.init(mode: "coin", text: "One Tower", icon: UIImage(named: "One Tower"), l1: "Gönderilmez", l2: "Gönderilmez", minSend: "-", minReceive: "-" )
        
        let line4 = digilira.line.init(mode: "text", text: "(min): Komisyonlar hariç gönderebileceğiniz veya alabileceğiniz en az miktarları gösterir. Bu miktarların altında yapılan transferler alıcıya ulaşmaz ve iade talep edilemez.\n\n(kom): Waves blokzinciri dışına yapılan işlemler için Waves ağ geçidine ödenen ücreti ifade etmektedir.")
         commissionsView.lines = [line1, head2, btc1, eth1, waves1, usd1, onet1, sep1,
                                 line2, head2, btc2, eth2, waves2, usd2, onet2, sep2,
                                 line3, head2, btc3, eth3, waves3, usd3, onet3, sep2, line4
                                ]

        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(commissionsView)
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        closeProfileView()
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
    }
    
    private func bitexenScreen() {
        isBitexenAPI = true
        bitexenAPIView = UIView().loadNib(name: "bitexenApiView") as! BitexenAPIView
        sendWithQRView.frame.origin.y = self.view.frame.height
        bitexenAPIView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: view.frame.width,
                                      height: view.frame.height)
        bitexenAPIView.delegate = self
        bitexenAPIView.errors = self

        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(bitexenAPIView)
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        closeProfileView()
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
    }
    
    private func seedScreen() {
        isSeedScreen = true
        for view in self.sendWithQRView.subviews
        { view.removeFromSuperview() }
        self.sendWithQRView.translatesAutoresizingMaskIntoConstraints = true

        let headerExitView: HeaderExitView = UIView().loadNib(name: "HeaderExitView") as! HeaderExitView

        headerExitView.delegate = self
        headerExitView.frame = CGRect(x: 0,
                                      y: 0,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height)
        
        headerExitView.backgroundColor = UIColor.white
        
        if let isBackuped = UserDefaults.standard.value(forKey: "seedRecovery") as? Bool {
            headerExitView.isVerified = isBackuped
        }

        headerExitView.start()
        self.sendWithQRView.addSubview(headerExitView)
        self.sendWithQRView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
    }
    
    func goQRScreen()
    {
        chooseQRSource()
    } 
}

extension MainScreen: OperationButtonsDelegate
{
    func send(params: SendTrx)
    {
        let transactionRecipient: String = params.merchant!
        
        if isNewSendScreen {
            newSendMoneyView.transaction = params
            newSendMoneyView.setQR()
            return
        }
        
        isNewSendScreen = true

        newSendMoneyView = UIView().loadNib(name: "newSendView") as! newSendView
        newSendMoneyView.ticker = digiliraPay.ticker(ticker: Ticker)
        
        sendWithQRView.frame.origin.y = self.view.frame.height
        newSendMoneyView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height)
        
        newSendMoneyView.errors = self
        newSendMoneyView.delegate = self
        
        newSendMoneyView.Filtered = Waves
        
        do {
            newSendMoneyView.Coins = try BC.returnCoins()
        } catch {
            throwEngine.evaluateError(error: digilira.NAError.tokenNotFound)
            return
        }
        
        newSendMoneyView.Ticker = Ticker
        newSendMoneyView.set()
        
        newSendMoneyView.recipientText.setTitle(transactionRecipient, for: .normal)
         
        do {
            let coin = try BC.returnAsset(assetId:  params.assetId)
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            if params.amount != 0 {
                newSendMoneyView.textAmount.text = (Double(params.amount!) / double).description
            }else{
                newSendMoneyView.textAmount.text = ""
            }
        } catch  {
            print (error)
        }
        
        newSendMoneyView.transaction = params
        newSendMoneyView.setQR()
        if params.destination == digilira.transactionDestination.interwallets {
            newSendMoneyView.recipientText.isEnabled = true
        }
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(newSendMoneyView)
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        closeProfileView()
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func showMyFQr(coin: [WavesListedToken] = []) {
        
        if kullanici.status == 0 {
            verifyProfile()
            DispatchQueue.main.async { [self] in
                
                if let identity = UserDefaults.standard.value(forKey: "isIdentity") as? Bool {
                    if identity {
                        self.throwEngine.alertCaution(title: "Profil Onayı", message: "Profil onay süreciniz devam etmektedir.")
                        return
                    }
                }
                
                self.throwEngine.alertCaution(title: "Profil Onayı", message: "Müşterini tanı politikası gereğince hesabınıza para yükleyebilmek için profil onay sürecini tamamlamanız gerekmektedir.")
            }
            return
        }
        
        
        qrView.frame.origin.y = view.frame.height
        paraYatirView = UIView().loadNib(name: "ParaYatirView") as! ParaYatirView
        paraYatirView.frame.origin.y = self.view.frame.height
        paraYatirView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: view.frame.width,
                                    height: view.frame.height)
        paraYatirView.delegate = self
        paraYatirView.errors = self
        
        if (coin.count == 0) {
            do {
                let coins = try BC.returnCoins()
                var arr:[WavesListedToken] = []
                
                if let result = UserDefaults.standard.value(forKey: "isAuthorized") as? Int {
                    for coin in coins {
                        if coin.role <= result {
                            arr.append(coin)
                        }
                    }
                } else {
                    for coin in coins {
                        if coin.role <= 200 {
                            arr.append(coin)
                        }
                    }
                }
                paraYatirView.Filtered = arr

            } catch {
                throwEngine.evaluateError(error: digilira.NAError.tokenNotFound)
                return
            }
        } else {
            paraYatirView.Filtered = coin
        }
        

        paraYatirView.Ticker = Ticker
        
        for subView in qrView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        qrView.addSubview(paraYatirView)
         
        qrView.isHidden = false
        qrView.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.3)
        {
            self.qrView.frame.origin.y = 0
            self.qrView.alpha = 1
        }
        
    }

    func load()
    {
        showMyFQr()
    }
 
}

extension MainScreen: BitexenAPIDelegate
{
    func dismissBitexen() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }) { (_) in
            
        }
        menuView.isHidden = false
        dismissKeyboard()
        setPaymentView()
    } 
}

extension MainScreen: ProfileMenuDelegate // Profil doğrulama, profil ayarları gibi yan menü işlemleri
{
    func showCommissions() {
        self.openCommissions()
    }
    
    
    func showBitexenView() {
        
        if  !digiliraPay.isKeyPresentInUserDefaults(key: digiliraPay.returnBexChain()) {
            self.bitexenScreen()
            return
        }
         
        self.onPinSuccess = { [self] res in
            switch res {
            case true:
                self.bitexenScreen()
                self.closeProfileView()
                break
            case false:
                self.closeProfileView()
                break
            }
            
        }
        
        digiliraPay.onTouchID = { res, err in
            if res == true {
                self.bitexenScreen()
            } else {
                self.isTouchIDCanceled = true
                self.openPinView()
                self.closeProfileView()
            }
        }
        
        digiliraPay.touchID(reason: "API bilgilerini görüntüleyebilmek için kimliğinizi onaylamanız gerekmektedir.")
        
    }
    
    func showSeedView() {
        
        self.onPinSuccess = { [self] res in
            switch res {
            case true:
                self.seedScreen()
                self.closeProfileView()
                break
            case false:
                self.closeProfileView()
                break
            }
            
        }
        
        digiliraPay.onTouchID = { res, err in
            if res == true {
                self.seedScreen()
                self.closeProfileView()
                
            } else {
                self.isTouchIDCanceled = true
                self.openPinView()
                self.closeProfileView()
            }
        }
        
        digiliraPay.touchID(reason: "Transferin gerçekleşebilmesi için biometrik onayınız gerekmektedir!")
        
        
    }
    
    func verifyProfile()
    {
        qrView.frame.origin.y = view.frame.height
        bottomView.isHidden = true // alttaki boslugun kadldirilmasi
        
        isVerifyAccount = true
        //profil onay sureci
        
        do {
            let k = try secretKeys.userData()
            
            switch k.status {
            case 0, 3:
                
                if let isIdentity = UserDefaults.standard.value(forKey: "isIdentity") as? Bool {
                    if isIdentity {
                        throwEngine.alertWarning(title: "Kontrol Aşamasında", message: "Gönderdiğiniz bilgiler kontrol edildikten sonra tarafınıza bildirim yapılacaktır. Eğer bildirimleri açmadıysanız, telefonunuzun ayarlar bölümünden bildirimlere izin vermeniz gerekmektedir.")
                        return
                    }
                }
                let verifyProfileXib = UIView().loadNib(name: "VerifyAccountView") as! VerifyAccountView
                
                verifyProfileXib.frame = CGRect(x: 0,
                                                y: 0,
                                                width: view.frame.width,
                                                height: view.frame.height)
                
                verifyProfileXib.delegate = self
                verifyProfileXib.errors = self
                
                for subView in qrView.subviews
                { subView.removeFromSuperview() }
                
                if kullanici.status == 3 {
                    verifyProfileXib.descLabel.text =  "Profiliniz Onaylanmıştır."
                    verifyProfileXib.titleLabel.text = "Profilim"
                    verifyProfileXib.nameText.isEnabled = false
                    verifyProfileXib.surnameText.isEnabled = false
                    verifyProfileXib.tcText.isEnabled = false
                    verifyProfileXib.telText.isEnabled = false
                    verifyProfileXib.mailText.isEnabled = false
                    verifyProfileXib.dogum.isEnabled = false
                    verifyProfileXib.sendAndContiuneView.isHidden = true
                    verifyProfileXib.remarksView.isHidden = true
                }
     
                qrView.addSubview(verifyProfileXib)
                qrView.isHidden = false
                qrView.translatesAutoresizingMaskIntoConstraints = true
                closeProfileView()
                
                UIView.animate(withDuration: 0.3)
                {
                    self.qrView.frame.origin.y = 0
                    self.qrView.alpha = 1
                }
                
            case 1:
                let verifyProfileXib = UIView().loadNib(name: "ProfileUpgradeView") as! ProfilUpgradeView
                
                verifyProfileXib.frame = CGRect(x: 0,
                                                y: 0,
                                                width: view.frame.width,
                                                height: view.frame.height)
                
                verifyProfileXib.setSendId()
                verifyProfileXib.delegate = self
                for subView in qrView.subviews
                { subView.removeFromSuperview() }
                
                menuView.isHidden = true
                
                qrView.addSubview(verifyProfileXib)
                qrView.isHidden = false
                qrView.translatesAutoresizingMaskIntoConstraints = true
                closeProfileView()
                
                UIView.animate(withDuration: 0.3)
                {
                    self.qrView.frame.origin.y = 0
                    self.qrView.alpha = 1
                }
            case 2:
                throwEngine.alertWarning(title: "Profil Onayı", message: "Gönderdiğiniz bilgiler kontrol edilmektedir.", error: false)
                
                break
            default:
                print("ok")
                
            }
        } catch {
            
        }
        
        
        
    }
    
    func goProfileSettings()
    {
        profileSettingsView.frame.origin.y = view.frame.height
        let profileSettingsXib = UIView().loadNib(name: "ProfileSettingsView") as! ProfileSettingsView
        profileSettingsXib.delegate = self
        profileSettingsXib.frame = CGRect(x: 0,
                                          y: 0,
                                          width: profileSettingsView.frame.width,
                                          height: profileSettingsView.frame.height)
        
        for subView in profileSettingsView.subviews
        { subView.removeFromSuperview() }
        profileSettingsView.addSubview(profileSettingsXib)
        closeProfileView()
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.frame.origin.y = 0
        }) { (_) in
            
        }
    }
    
    func goExtraPayment()
    {
        paymentCat.frame.origin.y = view.frame.height
        let paymentCatXib = UIView().loadNib(name: "PaymentCategories") as! PaymentCat
        paymentCatXib.delegate = self
        paymentCatXib.frame = CGRect(x: 0,
                                     y: 0,
                                     width: paymentCat.frame.width,
                                     height: paymentCat.frame.height)
        
        for subView in paymentCat.subviews
        { subView.removeFromSuperview() }
        paymentCat.addSubview(paymentCatXib)
        closeProfileView()
        UIView.animate(withDuration: 0.4, animations: {
            self.paymentCat.frame.origin.y = 0
        }) { (_) in
            
        }
    }
    
    func goNewSendView() {
        
        newSendMoneyView = UIView().loadNib(name: "newSendView") as! newSendView
        sendWithQRView.frame.origin.y = self.view.frame.height
        newSendMoneyView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height)
        
        newSendMoneyView.Filtered = self.Filtered
        newSendMoneyView.Ticker = Ticker

        newSendMoneyView.delegate = self
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(newSendMoneyView)
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        closeProfileView()
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
        
    }
    
    
    func goPageCardView(ORDER: PaymentModel) {
        
        pageCardView = UIView().loadNib(name: "PageCardView") as! PageCardView
        pageCardView.frame.origin.y = self.view.frame.height
        pageCardView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: view.frame.width,
                                    height: view.frame.height)
        pageCardView.errors = self
        pageCardView.delegate = self
        
        var doesHave = true
        var tokenName = ""
        
        if let coin = ORDER.currency {
            doesHave = false
            do {
                let asset = try BC.returnAsset(assetId: coin)
                
                for item in Filtered {
                    tokenName = asset.tokenName
                    if asset.tokenName == item.tokenName {
                        doesHave = true
                        let balance = item
                        pageCardView.Filtered = [balance]
                    }
                }
            } catch {
                DispatchQueue.main.async { [self] in
                    errorHandler(message: "Token Desteklenmemektedir.", title: "Token Hatalı", error: true)
                    return
                }
            }
           

        } else {
            pageCardView.Filtered = self.Filtered
        }
        
        if !doesHave {
            errorHandler(message: "Bu ödeme sadece " + tokenName +  " ile yapılabilir. Hesabınızda " + tokenName + " bulunmadığı için ödeme yapamazsınız.", title: "Yetersiz Bakiye", error: true)
            return
        }
         
        pageCardView.bexTicker = bexTicker
        pageCardView.marketInfo = bexMarketInfo
        pageCardView.Ticker = Ticker
        pageCardView.Order = ORDER
        pageCardView.setTableView()
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(pageCardView)
        
        if QR.address != nil {
            
            if isPinEntered {
                UserDefaults.standard.set(nil, forKey: "QRARRAY2")
                self.QR = digilira.QR.init()
            }
            
        }
        
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
        
    }
     
    func showSuccess(mode: Int, transaction: TransferTransactionModel) {
        do {
            let asset = try BC.returnAsset(assetId: transaction.assetID)
            
            let amount:String = MainScreen.int2so(transaction.amount, digits: asset.decimal)

            let message = amount + " " + asset.tokenName + " Gönderiliyor."
            switch mode {
            case 1:
                throwEngine.alertTransaction(title: "Doğrulanıyor", message: message, verifying: true)
                break
            case 2:
                fetch()
                throwEngine.alertWarning(title: "Transfer Başarılı", message: "Transferiniz gerçekleşti.", error: false)
            default:
                break
            }
            
        } catch  {
            print(error)
        }
    
        
    }
    
    func showTermsofUse()
    {
        showLegal(mode: digilira.terms.init(title: digilira.termsOfUse.title, text: digilira.termsOfUse.text))
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            self.shake()
            self.throwEngine.alertWarning(title: "Dikkat", message: "Galeriye erişim izniniz bulunmamaktadır", error: true)
        }
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }
    
    func showLegalText()
    {
        showLegal(mode: digilira.terms.init(title: digilira.legalView.title, text: digilira.legalView.text))
    }
    func showPinView() {
        isNewPin = true
        openPinView()
    }
    
    func sendBTCETH (external: digilira.externalTransaction, ticker: digilira.ticker) {
         
            do {
                let coin = try BC.returnAsset(assetId: external.assetId)
                do {
                    let exchange = try digiliraPay.exchange(amount: external.amount!, coin: coin, symbol: digiliraPay.ticker(ticker: Ticker))
                    
                    BC.onMember = { res, data in
                        DispatchQueue.main.async { [self] in

                            guard let data = data else {return}
                            
                            var miktar: Int64 = 0
                            var attach = ""
                            
                            if data.amount != nil {
                                miktar = data.amount!
                            }
                            
                            attach = data.message
                            
                            var name = digilira.dummyName
                            if let f = kullanici.firstName {
                                if let l = kullanici.lastName {
                                    name = f + " " + l
                                }
                            }
                            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                                let trx = SendTrx.init(merchant: data.owner!,
                                                       recipient: data.wallet!,
                                                       assetId: data.assetId!,
                                                       amount: miktar,
                                                       fee: digilira.sponsorTokenFee,
                                                       fiat: exchange,
                                                       attachment: attach,
                                                       network: data.network!,
                                                       destination: data.destination!, externalAddress: data.wallet,
                                                       massWallet: data.wallet,
                                                       memberCheck: true,
                                                       me: name,
                                                       blockchainFee: Int64(coin.gatewayFee * double)
                                )
                                
                                self.send(params: trx)
                        }
                        
                    }
                } catch {
                    throwEngine.evaluateError(error: error)
                }
                
                BC.isOurMember(external: external)
                
            } catch  {
                print (error)
            }
       
        
        
        
    }
    
    func popup (image: UIImage?) {
        PHPhotoLibrary.requestAuthorization { status in
          if status == .authorized {
            //do things
            if let image = image {
                if let pngImageData = image.pngData() {
                    // Write the png image into a filepath and return the filepath in NSURL
                    if let pngImageURL = pngImageData.dataToFile(fileName:  UUID().uuidString + ".png") {
                        
                        // Create the Array which includes the files you want to share
                        var filesToShare = [Any]()

                        // Add the path of png image to the Array
                        filesToShare.append(pngImageURL)
                        
                        let activityViewController = UIActivityViewController(activityItems:filesToShare, applicationActivities: nil)
                        if #available(iOS 13.0, *) {
                            activityViewController.isModalInPresentation = true
                        } else {
                            // Fallback on earlier versions
                        }
                        self.present(activityViewController, animated: true)
                    }
                }
            }
          }
            
        } 
    } 
}

extension MainScreen: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.dismiss(animated: true, completion: {
            
        })
    }
    

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return 
        }
        
        if isProfileImageUpload {
            isProfileImageUpload = false

            
        digiliraPay.onUpdate = { res, sts in
            DispatchQueue.main.async { [self] in
                if (res != nil) {
                    if let user = res {
                        kullanici = user
                        self.throwEngine.warningView.removeFromSuperview()
                        self.throwEngine.alertWarning(title: "Bilgileriniz Yüklendi", message: "Gönderdiğiniz bilgiler kontrol edildikten sonra profiliniz güncellenecektir.", error: false)
                        
                        if isIdentityUpload {
                            UserDefaults.standard.set(true, forKey: "isIdentity")
                        } else {
                            UserDefaults.standard.set(true, forKey: "isSelfied")
                        }
                        
                        checkEssentials()
                    }
                } else {
                    throwEngine.evaluateError(error: digilira.NAError.anErrorOccured)
                }
            }
        }
        
            throwEngine.alertTransaction(title: "Yükleniyor...", message: "Fotoğrafınız yükleniyor lütfen bekleyin.", verifying: true)
            
            
            if let img = image.resizeWithWidth(width: 700) {
                if let compressData = img.jpegData(compressionQuality: 0.5) {
                    if let compressedImage = UIImage(data: compressData) {
                        let b64 = digiliraPay.convertImageToBase64String(img: compressedImage)

                        let idHash = b64.hash256()
                        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
                        
                        var userStatus = 2
                        if isIdentityUpload {
                            userStatus = 0
                        }

                        if let sign = try? BC.bytization([kullanici.id, idHash, userStatus.description], timestamp) {
                            let user = digilira.exUser.init(
                                id: kullanici.id,
                                wallet: sign.wallet, status:userStatus,
                                id1: b64,
                                signed: sign.signature,
                                publicKey: sign.publicKey,
                                timestamp: timestamp
                            )
                            
                            let encoder = JSONEncoder()
                            let data = try? encoder.encode(user)
                            
                            digiliraPay.updateUser(user: data, signature: sign.signature)
                        }
                        
                        
                    } else {
                        throwEngine.alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Dosya yüklenemedi. Lütfen tekrar deneyin. Sıkıştırma Hatası", error: true)
                        return
                    }
                } else {
                    throwEngine.alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Dosya yüklenemedi. Lütfen tekrar deneyin. Düzenleme Hatası", error: true)
                    return
                }
            } else {
                throwEngine.alertWarning(title: lang.const(x: Localize.keys.an_error_occured.rawValue), message: "Dosya yüklenemedi. Lütfen tekrar deneyin.", error: true)
                return
            }
  
        }else {
            if let features = detectQRCode(image), !features.isEmpty{
                for case let row as CIQRCodeFeature in features{
                    
                    if (row.messageString != "") {
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
                        OpenUrlManager.parseUrlParams(openUrl: URL(string: row.messageString!))
                    }
                }
            }
        }
         
        self.imagePicker.dismiss(animated: true, completion: {})
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
    static let orderClick = Notification.Name("orderClick")
    static let trxConfirm = Notification.Name("trxConfirm")
}

class MyTapGesture: UITapGestureRecognizer {
    var floatValue = 0
    var assetName = ""
    var qrAttachment = ""
    var trxId = ""
    
}

class CopyGesture: UITapGestureRecognizer {
    var cp:String?
    var btn:UIButton?
    var msg:String?
    
}

class depositeGesture: UITapGestureRecognizer {
    var floatValue:Float?
    var address: String?
    var qrAttachment: String = ""
    
}

import CryptoKit
import CommonCrypto

extension String {
    func hash256() -> String {
        let inputData = Data(utf8)
        
        if #available(iOS 13.0, *) {
            let hashed = SHA256.hash(data: inputData)
            return hashed.compactMap { String(format: "%02x", $0) }.joined()
        } else {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            inputData.withUnsafeBytes { bytes in
                _ = CC_SHA256(bytes.baseAddress, UInt32(inputData.count), &digest)
            }
            return digest.makeIterator().compactMap { String(format: "%02x", $0) }.joined()
        }
    }
}

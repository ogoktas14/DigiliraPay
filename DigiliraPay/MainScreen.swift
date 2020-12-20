//
//  MainScreen.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 25.08.2019.
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
    @IBOutlet weak var serverLabel: UILabel!
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
    var selectCoin = selectCoinView()
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
    
    var walletOperationsViewOrigin = CGPoint(x: 0, y: 0)
    
    var kullanici: digilira.auth = try! secretKeys.userData()
    var pinkodaktivasyon: Bool? = false
    
    var Balances: NodeService.DTO.AddressAssetsBalance?
    var Ticker: binance.BinanceMarketInfo = []
    var Filtered: [digilira.DigiliraPayBalance] = []
        
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
    
    func checkEssentials() {
        if let versionLegal = UserDefaults.standard.value(forKey: "isLegalView") as? Int {
            let v = digilira.legalView.version
            if (versionLegal < v) {
                throwEngine.alertWarning(title: digilira.messages.newLegalViewTitle, message: digilira.messages.newLegalViewMessage, error: false)
                profileMenuView.legalViewWarning.isHidden = false
                showLegalText()
                return
            }
            profileMenuView.legalViewWarning.isHidden = true
        }
        
        if let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse") as? Int {
            let v = digilira.termsOfUse.version
            if (versionTerms < v) {
                throwEngine.alertWarning(title: digilira.messages.newTermsOfUseTitle, message: digilira.messages.newTermsOfUseMessage, error: false)
                profileMenuView.termsViewWarning.isHidden = false
                showTermsofUse()
                return
            }
            profileMenuView.termsViewWarning.isHidden = true
        }
        
        if let isVerified = UserDefaults.standard.value(forKey: "seedRecovery") as? Bool {
            if isVerified {
                profileMenuView.seedBackupWarning.isHidden = true
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
        
        switch WavesSDK.shared.enviroment.server {
        case .mainNet:
            serverLabel.text = "MainNet"
            break
        default:
            serverLabel.text = "TestNet"
            break
        }
        
        do {
            kullanici = try secretKeys.userData()
        } catch {
            self.digiliraPay.onLogin2 = { user, status in
                DispatchQueue.main.sync {
                    self.kullanici = user
                }
            }
            digiliraPay.login2()
        }
        
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
                
                if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
                    QR = qr
                    self.getOrder(address: QR)
                }
                
                isBitexenReload = false
                isWavesReloaded = false
                Filtered.removeAll()
                Filtered.append(contentsOf: Waves)
                Filtered.append(contentsOf: Bitexen)
                self.checkHeaderExist()
            }
        }
        
        bitexenSign.onBitexenBalance = { [self] balances, statusCode in
            if statusCode == 200 {
                bitexenBalance = 0
                Bitexen.removeAll()
                for bakiye in balances.data.balances {
                    if Double(bakiye.value.balance)! > 0 {
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
                                    tlExchange: lastPrice, network: "bitexen")
                                
                                bitexenBalance += lastPrice

                                Bitexen.append(digiliraBalance)
                                
                                self.BitexenBalances.append(bakiye.value)
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
        
        BC.onAssetBalance = { [self] result in
            construct(result: result)
        }
        
        BC.onMassTransaction = { res in
            print(res)
            let txid = res.dictionary["id"] as? String
            
            DispatchQueue.main.async {
                self.showSuccess(mode: 1, transaction: res.dictionary)
            }
            self.bottomView.isHidden = true
            self.goHomeScreen()
            
            self.BC.verifyTrx(txid: txid!)
            
            self.bottomView.isHidden = true
            self.goHomeScreen()
        }
        
        
        BC.onTransferTransaction = { res in
            //            let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res.dictionary["attachment"] as! String)!), as: UTF8.self)
            let txid = res.dictionary["id"] as? String
            
            DispatchQueue.main.async {
                self.showSuccess(mode: 1, transaction: res.dictionary)
            }
            self.bottomView.isHidden = true
            self.goHomeScreen()
            
            self.BC.verifyTrx(txid: txid!)
            
        }
        
        BC.onVerified = { res in

            NotificationCenter.default.post(name: .didCompleteTask, object: nil)
            DispatchQueue.main.async {
                self.showSuccess(mode: 2, transaction: res)
            }
            
            let id = res["id"] as? String
            switch res["type"] as? Int {
            case 11:
                return
            default:
                let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res["attachment"] as! String)!), as: UTF8.self)
                
                let odeme = digilira.odemeStatus.init(id: attachment, txid: id!, status: "2")
                self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
            }
            
        }
        
        digiliraPay.onError = { res, sts in
            self.throwEngine.evaluateError(error: res)            
        }
        
        BC.onError = { [self] res in
            if isFirstLaunch {
                loadScreen()
            }
            self.throwEngine.evaluateError(error: res)
        }
        
        bitexenSign.onBitexenError = { res, sts in
            self.throwEngine.alertWarning(title: "Bitexen API", message: "Bitexen API bilgileriniz hatalıdır.", error: true)
        }
        refreshControl.alpha = 0
        refreshControl.attributedTitle = NSAttributedString(string: "Güncellemek için çekiniz..")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCompleteTask(_:)), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrxCompleted), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onOrderClicked), name: .orderClick, object: nil)
        
        
        
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark{
            
            //            IQKeyboardManager.shared.keyboardAppearance = .dark
            mainView.backgroundColor = UIColor.black
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
    }
    
    func construct(result: NodeService.DTO.AddressAssetsBalance) {
        let ticker = digiliraPay.ticker(ticker: Ticker)
        totalBalance = 0
        Waves.removeAll()

        for asset1 in result.balances {
            
            do {
                let asset = try BC.returnAsset(assetId: asset1.assetId)
                
                var coinPrice:Double = 0
                let double = Double(truncating: pow(10,asset.decimal) as NSNumber)
                
                switch asset.tokenName {
                case "Bitcoin":
                    coinPrice = (ticker.btcUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / double
                    break
                case "Ethereum":
                    coinPrice = (ticker.ethUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / double
                    break
                case "Kızılay":
                    coinPrice = 1 * Double(asset1.balance) / double
                    break
                case "Waves":
                    coinPrice = (ticker.wavesUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / double
                    break
                case "Tether USDT":
                    coinPrice = (ticker.usdTLPrice)! * Double(asset1.balance) / double
                    break
                default:
                    coinPrice = 0
                    break
                }
                
                let digiliraBalance = digilira.DigiliraPayBalance.init(
                    tokenName: asset.tokenName,
                    tokenSymbol: asset1.issueTransaction.name,
                    availableBalance: asset1.balance,
                    decimal: asset.decimal,
                    balance: asset1.balance,
                    tlExchange: coinPrice,
                    network: "waves")
                
                totalBalance += coinPrice
                
                Waves.append(digiliraBalance)
            } catch {
                throwEngine.evaluateError(error: error)
            }
            
        }
        
        loadScreen()
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
            checkEssentials()
            isFirstLaunch = false
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
    
    struct JwtAlg: Codable {
        let alg, typ: String
    }
    
    struct JwtPayload: Codable {
        let sub: String
        let def: Int
        let m: String
        let iat, exp: Int64
    }
    
    func isTokenOK() -> Bool {
        let token = kullanici.token
        let jwt = token.split(separator: ".")
        
        if let decodedData = Data(base64Encoded: String(jwt[1])) {
            
            do {
                let jwtPayload = try digiliraPay.decodeDefaults(forKey: decodedData, conformance: JwtPayload.self)
                let now = Date().millisecondsSince1970
                let then : Int64 = jwtPayload.exp * Int64(1000)
                
                let diff = ((then - now) / Int64(1000)) / 60

                if diff == 0 {
                    return false
                }
                return true
            } catch {
                print(error)
            }
            
        }
        return false
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
        let bakiye = MainScreen.df2so(totalBalance + bitexenBalance)
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
 
            logoView.isHidden = false
            
            walletOperationView.frame.origin.y = walletY
            walletOperationView.alpha = 1
        }, completion: { [self]_ in
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
        
        if !isTokenOK() {
            throwEngine.waitPlease()
            self.digiliraPay.onLogin2 = { user, status in
                DispatchQueue.main.sync {
                    self.throwEngine.removeWait()
                    self.kullanici = user
                    self.getOrder(address: address)
                }
            }
            
            self.digiliraPay.login2()
        }else {
            
            if address.address == nil {return}
            switch address.network {
            
            case digilira.bitcoin.network:
                let external = digilira.externalTransaction(network: address.network, address: address.address, amount: address.amount, message: address.address!, assetId:digilira.bitcoin.token)
                sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                break
            case digilira.waves.network:
                let external = digilira.externalTransaction(network: address.network, address: address.address, amount: address.amount, message: address.address!, assetId: address.assetId!)
                sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                break
            case digilira.ethereum.network:
                let external = digilira.externalTransaction(network: address.network, address: address.address, amount: address.amount, message: address.address!, assetId:digilira.ethereum.token)
                sendBTCETH(external: external, ticker:digiliraPay.ticker(ticker: Ticker))
                break
            default:
                digiliraPay.onGetOrder = { res in
                    //self.goSelectCoinView(ORDER: res)
                    let odeme = digilira.odemeStatus.init(
                        id: res._id,
                        status: "1",
                        name: self.kullanici.firstName,
                        surname: self.kullanici.lastName,
                        wallet: self.kullanici.wallet,
                        _id: self.kullanici.id
                    )
                    
                    self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
                    self.goPageCardView(ORDER: res)
                    
                }
                digiliraPay.getOrder(PARAMS: address.address!)
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
    
    @objc func onOrderClicked(_ sender: Notification) {

        if let ifQR = (sender.userInfo!["qr"]) {
            
            digiliraPay.onGetOrder = { res in
                self.throwEngine.alertOrder(order: res)
            }
            digiliraPay.getOrder(PARAMS: ifQR as! String)
            DispatchQueue.main.async {
                self.throwEngine.alertTransaction(title: "Sipariş detayları", message:"Sipariş detaylarınız yükleniyor...", verifying: true)

            }
        }
        
  
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
        
        if let api = decodeDefaults(forKey: bex.bexApiDefaultKey.key, conformance: bex.bitexenAPICred.self) {
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
        
        if let isim = kullanici.firstName {
            walletView.ad_soyad = isim
            if let soyisim = kullanici.lastName {
                walletView.ad_soyad = isim + " " + soyisim
            } else {
                walletView.ad_soyad = "Satoshi Nakamoto"
            } 
        }else {
            walletView.ad_soyad = "Satoshi Nakamoto"
        }
        
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
        var name: String = "Satoshi Nakamoto"
        
        if let n = kullanici.firstName {
            name = n
            if let s = kullanici.lastName {
                name = n + " " + s
            }
        }
        return name
    }
    
    func setPaymentView() // payments ekranı
    {
        var cards: [digilira.cardData] = []
        
        var bitexen = turkish.bitexenCard
        let kizilay = turkish.kizilayCard
        let okex = turkish.okexCard
        
        if let api = decodeDefaults(forKey: bex.bexApiDefaultKey.key, conformance: bex.bitexenAPICred.self) {
            bitexen.cardNumber = "Hesap Bilgilerini Düzenle"
            if (api.valid) { // if bitexen api valid
                bitexen.apiSet = true
                bitexen.cardNumber = "Hesap Aktif"
                bitexen.cardHolder = getName()
            }
        }
        
        cards.append(bitexen)
        cards.append(okex)
        cards.append(kizilay)
        
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
        if Filtered.count == 0 {
            return 3
        }
        return Filtered.count
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
        goWalletScreen(coin: recognizer.assetName)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = UITableViewCell().loadXib(name: "CoinTableViewCell") as? CoinTableViewCell
        {
            let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
            tapped.floatValue = indexPath[1]
            cell.addGestureRecognizer(tapped)
            
            if Filtered.count > 0 {
                
                let asset = Filtered[indexPath[1]]
                cell.coinIcon.image = UIImage(named: asset.tokenSymbol)
                cell.coinName.text = asset.tokenName
                cell.type.text = "₺" + MainScreen.df2so(asset.tlExchange)
                tapped.assetName = asset.tokenName
                
                let double = MainScreen.int2so(asset.balance, digits: asset.decimal)
                
                cell.coinAmount.text = double
                
            }
            

            if Filtered.count == 0 {
                let demoin = digilira.demo[indexPath[1]]
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
        walletView.readHistory(coin: coin)
        
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

        let letsStartView4: Verify_StartView = UIView().loadNib(name: "Verify&StartView") as! Verify_StartView

        letsStartView4.delegate = self
        letsStartView4.frame = CGRect(x: 0,
                                      y: 0,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height)
        
        letsStartView4.backgroundColor = UIColor.white

        self.sendWithQRView.addSubview(letsStartView4)
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

extension MainScreen: OperationButtonsDelegate // Wallet ekranındaki gönder yükle butonlarının tetiklenmesi ve işlemleri
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
        newSendMoneyView.Coins = BC.returnCoins()
        newSendMoneyView.Ticker = Ticker
        newSendMoneyView.set()
        
        newSendMoneyView.recipientText.setTitle(transactionRecipient, for: .normal)
        
        if let assetId = params.assetId {
            do {
                let coin = try BC.returnAsset(assetId: assetId)
                let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                if params.amount != 0 {
                    newSendMoneyView.textAmount.text = (Double(params.amount!) / double).description
                }else{
                    newSendMoneyView.textAmount.text = ""
                }

            } catch  {
                print (error)
            }
        }
        
        
        newSendMoneyView.transaction = params
        newSendMoneyView.setQR()
        if params.destination == digilira.transactionDestination.interwallets {
            newSendMoneyView.recipientText.isEnabled = false
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
    
    func showMyFQr() {
        qrView.frame.origin.y = view.frame.height
        paraYatirView = UIView().loadNib(name: "ParaYatirView") as! ParaYatirView
        paraYatirView.frame.origin.y = self.view.frame.height
        paraYatirView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: view.frame.width,
                                    height: view.frame.height)
        paraYatirView.delegate = self
        paraYatirView.errors = self
        paraYatirView.Filtered = BC.returnCoins()
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
    
    func showBitexenView() {
        
        if  !digiliraPay.isKeyPresentInUserDefaults(key: bex.bexApiDefaultKey.key) {
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
        
        switch kullanici.status {
        case 0:
            let verifyProfileXib = UIView().loadNib(name: "VerifyAccountView") as! VerifyAccountView
            
            verifyProfileXib.frame = CGRect(x: 0,
                                            y: 0,
                                            width: view.frame.width,
                                            height: view.frame.height)
            
            verifyProfileXib.delegate = self
            verifyProfileXib.errors = self
            for subView in qrView.subviews
            { subView.removeFromSuperview() }
 
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
        case 3:
            throwEngine.alertWarning(title: "Onaylı Profil", message: "Profiliniz onaylanmıştır. Kripto paralarınızla alışveriş yapabilirsiniz", error: false)
            
            break
        default:
            print("ok")
            
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
    
    
    func goPageCardView(ORDER: digilira.order) {
        
        pageCardView = UIView().loadNib(name: "PageCardView") as! PageCardView
        pageCardView.frame.origin.y = self.view.frame.height
        pageCardView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: view.frame.width,
                                    height: view.frame.height)
        pageCardView.errors = self
        pageCardView.delegate = self
        pageCardView.Filtered = self.Filtered
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
    
    
    func goSelectCoinView(ORDER: digilira.order) {
        
        selectCoin = UIView().loadNib(name: "selectCoinView") as! selectCoinView
        sendWithQRView.frame.origin.y = self.view.frame.height
        selectCoin.frame = CGRect(x: 0,
                                  y: 0,
                                  width: view.frame.width,
                                  height: view.frame.height)
        selectCoin.delegate = self
        selectCoin.Filtered = self.Filtered
        selectCoin.Order = ORDER
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuView.isHidden = true
        
        sendWithQRView.addSubview(selectCoin)
        selectCoin.setupTableView()
        sendWithQRView.isHidden = false
        sendWithQRView.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.3)
        {
            self.sendWithQRView.frame.origin.y = 0
            self.sendWithQRView.alpha = 1
        }
        
    }
    
    func showSuccess(mode: Int, transaction: [String : Any]) {
        do {
            let asset = try BC.returnAsset(assetId: (transaction["assetId"] as?  String)!)
            let double = Double(truncating: pow(10,asset.decimal) as NSNumber)
            
            let amount:String = String((transaction["amount"] as? Float64)! / double)

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
        
        if let asset = external.assetId {
            do {
                let coin = try BC.returnAsset(assetId: asset)
                do {
                    let exchange = try digiliraPay.exchange(amount: external.amount!, coin: coin, symbol: digiliraPay.ticker(ticker: Ticker))
                    
                    digiliraPay.onMember = { res, data in
                        DispatchQueue.main.async {

                            var miktar: Int64 = 0
                            var attach = ""
                            
                            if data?.amount != nil {
                                miktar = data!.amount!
                            }
                            
                            if data?.message != nil {
                                attach = data!.message
                            }
                            
                                let trx = SendTrx.init(merchant: data?.owner!,
                                                       recipient: (data?.wallet)!,
                                                       assetId: data?.assetId!,
                                                       amount: miktar,
                                                       fee: digilira.sponsorTokenFee,
                                                       fiat: exchange,
                                                       attachment: attach,
                                                       network: data?.network!,
                                                       destination: data?.destination!,
                                                       massWallet: data?.wallet,
                                                       memberCheck: true
                                )
                                
                                self.send(params: trx)
                                

                        }
                        
                    }
                } catch {
                    throwEngine.evaluateError(error: error)
                }
                
                digiliraPay.isOurMember(external: external)
                
            } catch  {
                print (error)
            }
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
    
    func sendQR(ORDER: digilira.order) {
        
        digiliraPay.onAuth = { auth, sts in
           
        if (auth.status == 0) {
            self.alertError ()
            return
        }
        
        let odeme = digilira.odemeStatus.init(
            id: ORDER._id,
            status: "1",
            name: auth.firstName,
            surname: auth.lastName
        )
        
        self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
        
        let data = SendTrx.init(merchant: ORDER.merchant,
                                recipient: ORDER.wallet,
                                assetId: ORDER.asset!,
                                amount: ORDER.rate,
                                fee: digilira.sponsorTokenFee,
                                fiat: ORDER.totalPrice!,
                                attachment: ORDER._id,
                                network: digilira.transactionDestination.domestic,
                                products: ORDER.products
        )
            self.send(params: data)
        }
        
        digiliraPay.auth()
 
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

            
        digiliraPay.onUpdate = { res in
            
            DispatchQueue.main.async {
                
                self.throwEngine.warningView.removeFromSuperview()
                self.throwEngine.alertWarning(title: "Bilgileriniz Yüklendi", message: "Gönderdiğiniz bilgiler kontrol edildikten sonra profiliniz güncellenecektir.", error: false)
           
            self.digiliraPay.onLogin2 = { user, status in
                
                DispatchQueue.main.async {
                    self.dismissVErifyAccountView()
                }
            }
            
            self.digiliraPay.login2()
            }
        }
        
            throwEngine.alertTransaction(title: "Yükleniyor...", message: "Fotoğrafınız yükleniyor lütfen bekleyin.", verifying: true)
            
            let b64 = digiliraPay.convertImageToBase64String(img: image)
            let user = digilira.exUser.init(
                status:2,
                id1: b64
            )
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(user)
            
            digiliraPay.updateUser(user: data)
        }else {
            if let features = detectQRCode(image), !features.isEmpty{
                for case let row as CIQRCodeFeature in features{
                    
                    if (row.messageString != "") {
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
    
}


class depositeGesture: UITapGestureRecognizer {
    var floatValue:Float?
    var address: String?
    var qrAttachment: String = ""
    
}

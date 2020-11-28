//
//  MainScreen.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 25.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions
import RxSwift
import Locksmith
import Foundation
import Wallet
import UserNotifications

public let kNotification = Notification.Name("kNotification")


class MainScreen: UIViewController {
    
    
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
    @IBOutlet weak var headerTotal: UILabel!
    @IBOutlet weak var sendMoneyBackButton: UIImageView!
    @IBOutlet weak var sendWithQRView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    
    @IBOutlet var mainView: UIView!
    var profileViewXib: ProfileMenuView = ProfileMenuView()
    
    var contentScrollView = UIScrollView()
    var coinTableView = UITableView()
    var walletOperationView = WalletOperationButtonSView()
    var walletView: WalletView = WalletView()
    var menuXib: MenuView = MenuView()
    var sendMoneyView = CoinSendView()
    var loadMoneyView = QRView()
    var successView = TransactionPopup()
    var seedView = LetsStartWordsView()
    var paymentCat = PaymentCat()
    var profileMenuView = ProfileMenuView()
    var depositeMoneyView = DepositeMoneyView()
    let imagePicker = UIImagePickerController()
    var newSendMoneyView = newSendView()
    var selectCoin = selectCoinView()
    var pageCardView = PageCardView()
    var bitexenAPIView = BitexenAPIView()

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
    var isDepositeMoneyView = false
    var isNewSendScreen = false
    var isBitexenAPI = false
    var isVerifyAccount = false
    
    var isBitexenFetched = false
    var isBinanceFetched = false
    
    var isBitexenReload = false
    var isBinanceReload = false
    
    var isFetching = false
    
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
    
    private let refreshControl = UIRefreshControl()
    
    var isAlive = false
    var isNewPin = false
    var isFirstLaunch = true
    var isTouchIDCanceled = false
    
    var walletOperationsViewOrigin = CGPoint(x: 0, y: 0)
    
    var kullanici: digilira.auth = try! secretKeys.userData()
    var pinkodaktivasyon: Bool? = false
    
    var Balances: NodeService.DTO.AddressAssetsBalance?
    var Ticker: binance.BinanceMarketInfo = []
    var Filtered: [digilira.DigiliraPayBalance] = []
    var BitexenBalances:[bex.BalanceValue?] = []
    
    var bexTicker: bex.bexAllTicker?
    var bexMarketInfo: bex.bexMarketInfo?
    
    var onPinSuccess: ((_ result: Bool)->())?
    
    var headerHeightBuffer: CGFloat?
    var QR:digilira.QR = digilira.QR.init()
    
    let defaults = UserDefaults.standard

    let BC = Blockchain()
    let bitexenSign = bex()
    let binanceAPI = binance()
    
    let digiliraPay = digiliraPayApi()
    
    func checkEssentials() {
        if let versionLegal = UserDefaults.standard.value(forKey: "isLegalView") as? Int {
            let v = digilira.legalView.version
            if (versionLegal < v) {
                alertWarning(title: digilira.messages.newLegalViewTitle, message: digilira.messages.newLegalViewMessage)
                showLegalText()
            }
        }
        
        if let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse") as? Int {
            let v = digilira.termsOfUse.version
            if (versionTerms < v) {
                alertWarning(title: digilira.messages.newTermsOfUseTitle, message: digilira.messages.newTermsOfUseMessage)
                showTermsofUse()
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        coinTableView.refreshControl = refreshControl
        
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
        //        when requested asset balances
        
        bitexenSign.onBitexenBalance = { [self] balances, statusCode in
            if statusCode == 200 {
                for bakiye in balances.data.balances {
                    if Double(bakiye.value.balance)! > 0 {
                        for mrkt in (bexMarketInfo?.data.markets)! {
                            
                            if bakiye.value.currencyCode == mrkt.baseCurrency {
                                let coinPrice = bexTicker?.data.ticker[mrkt.marketCode]
                                let lastPrice = Double(bakiye.value.availableBalance)! * Double(coinPrice!.lastPrice)!
                                
                                let digiliraBalance = digilira.DigiliraPayBalance.init(
                                    tokenName: bakiye.value.currencyCode,
                                    tokenSymbol: "Bitexen " + bakiye.value.currencyCode,
                                    availableBalance: Int64(Double(bakiye.value.availableBalance)! * 100000000),
                                    balance: Int64(Double(bakiye.value.balance)! * 100000000),
                                    tlExchange: lastPrice)
                                
                                totalBalance += lastPrice
                                setHeaderTotal()
                                Filtered.append(digiliraBalance)
                                 
                                self.BitexenBalances.append(bakiye.value)
                            }
                            
                        }

                }
                }
                coinTableView.reloadData()
   
            }
            
        }
         
        BC.onAssetBalance = { [self] result in
            
            for asset1 in result.balances {
                let asset = BC.returnAsset(assetId: asset1.assetId)
                if (asset != "") {
                    
                    
                    let ticker = digiliraPay.ticker(ticker: Ticker)
                    var coinPrice:Double = 0
                    
                    switch asset {
                    case "Bitcoin":
                        coinPrice = (ticker.btcUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / Double(100000000)
                        break
                    case "Ethereum":
                         coinPrice = (ticker.ethUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / Double(100000000)
                        break
                    case "Kızılay Token":
                         coinPrice = 1 * Double(asset1.balance) / Double(100000000)
                        break
                    case "Waves":
                         coinPrice = (ticker.wavesUSDPrice)! * (ticker.usdTLPrice)! * Double(asset1.balance) / Double(100000000)
                        break
                    default:
                         coinPrice = 0
                        break
                    }
                    
                    let digiliraBalance = digilira.DigiliraPayBalance.init(
                        tokenName: asset,
                        tokenSymbol: asset1.issueTransaction.name,
                        availableBalance: asset1.balance,
                        balance: asset1.balance,
                        tlExchange: coinPrice)
                
                         
                    totalBalance += coinPrice
                    
                    Filtered.append(digiliraBalance)
                    
                }
            }
             

            self.coinTableView.reloadData()
            self.headerTotal.fadeTransition(0.4)
            self.setHeaderTotal()
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

            if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
                QR = qr
                self.getOrder(address: QR)
            }
        }
        
        BC.onMassTransaction = { res in
            print(res)
            let txid = res.dictionary["id"] as? String
            
            DispatchQueue.main.async {
                self.showSuccess(mode: 1, transaction: res.dictionary)
            }
            self.bottomView.isHidden = true
            self.closeCoinSendView()
            self.goHomeScreen()
            
            self.BC.verifyTrx(txid: txid!)
            
            self.bottomView.isHidden = true
            self.closeCoinSendView()
            self.goHomeScreen()
        }
        
        
        BC.onTransferTransaction = { res in
//            let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res.dictionary["attachment"] as! String)!), as: UTF8.self)
            let txid = res.dictionary["id"] as? String
            
            DispatchQueue.main.async {
                self.showSuccess(mode: 1, transaction: res.dictionary)
            }
            self.bottomView.isHidden = true
            self.closeCoinSendView()
            self.goHomeScreen()
            
            self.BC.verifyTrx(txid: txid!)
            
        }
        
        BC.onVerified = { res in
            print("verified verified verified")
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
            
            DispatchQueue.main.async {
            switch res {
            case "SSL PINNING MISMATCH":
                let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu anda işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: { _ in
                    exit(1)
                }))
                
                self.present(alert, animated: true, completion: nil)
            default:
                print("digilirapayError", res)
//                let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu anda işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
            }
            }
            
        }
        
        BC.onError = { res in
            switch res {
            case "Canceled by user.":
                self.closeCoinSendView()
                break
            case "Fallback authentication mechanism selected.":
                self.isTouchIDCanceled = true
                self.openPinView()
                break
            case "The operation couldn’t be completed. (WavesSDK.NetworkError error 0.)":
                let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu an işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                self.closeSendView()
                break
            default:
                print("blockchain", res)
//                let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu anda işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
                break
                
            }
            
        }
        
        
        bitexenSign.onBitexenError = { res, sts in
            
            DispatchQueue.main.async {
            self.shake()
            
            let alert = UIAlertController(title: "Bitexen API", message: "Bitexen API bilgileriniz hatalıdır.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            self.present(alert, animated: true)
            }
            
            print("bitexenError", res)
//                let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu anda işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
             
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Güncellemek için çekiniz..")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCompleteTask(_:)), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrxCompleted), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onOrderClicked), name: .orderClick, object: nil)
        
        
        
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark{
            
            IQKeyboardManager.shared.keyboardAppearance = .dark
            mainView.backgroundColor = UIColor.black
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
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
    
    func isTokenOK() {
        let token = kullanici.token
        let jwt = token.split(separator: ".")
        
        if let decodedData = Data(base64Encoded: String(jwt[1])) {
            if let jwtPayload = digiliraPay.decodeDefaults(forKey: decodedData, conformance: JwtPayload.self) {
                let now = Date().millisecondsSince1970
                let then : Int64 = jwtPayload.exp * Int64(1000)
                
                let diff = ((then - now) / Int64(1000)) / 60
                
                if diff < 5 {
                    
                    self.digiliraPay.onLogin2 = { user, status in
                        DispatchQueue.main.sync {
                            self.kullanici = user
                        }
                    }
                    
                    self.digiliraPay.login2()
                    
                    
                }
            }
        }
        
    }
    
    @objc func onDidCompleteTask(_ sender: Notification) {
        isTokenOK()
    }
    
    static func df2so(_ price: Double, digits: Int = 2) -> String{
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = "."
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = ","
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = digits
            return numberFormatter.string(from: price as NSNumber)!
        }
    
    static func int2so(_ price: Int64, digits: Int = 8) -> String{
            let double = Double(price) / Double(100000000)
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = "."
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = ","
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = digits
            return numberFormatter.string(from: double as NSNumber)!
        }
    
    func setHeaderTotal() {
        headerTotal.text = "₺" + MainScreen.df2so(totalBalance)
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
            if (isDepositeMoneyView) {
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
                    surname: self.kullanici.lastName
                )
                
                self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
                
                self.goPageCardView(ORDER: res)

                //self.sendQR(ORDER: res)
                
            }
            digiliraPay.getOrder(PARAMS: address.address!)
        }
        
    }
    
    @objc func onDidReceiveData(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        
        if (isDepositeMoneyView) {
            closeDeposite()
        }
        
        if let qr = decodeDefaults(forKey: "QRARRAY2", conformance: digilira.QR.self, setNil: true) {
            QR = qr
            self.getOrder(address: QR)
        }

//        if let savedQR = defaults.object(forKey: "QRARRAY2") as? Data {
//            let decoder = JSONDecoder()
//            let loadedQR = try? decoder.decode(digilira.QR.self, from: savedQR)
//            QR = loadedQR!
//            if (self.QR.address != nil) {
//                getOrder(address: self.QR)
//                self.QR = digilira.QR.init()
//                UserDefaults.standard.set(nil, forKey: "QRARRAY2")
//            }
//        }
        if (isSuccessView) {
            self.close()
        }
        
        if isVerifyAccount {
            self.dismissVErifyAccountView()
        }
        
    }
    
    @objc func onTrxCompleted(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        print("ok")
    }
    
    @objc func onOrderClicked(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        //        print(sender.userInfo)
        
        let alert = UIAlertController(title: "Sipariş detayları", message: "Sipariş detayları için kendinize iyi bakın.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        
        
        
        
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
        view.endEditing(true)
    }
    
    
    @objc private func refreshData(_ sender: Any) {
        if isSuccessView {
            refreshControl.endRefreshing() // dogrulama ekraninda guncelleme yapilmasin
            return
        }
        let lamda = Date()
        let differenceInSeconds = lamda.timeIntervalSince(lastBinanceCheck)
        
        if differenceInSeconds > 10  {
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
        
        Filtered.removeAll()
        totalBalance = 0
        
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
                            }
                        }
                    }
                    bitexenSign.getTicker()
                }
                bitexenSign.getMarketInfo()
                isBitexenFetched = false
            }else {
                isBitexenFetched = true //is bex not valid do not wait
            }
        }else {
            isBitexenFetched = true //is bex not valid do not wait
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
        headerView.layer.cornerRadius = 5
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
        
        profileViewXib = UIView().loadNib(name: "ProfileMenuview") as! ProfileMenuView
        profileViewXib.delegate = self
        profileViewXib.frame = CGRect(x: 0,
                                      y: 0,
                                      width: profileView.frame.width,
                                      height: profileView.frame.height)
        profileView.addSubview(profileViewXib)
        
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
        
        
        walletView.kullanici = self.kullanici
//        walletView.coin = "Ethereum"
        
        walletView.layer.zPosition = 0
        
        walletView.frameValue = walletView.frame
        walletView.setView()
        walletView.ViewOriginMaxXValue.y = menuView.frame.height
        contentScrollView.addSubview(walletView)
        
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
        
        if isFirstLaunch {
            //
            if pinkodaktivasyon! {
                if kullanici.pincode == "-1" {
                    openPinView()
                }
            }
        }
        
    }
     
    func setSettingsView() {
        profileMenuView = UIView().loadNib(name: "ProfileMenuview") as! ProfileMenuView
        profileMenuView.frame = CGRect(x: contentView.frame.width * 3,
                                       y: 0,
                                       width: contentView.frame.width,
                                       height: contentView.frame.height)
        
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

        var bitexen = digilira.cardData.init(
            org: "Bitexen",
            bgColor: UIColor(red: 0.1882, green: 0.2588, blue: 0.3804, alpha: 1.0),
            logoName: "logo_bitexen",
            cardHolder:  "",
            cardNumber: "Bitexen Hesabı Ekle",
            remarks: "Bitexen hesabınızı DigiliraPAY'e bağlayarak hesabınızdaki bakiyelerinizi kullanarak alışveriş yapabilirsiniz.",
            apiSet: false,
            bg: "bexbg"
        )
        
        if let api = decodeDefaults(forKey: bex.bexApiDefaultKey.key, conformance: bex.bitexenAPICred.self) {
            bitexen.cardNumber = "Hesap Bilgilerini Düzenle"
            if (api.valid) { // if bitexen api valid
                bitexen.apiSet = true
                bitexen.cardNumber = "Hesap Aktif"
                bitexen.cardHolder = getName()
                bitexen.remarks = "Alışverişlerinizde Bitexen hesabınızdaki bakiyelerinizi kullanabilirsiniz."
            }
        }
        
        cards.append(bitexen)
        
        let okex = digilira.cardData.init(
            org: "Okex",
            bgColor:  UIColor(red: 0.0431, green: 0.1294, blue: 0.3843, alpha: 1.0), /* #0b2162 */
            logoName: "logo_okex",
            cardHolder:  "",
            cardNumber: "Okex Hesabı Ekle",
            remarks: "OKEX hesabınıza giriş yapın, Ayarlar bölümünden Erişim Ayarlarını belirleyin.",
            apiSet: false

        )
        
        cards.append(okex)
        
        let kizilay = digilira.cardData.init(
            org: "Kızılay",
            bgColor:  UIColor(red: 0.7529, green: 0.0039, blue: 0, alpha: 1.0), /* #c00100 */
            logoName: "logo_kizilay",
            cardHolder:  "",
            cardNumber: "Kızılay",
            remarks: "Kızılay'a kripto varlıklarınızı kullanarak bağış yapabilirsiniz.",
            apiSet: false

        )
        
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
         
        //profileMenuButton.isHidden = false
        closeCoinSendView()
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
//
//            let asset = BC.returnAsset(assetId: (Filtered[indexPath[1]]?.issueTransaction.assetId)!)
//            cell.coinIcon.image = UIImage(named: asset)
//            cell.coinName.text = asset
//            tapped.assetName = asset
//
//            let double = Double(Filtered[indexPath[1]]!.balance) / Double(100000000)
//            cell.coinAmount.text = (double).description
//            cell.coinCode.text = (Filtered[indexPath[1]]!.issueTransaction.name)
//
//
            if Filtered.count > 0 {
                
                let asset = Filtered[indexPath[1]]
                cell.coinIcon.image = UIImage(named: asset.tokenName)
                cell.coinName.text = asset.tokenName
                cell.type.text = "₺" + MainScreen.df2so(asset.tlExchange)
                tapped.assetName = asset.tokenName

                let double = Double(asset.balance) / Double(100000000)
                cell.coinAmount.text = MainScreen.df2so(double, digits: 8)
                cell.coinCode.text = (asset.tokenSymbol)

                
                
            }
            
            return cell
            
        }
        else
        { return UITableViewCell() }
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
        
        headerTotal.isHidden = true
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        walletOperationView.removeFromSuperview()
        
        if isShowWallet
        {
            headerInfoLabel.isHidden = true
            closeCoinSendView()
            isShowWallet = false
        }
        
        if isHomeScreen {
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.walletOperationView.removeFromSuperview()
                self.contentScrollView.contentOffset.x = 0
            }
        }
        
        headerInfoLabel.isHidden = true
        homeAmountLabel.isHidden = true
        logoView.isHidden = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.contentScrollView.contentOffset.x = self.view.frame.width * 2
        }) { (_) in
            self.walletOperationsViewOrigin = self.walletOperationView.frame.origin
        }
        isShowSettings = false
        isPayments = true
        isHomeScreen = false
    }
    
    func goSettings() {
        menuXib.settings()
        
        
        dismissLoadView()
        dismissProfileMenu()
        headerTotal.isHidden = true
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if isShowWallet
        {
            headerInfoLabel.isHidden = true
            closeCoinSendView()
            isShowWallet = false
            
        }
        if isHomeScreen {
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.walletOperationView.removeFromSuperview()
                self.contentScrollView.contentOffset.x = 0
            }
            isHomeScreen = false
        }
        headerInfoLabel.isHidden = true
        homeAmountLabel.isHidden = true
        logoView.isHidden = false
        menuXib.isHidden = false
        
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
        menuXib.home()
         
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if isShowWallet
        {
            headerInfoLabel.isHidden = true
            closeCoinSendView()
            isShowWallet = false
        }
        
        if !isHomeScreen {
            walletOperationView = UIView().loadNib(name: "WalletOperationButtonSView") as! WalletOperationButtonSView
            walletOperationView.frame = CGRect(x: 0,
                                               y: homeAmountLabel.frame.maxY + 10,
                                               width: view.frame.width,
                                               height: 100)
            walletOperationView.delegate = self
            walletOperationView.alpha = 1
             
            UIView.animate(withDuration: 0.3) {
                self.headerView.addSubview(self.walletOperationView)
                self.contentScrollView.contentOffset.x = 0
                self.headerView.frame.size.height =  self.walletOperationView.frame.maxY
            }
        }
         
        if !isSuccessView {
            bottomView.isHidden = false
        }
        
        if isPayments || isShowSettings {
            isPayments = false
            isShowSettings = false
        }
        
        headerInfoLabel.isHidden = true
        headerInfoLabel.textColor = .black
        headerTotal.isHidden = false
        homeAmountLabel.isHidden = true
        
        logoView.isHidden = true
        menuXib.isHidden = false
         
        isHomeScreen = true

    }
    
    func goWalletScreen(coin: String)
    {
        
        menuXib.wallet()
        walletView.coin = coin
        walletView.readHistory(coin: coin)
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        
        if isHomeScreen {
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                self.walletOperationView.removeFromSuperview()
                self.contentScrollView.contentOffset.x = 0
            }
        }
        walletOperationView.removeFromSuperview()
        
        if !isShowWallet
        {
            isShowWallet = true
            
            logoView.isHidden = false
            headerTotal.isHidden = true
            
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
        if !isShowSettings
        {
            isShowSettings = true
            dismissLoadView()
            closeCoinSendView()
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
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuXib.isHidden = true
        
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
        
        let letsStartView4: LetsStartWordsView = UIView().loadNib(name: "LetsStartWordView") as! LetsStartWordsView
        
        letsStartView4.delegate = self
        
        letsStartView4.setTitles(title: "Anahtar kelimelerini", subTitle: "asla kaybetme!", desc: "Eğer uygulaman silinirse veya cüzdanını başka bir cihaza aktarman gerekirse bu kelimelere ihtiyaç duyacaksın.")
        letsStartView4.frame = CGRect(x: 0,
                                      y: 100,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height)
        
        letsStartView4.backgroundColor = UIColor.white
        letsStartView4.okButtonView.isHidden = false
        
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
            newSendMoneyView.setQR(params: params)
            return
        }
        
        isNewSendScreen = true
        
        if (isDepositeMoneyView) {
            shake()
            return
        }
         
        newSendMoneyView = UIView().loadNib(name: "newSendView") as! newSendView
        newSendMoneyView.ticker = digiliraPay.ticker(ticker: Ticker)

        sendWithQRView.frame.origin.y = self.view.frame.height
        newSendMoneyView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: view.frame.width,
                                        height: view.frame.height)
        newSendMoneyView.delegate = self
        
        newSendMoneyView.recipientText.text = transactionRecipient
        if params.amount != 0 {
            newSendMoneyView.textAmount.text = (Double(params.amount!) / Double(100000000)).description
        }else{
            newSendMoneyView.textAmount.text = ""
        }
        newSendMoneyView.coinSwitch.setTitle(params.fiat!.description + " ₺", forSegmentAt: 0)
        newSendMoneyView.coinSwitch.setTitle((Double(params.amount!) / Double(100000000)).description + " " + params.network!, forSegmentAt: 1)
        
        var networkLabel = params.network?.capitalized
        
        if networkLabel == "" {
            networkLabel = "Cüzdan Seçin"
        }
        newSendMoneyView.adresBtn.setTitle(networkLabel, for: .normal)
        

        newSendMoneyView.transaction = params
        if params.destination == digilira.transactionDestination.interwallets {
            newSendMoneyView.adresBtn.isEnabled = false
            newSendMoneyView.recipientText.isEnabled = false
        }
        
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuXib.isHidden = true
        
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
    
    
    
    func showMyQr() {
        
        
        isShowLoadCoinView = true
        qrView.frame.origin.y = view.frame.height
        loadMoneyView = UIView().loadNib(name: "QRView") as! QRView
        loadMoneyView.frame = qrView.frame
        loadMoneyView.delegate = self
        
        loadMoneyView.address = selectedCoin
        
        for subView in qrView.subviews
        { subView.removeFromSuperview() }
        
        qrView.addSubview(loadMoneyView)
        qrView.isHidden = false
        qrView.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.3)
        {
            self.qrView.alpha = 1
            self.qrView.frame.origin.y = 0
            self.loadMoneyView.frame.origin.y = 0
            self.sendMoneyBackButton.isHidden = false
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoadMoney" {
            if let viewController = segue.destination as? ShareQRVC {
                viewController.ticker = digiliraPay.ticker(ticker: Ticker)

            }
        }
        
        

    }
    
    
    func showDepositeMoneyView (mode: Int, source: String) {
        
        isDepositeMoneyView = true
        depositeMoneyView = UIView().loadNib(name: "DepositeMoneyView") as! DepositeMoneyView
        
        depositeMoneyView.frame = CGRect(x: contentScrollView.frame.width  + (contentScrollView.frame.width / 20),
                                         y: contentScrollView.frame.maxY,
                                         width: contentScrollView.frame.width - ( contentScrollView.frame.width  / 10),
                                         height: contentScrollView.frame.width)
        
        depositeMoneyView.delegate = self
        
        depositeMoneyView.transferMode = mode
        depositeMoneyView.network = "ethereum"
        depositeMoneyView.source = source
        
        depositeMoneyView.layer.shadowColor = UIColor.black.cgColor
        depositeMoneyView.layer.shadowOpacity = 0.4
        depositeMoneyView.layer.shadowOffset = .zero
        depositeMoneyView.layer.shadowRadius = 3
        depositeMoneyView.layer.cornerRadius = 20
        depositeMoneyView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        bottomView.isHidden = true
        menuView.isHidden = true
        self.contentScrollView.addSubview(depositeMoneyView)
        self.contentScrollView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.depositeMoneyView.frame.origin.y = self.contentScrollView.frame.maxY -  self.depositeMoneyView.frame.height - self.headerView.frame.height + self.menuView.frame.height
            self.depositeMoneyView.alpha = 1
        }
        
        
    }
    
    func load()
    {
        if (isDepositeMoneyView) {
            shake()
            return
        }
        
        if kullanici.status == 0 {
            alertError()
            return
        }else {
            performSegue(withIdentifier: "showLoadMoney", sender: nil)

        }
        
        
        //showMyQr()
        
        //        showDepositeMoneyView(mode: 1, source:"PEP Para")
        
        
    }
    
    
    
    func alertConfirm (title: String, message: String)-> Void {
        
        
    }
}



extension MainScreen: TransactionPopupDelegate2 {
    func close() {
        
        menuView.isHidden = false
        isNewSendScreen = false
        dismissNewSend()
        
        //accountButton.isHidden = false
        //profileMenuButton.isHidden = false
        
        UIView.animate(withDuration: 1) {
            self.fetch()
            self.successView.frame.origin.y = (self.contentView.frame.maxY)
            self.successView.alpha = 0
            self.isSuccessView = false
            self.bottomView.isHidden = false
            self.walletOperationView.isUserInteractionEnabled = true
            
            for subView in self.qrView.subviews
            { subView.removeFromSuperview() }
            
        }
        
    }
    
    
}

extension MainScreen: DepositeMoneyDelegate {
    
    func closeDeposite() {
        isDepositeMoneyView = false
        UIView.animate(withDuration: 1) {
            self.menuView.isHidden = false
            self.bottomView.isHidden = false
            
            self.depositeMoneyView.frame.origin.y = self.contentScrollView.frame.maxY
            self.depositeMoneyView.alpha = 1
        }
    }
    
    func confirmInternalWallet (amount: Float, fiat: Float, network: String, address: String, source: String) {
        
        
        let fiatString = String(fiat)
        let amountString = String(amount)
        let message = source + " hesabınızdan ₺" + fiatString + " karşılığında " + amountString + " " + network + " cüzdanınıza tanımlanacaktır. Onaylıyor musunuz?"
        
        
        self.digiliraPay.onTouchID = { res, err in
            if res == true {
                
                
                
            } else {
                
                print(err)
                
                if (err == "Canceled by user.") {return}
                
                let alert = UIAlertController(title: "title", message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Evet", style: UIAlertAction.Style.default, handler: {action in
                    //ok
                }))
                
                alert.addAction(UIAlertAction(title: "Hayır", style: UIAlertAction.Style.default, handler: {action in
                    //nine
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        self.digiliraPay.touchID(reason: message)
        
    }
    
}


extension MainScreen: SendCoinDelegate // Wallet ekranı gönderme işlemi
{
    func getQR() {
        chooseQRSource()
    }
    
    func sendCoin(params:SendTrx) // gelen parametrelerle birlikte gönder butonuna basıldı.
    {
        let ifPin = kullanici.pincode
        
        if ifPin == "-1" {
            openPinView()
        }else {
            
            
            BC.onSensitive = { [self] wallet, err in
                switch err {
                case "ok":
                    
                    switch params.destination {
                    case digilira.transactionDestination.domestic:
                        BC.sendTransaction2(recipient: params.recipient!, fee: digilira.sponsorTokenFee, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment!, wallet:wallet)
                        break
                    case digilira.transactionDestination.foreign:
                        print(params)
                        break
                    case digilira.transactionDestination.interwallets:
                        BC.massTransferTx(recipient: params.recipient!, fee: 1100000, amount: params.amount!, assetId: params.assetId!, attachment: "", wallet: wallet)
                        print(params)
                        break
                    default:
                        return
                    }
                    
                    break
                case "Canceled by user.":
                    let alert = UIAlertController(title: "İptal", message: "İşleminiz iptal edilmiştir.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    //self.closeSendView()
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
                        let alert = UIAlertController(title: "İptal", message: "İşleminiz iptal edilmiştir.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        //self.closeSendView()
                    }
                    break
                }
                
            }
            
            
            BC.getSensitive(pin:false)
            
        }
        
        
        
    }
    
    func closeCoinSendView()
    {
        //self.QR = [] //qr bilgisi sifirlama
        if isShowSendCoinView
        {
            isShowSendCoinView = false
            
            if isShowWallet {
                
                logoView.isHidden = true
                headerInfoLabel.isHidden = false
                homeAmountLabel.isHidden = false
                
            }else {
                
                headerInfoLabel.isHidden = true
                homeAmountLabel.isHidden = true
            }
            
            sendMoneyBackButton.isHidden = true
            
            //            let headerHeight = headerView.frame.size.height
            sendMoneyView.removeFromSuperview()
            //            let buffer = sendMoneyView.sendView.frame.maxY
            UIView.animate(withDuration: 0.4, animations: {
                self.headerView.frame.size.height = self.headerHeightBuffer!
            }) { (_) in
                
                self.walletOperationView.translatesAutoresizingMaskIntoConstraints = true
                self.walletOperationView.frame = CGRect(x: 0,
                                                        y: self.homeAmountLabel.frame.maxY + 15,
                                                        width: self.view.frame.width,
                                                        height: self.view.frame.height)
                self.walletOperationView.alpha = 1
                
            }
            
            
            
        }
        
    }
}

extension MainScreen: BitexenAPIDelegate
{
    func dismissBitexen() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }) { (_) in
            
        }
        menuXib.isHidden = false
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
            for subView in qrView.subviews
            { subView.removeFromSuperview() }
            
            menuXib.isHidden = true
            
            
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
            
            verifyProfileXib.delegate = self
            for subView in qrView.subviews
            { subView.removeFromSuperview() }
            
            menuXib.isHidden = true
            
            qrView.addSubview(verifyProfileXib)
            qrView.isHidden = false
            qrView.translatesAutoresizingMaskIntoConstraints = true
            closeProfileView()
            
            UIView.animate(withDuration: 0.3)
            {
                self.qrView.frame.origin.y = 0
                self.qrView.alpha = 1
            }
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
        newSendMoneyView.delegate = self
        
        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuXib.isHidden = true
        
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
        pageCardView.delegate = self
        pageCardView.Filtered = self.Filtered
        pageCardView.Ticker = Ticker
        pageCardView.Order = ORDER

        for subView in sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        menuXib.isHidden = true
        
        sendWithQRView.addSubview(pageCardView)

//        pageCardView.setScrollView()
//        pageCardView.setTableView()
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
        
        menuXib.isHidden = true
        
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
    
    
    func showSuccess(mode: Int, transaction: [String : Any])
    {
        
        let asset = BC.returnAsset(assetId: (transaction["assetId"] as?  String)!)
        var amount: String
        var title: String
        
        switch transaction["type"] as? Int {
        case 11:
            amount = String ((transaction["totalAmount"] as? Float64)! / (100000000))
            title = "TRANSFERİNİZ GERÇEKLEŞTİ"
            
        default:
            amount = String ((transaction["amount"] as? Float64)! / (100000000))
            title = "ÖDEME BAŞARILI"
            
        }
        
        print("ÖDEME")
        
        if isSuccessView {
            
            walletOperationView.isUserInteractionEnabled = false
            
            successView.titleLabel.text = title
            successView.remainingAmount.text = amount + " " + asset
            successView.remainingAmountInfoLabel.text = "Gönderildi!"
            successView.infoLabel.text = ""
            
            successView.buttonLabrl.text = "Tamam"
            
            successView.remainingAmount.isHidden = false
            successView.headerImage.isHidden = false
            successView.headerImage.image = UIImage(named: "sendericon")!
            successView.buttonView.isHidden = false
            successView.backgroundColor = UIColor(red: 0.39, green: 0.91, blue: 0.39, alpha: 1.00)
        }else {
            
            walletOperationView.isUserInteractionEnabled = false
            successView = UIView().loadNib(name: "TransactionPopup") as! TransactionPopup
            successView.remainingAmountInfoLabel.textColor = UIColor.black
            
            successView.frame = CGRect(x: 20,
                                       y: contentScrollView.frame.maxY,
                                       width: contentScrollView.frame.width - 40,
                                       height: contentScrollView.frame.width - 100 )
            
            
            menuView.isHidden = true
            bottomView.isHidden = true
            
            successView.titleLabel.text = "DOĞRULANIYOR"
            successView.backgroundColor = UIColor.white
            
            successView.remainingAmount.text = amount + " " + asset
            successView.remainingAmountInfoLabel.text = "Gönderiliyor.."
            successView.infoLabel.text = "Transferiniz blokzincire yazılıyor."
            
            
            
            successView.headerImage.image = UIImage(named: "transactionTime")!
            successView.headerImage.isHidden = false
            successView.buttonView.isHidden = true
            
            successView.remainingAmount.isHidden = false
            
            isSuccessView = true
            
            successView.layer.shadowColor = UIColor.black.cgColor
            successView.layer.shadowOpacity = 0.4
            successView.layer.shadowOffset = .zero
            successView.layer.shadowRadius = 3
            successView.layer.cornerRadius = 20
            successView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            
            
            successView.delegate = self
            
            contentScrollView.addSubview(successView)
            contentScrollView.isHidden = false
            
            UIView.animate(withDuration: 0.4) {
                self.successView.frame.origin.y = self.contentScrollView.frame.maxY - self.successView.frame.height * 2
                self.successView.alpha = 1
            }
            
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
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
    
    
    func qrError(error: String) {
        switch error {
        case "notDP":
            let alert = UIAlertController(title: digilira.messages.qrErrorHeader, message: digilira.messages.qrErrorMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                self.isShowQRButton = false
                UIView.animate(withDuration: 0.3) {
                    self.sendWithQRView.frame.origin.y = self.self.view.frame.height
                    self.sendWithQRView.alpha = 0
                }
            }))
            
            
            self.present(alert, animated: true)
        default:
            break
        }
    }
    
    func sendBTCETH (external: digilira.externalTransaction, ticker: digilira.ticker) {
        let exchange = digiliraPay.exchange(amount: external.amount!, network: external.network!, assetId: external.assetId!, symbol: digiliraPay.ticker(ticker: Ticker))
        
        digiliraPay.onMember = { res, data in
            DispatchQueue.main.async {
                switch res {
                case true:
                    let trx = SendTrx.init(merchant: data?.owner!,
                                           recipient: (data?.wallet)!,
                                           assetId: data?.assetId!,
                                           amount: data?.amount!,
                                           fee: digilira.sponsorTokenFee,
                                           fiat: exchange,
                                           attachment: data?.message,
                                           network: data?.network!,
                                           destination: data?.destination!,
                                           massWallet: data?.wallet,
                                           memberCheck: true
                    )
                    
                    self.send(params: trx)
                    
                default:
                    return
                }
            }
            
            
            
        }
        
        
        
        digiliraPay.isOurMember(external: external)
        
        
    }
    
    func sendQR(ORDER: digilira.order) {
        
        let auth = digiliraPay.auth()
        
        if (auth.status == 0) {
            alertError ()
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
        send(params: data)
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
        
        if let features = detectQRCode(image), !features.isEmpty{
            for case let row as CIQRCodeFeature in features{
                
                if (row.messageString != "") {
                    OpenUrlManager.onURL = { [self] res in
                        getOrder(address: res)
                    }
                    print(row.messageString!)
                    OpenUrlManager.parseUrlParams(openUrl: URL(string: row.messageString!))
                }
                
                self.imagePicker.dismiss(animated: true, completion: {
                    
                })
            }
        }
    }
}

extension MainScreen: UINavigationControllerDelegate {
    
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
            alertWarning(title: "Yapım Aşamasında", message: "OKEX API bağlantısı yapım aşamasındadır.")
        default:
            break
        }
         print(data)
    }
    
    
}


extension MainScreen: seedViewDelegate {
    func closeSeedView() {
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
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
        
        UIView.animate(withDuration: 0.3) {
            self.qrView.frame.origin.y = self.view.frame.height
        }
        for subView in self.qrView.subviews
        { subView.removeFromSuperview() }
    }
    
    func shareQR(image: UIImage?) {
        
    }
    
    func errorHandler(message: String) {
        alertWarning(title: "Bir Hata Oluştu", message: message)
    }
}

extension MainScreen: VerifyAccountDelegate
{
    func dismissVErifyAccountView() // profil doğrulama sayfasının kapatılması
    {
        
        if QR.address != nil {
            UserDefaults.standard.set(nil, forKey: "QRARRAY2")
            getOrder(address: self.QR)
            self.QR = digilira.QR.init()
            
        }
        
        do {
            try self.kullanici = secretKeys.userData()
        } catch {
            print("")
        }
        
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.3) {
                self.qrView.frame.origin.y = self.view.frame.height
                self.qrView.alpha = 0
            }
            menuXib.isHidden = false
            bottomView.isHidden = false
            isVerifyAccount = false
            
        }
    }
}



extension MainScreen: LegalDelegate // kullanım sözleşmesi gibi view'ların gösterilmesi
{
    func showLegal(mode: digilira.terms)
    {
        profileSettingsView.frame.origin.y = view.frame.height
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
            self.profileSettingsView.frame.origin.y = 0
        }) { (_) in
            
        }
    }
    
    func dismissLegalView()
    {
        UIView.animate(withDuration: 0.4, animations: {
            self.profileSettingsView.frame.origin.y = self.view.frame.height
        })
        
        for subView in profileSettingsView.subviews
        { subView.removeFromSuperview() }
    }
}

extension MainScreen: SendWithQrDelegate
{
    

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
            self.menuXib.isHidden = false
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
    
    func alertWarning (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: digilira.prompt.ok, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    
}



extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
    static let orderClick = Notification.Name("orderClick")
}


extension MainScreen: PageCardViewDeleGate
{
    func cancel1(id: String) {
        fetch()
        isNewSendScreen = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }
        for subView in self.sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        let odeme = digilira.odemeStatus.init(
            id: id,
            status: "5"
        )
        
        self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
        
    }
    func dismissNewSend1(params: digilira.order) {
        fetch()
        isNewSendScreen = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }
        for subView in self.sendWithQRView.subviews
        { subView.removeFromSuperview() }
         
        let data = SendTrx.init(merchant: params.merchant,
                                recipient: params.wallet,
                                assetId: params.asset!,
                                amount: params.rate,
                                fee: digilira.sponsorTokenFee,
                                fiat: params.totalPrice!,
                                attachment: params._id,
                                network: digilira.transactionDestination.domestic,
                                destination: digilira.transactionDestination.domestic,
                                products: params.products
        )
        
        sendCoinNew(params: data)
        
        
        
        
    }
    
    func selectCoin1(params: String) {
        print(params)
    }
     
}

extension MainScreen: SelectCoinViewDelegate
{
    func cancel() {
        fetch()
        isNewSendScreen = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }
        for subView in self.sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
    }
    func dismissNewSend(params: digilira.order) {
        fetch()
        isNewSendScreen = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }
        for subView in self.sendWithQRView.subviews
        { subView.removeFromSuperview() }
        
        self.sendQR(ORDER: params)
    }
    
    func selectCoin(params: String) {
        print(params)
    }
     
}

extension MainScreen: NewCoinSendDelegate
{
    func dismissNewSend()
    {
        isNewSendScreen = false
        menuXib.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.view.frame.height
        }
        for subView in self.sendWithQRView.subviews
        { subView.removeFromSuperview() }
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
                        BC.sendTransaction2(recipient: params.recipient!, fee: digilira.sponsorTokenFee, amount: params.amount!, assetId: params.assetId!, attachment: params.attachment!, wallet:wallet)
                        break
                    case digilira.transactionDestination.foreign:
                        BC.massTransferTx(recipient: params.recipient!, fee: digilira.sponsorTokenFeeMass, amount: params.amount!, assetId: params.assetId!, attachment: "", wallet: wallet)
                        print(params)
                        break
                    case digilira.transactionDestination.interwallets:
                        BC.massTransferTx(recipient: params.recipient!, fee: digilira.sponsorTokenFeeMass, amount: params.amount!, assetId: params.assetId!, attachment: "", wallet: wallet)
                        print(params)
                        break
                    default:
                        return
                    }
                    
                    break
                case "Canceled by user.":
                    let alert = UIAlertController(title: "İptal", message: "İşleminiz iptal edilmiştir.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController(title: "Hatalı Pin Kodu", message: "İşleminiz iptal edilmiştir.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        //self.closeSendView()
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
                let alert = UIAlertController(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                pinView.isInit = true
            }
        }else {
            
            if kullanici.pincode != "-1" {
                pinView.isEntryMode = false
                pinView.isUpdateMode = true
            }else{
                let alert = UIAlertController(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alert, animated: true)
                
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
            goNewSendView()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
        }
        
        
        
        
        
    }
    
    func updatePinCode (code:Int32) {
        let user = digilira.pin.init(
            pincode:code
        )
        
        digiliraPay.request(  rURL: digilira.api.url + digilira.api.userUpdate,
                              JSON: try? digiliraPay.jsonEncoder.encode(user),
                              METHOD: digilira.requestMethod.put,
                              AUTH: true
        ) { (json, statusCode) in
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Pin Kodu Güncellendi", message: "Pin kodunuzu unutmayın, cüzdanınızı başka bir cihaza aktarırken ihtiyacınız olacaktır.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)

                self.digiliraPay.onLogin2 = { user, status in
                    DispatchQueue.main.sync {
                        self.kullanici = user
                    }
                }
                
                self.digiliraPay.login2()
            }
        }
    }
    
    
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

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
import Starscream
import Foundation
import Wallet

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
    
    var isKeyboard = false
    
    private let refreshControl = UIRefreshControl()
    
    var isAlive = false
    var isNewPin = false
    var isFirstLaunch = true
    var isTouchIDCanceled = false
    
    var walletOperationsViewOrigin = CGPoint(x: 0, y: 0)
    
    var kullanici: digilira.user?
    var pinkodaktivasyon: Bool? = false
    
    var Balances: NodeService.DTO.AddressAssetsBalance?
    var Filtered: [NodeService.DTO.AssetBalance?] = []
    
    var onPinSuccess: ((_ result: Bool)->())?

    
    var headerHeightBuffer: CGFloat?
    var QR:String?
    
    var Assets = [
        "FjTB2DdymTfpYbCCdcFwoRbHQnEhQD11CUm6nAF7P1UD": "Bitcoin",
        "LVf3qaCtb9tieS1bHD8gg5XjWvqpBm5TaDxeSVcqPwn": "Ethereum",
        "49hWHwJcTwV7bq76NebfpEj8N4DpF8iYKDSAVHK9w9gF" : "Litecoin",
        "HGoEZAsEQpbA3DJyV9J3X1JCTTBuwUB6PE19g1kUYXsH" : "Waves",
        "2CrDXATWpvrriHHr1cVpQM65CaP3m7MJ425xz3tn9zMr" : "Charity"]
    
    let BC = Blockchain()
    
    let digiliraPay = digiliraPayApi()
    let socket1 = WebSocket(url: URL(string: "wss://api.digilirapay.com/socket/" + NSUUID().uuidString )!)
    
    func socketConn () {
        
        // if #available(iOS 13.0, *) {
        //     let webSocketTask = urlSession.webSocketTask(with: URL(string: "wss://api.digilirapay.com/socket/" )!)
        //     webSocketTask.resume()
        // } else {
        // Fallback on earlier versions
        socket1.delegate = self
        socket1.connect()
        // }
    }
    
    struct SocketMessage: Codable {
        var id: String
        var status: String
        var txid: String?
    }
    
    
    func sendMessage(_ message: SocketMessage) {
        print(message)
        
        if (!isAlive) {
            socket1.connect()
        }
        
        let jsonData = try? JSONEncoder().encode(message)
        socket1.write(data: jsonData!)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        socketConn()
        coinTableView.refreshControl = refreshControl
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        
        
        self.contentView.addGestureRecognizer(swipeRight)
        self.contentView.addGestureRecognizer(swipeLeft)
         
        
//        when requested asset balances
        
        BC.onAssetBalance = { result in
            self.Balances = (result)
            self.setTableView()
            self.setWalletView()
            self.setPaymentView()
            self.setSettingsView()
            self.coinTableView.reloadData()
        }
        
        
        BC.onTransferTransaction = { res in
            let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res.dictionary["attachment"] as! String)!), as: UTF8.self)
            let txid = res.dictionary["id"] as? String
            
            self.sendMessage(SocketMessage.init(id: attachment,
                                                status: "VERIFYING",
                                                txid: txid))
            DispatchQueue.main.async {
                self.showSuccess(mode: 1, transaction: res.dictionary)
            }
            self.bottomView.isHidden = true
            self.closeCoinSendView()
            self.goHomeScreen()
            
            self.BC.verifyTrx(txid: txid!, id: attachment)
            
        }
        
        BC.onVerified = { res in
            NotificationCenter.default.post(name: .didCompleteTask, object: nil)
            DispatchQueue.main.async {
                self.showSuccess(mode: 2, transaction: res)
            }
            
            let id = res["id"] as? String
            let attachment = String(decoding: (WavesCrypto.shared.base58decode( input: res["attachment"] as! String)!), as: UTF8.self)
            
            let odeme = digilira.odemeStatus.init(id: attachment, txid: id!, status: "2")
            self.sendMessage(SocketMessage.init(id: attachment, status: "SUCCESSFUL", txid: id!))
            self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
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
                break
            }
            
        }

        
        

        refreshControl.attributedTitle = NSAttributedString(string: "Güncellemek için çekiniz..")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
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
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            

            switch swipeGesture.direction {
            case .right:
                if (isHomeScreen) {
                    goSettings()
                    return
                }
                if (isPayments) {
                    goWalletScreen(coin: 0)
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
                    goWalletScreen(coin: 0)
                    return
                }
                if (isShowSettings) {
                    goHomeScreen()
                    return
                }
            default:
                break
            }
        }
    }
    
    func getOrder(address: String) {
        
        digiliraPay.onGetOrder = { res in
            self.sendQR(ORDER: res)

        }
        digiliraPay.getOrder(PARAMS: address)
        
    }
    
    @objc func onDidReceiveData(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        self.QR = UserDefaults.standard.object(forKey: "QRURL") as! String?
        self.dismissVErifyAccountView(user: kullanici!)
        getOrder(address: self.QR!)
        
        
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= 150
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
    
    
    @objc private func refreshWeatherData(_ sender: Any) {
        if isSuccessView {
            refreshControl.endRefreshing()
            return
        }
        fetch()
        //coinTableView.reloadData()
        refreshControl.endRefreshing()

    }
    
    
    func fetch() {
        BC.checkAssetBalance(address: kullanici!.wallet!)
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
        isHomeScreen = true
        
    }
    
    func setWalletView() // Wallet ekranı detayları aşağıda
    {
        walletView = UIView().loadNib(name: "WalletView") as! WalletView
        walletView.frame = CGRect(x: contentView.frame.width,
                                  y: 0,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height)
        
        
        walletView.kullanici = self.kullanici
        walletView.coin = self.homeAmountLabel.text
        
        walletView.layer.zPosition = 0
        
        walletView.frameValue = walletView.frame
        walletView.setView()
        walletView.ViewOriginMaxXValue.y = menuView.frame.height
        contentScrollView.addSubview(walletView)
        
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
        
        if isFirstLaunch {
//            
            if pinkodaktivasyon! {
                if kullanici?.pincode == -1 {
                    openPinView()
                }
            }
            isFirstLaunch = false
        }
        
        if QR != nil {
            getOrder(address: QR!)
            QR = nil
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
    
    func setPaymentView() // payments ekranı
    {
        paymentCat = UIView().loadNib(name: "PaymentCategories") as! PaymentCat
        paymentCat.cardCount = 3
        paymentCat.frame = CGRect(x: contentView.frame.width * 2,
                                  y: 0,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height)
        
        paymentCat.layer.zPosition = 1
        
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
        self.QR = nil //qr bilgisi sifirlama
        UserDefaults.standard.set("EMPTY", forKey: "QRURL")

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
        menuXib.setView()
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
    
}

extension MainScreen: UITableViewDelegate, UITableViewDataSource // Tableview ayarları, coinlerin listelenmesinde bu fonksiyonlar kullanılır.
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Filtered.removeAll()
        
        var count = 0
        for asset1 in Balances!.balances {
            if ((self.Assets[asset1.assetId]) != nil) {
                Filtered.append(asset1)
                count = count + 1
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSuccessView { //eger basarili ekrani aciksa kapat
            return
        }
        goWalletScreen(coin: indexPath.item)
        
    }
    
    @objc func handleTap(recognizer: MyTapGesture) {
        if isSuccessView { //eger basarili ekrani aciksa kapat
            return
        }
        goWalletScreen(coin: recognizer.floatValue)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = UITableViewCell().loadXib(name: "CoinTableViewCell") as? CoinTableViewCell
        {
            let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
            
            tapped.floatValue = indexPath[1]
            cell.addGestureRecognizer(tapped)
            
            cell.coinIcon.image = UIImage(named:Assets[(Filtered[indexPath[1]]?.issueTransaction.assetId)!]!)
            
            cell.coinName.text = Assets[(Filtered[indexPath[1]]?.issueTransaction.assetId)!]
            let double = Double(Filtered[indexPath[1]]!.balance) / Double(100000000)
            cell.coinAmount.text = (double).description
            cell.coinCode.text = (Filtered[indexPath[1]]!.issueTransaction.name)
            
            
            return cell
            
        }
        else
        { return UITableViewCell() }
    }
}

extension MainScreen: MenuViewDelegate // alt menünün butonlara tıklama kısmı
{
    func goPayments() {
        
//        if let resultController = storyboard!.instantiateViewController(withIdentifier: "cardViewVC") as? ViewController {
//            present(resultController, animated: true, completion: nil)
//        }
        
        
        isShowSettings = false
        isPayments = true
        isHomeScreen = false

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
            walletOperationView.removeFromSuperview()

            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!

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
        
    }
    
    func goSettings() {
        isShowSettings = true
        isPayments = false
        isHomeScreen = false
        
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
            walletOperationView.removeFromSuperview()
            
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                
                self.contentScrollView.contentOffset.x = 0
            }
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
    }
    
    func goHomeScreen()
    {
        
        isHomeScreen = true
        
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
            walletOperationView.removeFromSuperview()
            
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = self.headerHeightBuffer!
                
                self.contentScrollView.contentOffset.x = 0
            }
        }
        
        if !isSuccessView {
            bottomView.isHidden = false
        }
        
        if isPayments || isShowSettings {
            isPayments = false
            isShowSettings = false

            UIView.animate(withDuration: 0.3, animations: { [self] in
                self.contentScrollView.contentOffset.x = 0
            }) { (_) in
                self.walletOperationsViewOrigin = self.walletOperationView.frame.origin
            }
        }

        headerInfoLabel.isHidden = true
        homeAmountLabel.isHidden = true
        logoView.isHidden = false
        menuXib.isHidden = false
    }
    
    func goWalletScreen(coin: Int)
    {
        
        isShowSettings = false
        isPayments = false
        isHomeScreen = false
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView {
            closeSendView()
        }
        
        if !isShowWallet
        {
            isShowWallet = true
            
            headerInfoLabel.isHidden = false
            homeAmountLabel.isHidden = false
            logoView.isHidden = true
            
            headerInfoLabel.textColor = UIColor(red:0.94, green:0.56, blue:0.10, alpha:1.0)
            if Filtered.count != 0 {
                headerInfoLabel.text = Assets[(Filtered[coin]?.issueTransaction.assetId)!]
                let double = Double(Filtered[coin]!.balance) / Double(100000000)
                homeAmountLabel.text = (double).description
            } else {
                headerInfoLabel.text = "Bakiye"
                homeAmountLabel.text = "0.0"

            }
            walletOperationView = UIView().loadNib(name: "WalletOperationButtonSView") as! WalletOperationButtonSView
            walletOperationView.frame = CGRect(x: 0,
                                               y: homeAmountLabel.frame.maxY + 10,
                                               width: view.frame.width,
                                               height: 60)
            walletOperationView.delegate = self
            walletOperationView.alpha = 0
            
            headerHeightBuffer =  headerView.frame.size.height //bu mal degisip duruyo
            headerView.addSubview(walletOperationView)
            
            _ = headerView.frame.size.height
            
            
            UIView.animate(withDuration: 0.3, animations: { [self] in
                self.headerView.frame.size.height =  walletOperationView.frame.maxY + 20
                self.walletOperationView.alpha = 1
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
        if (!isAlive) {
            socket1.connect()
        }
        
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

extension MainScreen: OperationButtonsDelegate // Wallet ekranındaki gönder yükle butonlarının tetiklenmesi ve işlemleri
{
    func send(params: SendTrx)
    {
        
        let y = logoView.frame.maxY
        if !isShowSendCoinView
        {
            if params.attachment == "" { //bos send view
                homeAmountLabel.isHidden = false
                headerInfoLabel.isHidden = false
                //headerInfoLabel.text = "BAKİYEM"
                //headerInfoLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1.0)
            }else { // qr send view
                headerInfoLabel.isHidden = true
                homeAmountLabel.isHidden = true

            }
            
            goHomeScreen()
            
            logoView.isHidden = true

            isShowSendCoinView = true
            sendMoneyBackButton.isHidden = false
            //profileMenuButton.isHidden = true
            sendMoneyView = UIView().loadNib(name: "CoinSendView") as! CoinSendView
            sendMoneyView.transaction = params
            sendMoneyView.frame = CGRect(x: 0,
                                         y: y,
                                         width: view.frame.width,
                                         height: view.frame.height)

            sendMoneyView.amountTextField.text = (Double(params.amount) / Double(100000000)).description
            sendMoneyView.receiptTextField.text = params.merchant
            sendMoneyView.amountTextField.isEnabled = false
            sendMoneyView.receiptTextField.isEnabled = false
                        
            sendMoneyView.totalQuantity.text =  "Toplam Bakiye:"
            sendMoneyView.commissionAmount.text = "İşlem komisyonu:"
            sendMoneyView.amountEquivalent.text = params.fiat.description + " ₺"
            

            sendMoneyView.delegate = self
            walletOperationView.translatesAutoresizingMaskIntoConstraints = true
            walletOperationView.alpha = 0
            sendMoneyView.alpha = 0
            headerView.addSubview(sendMoneyView)
            
            let headerHeight = headerView.frame.size.height
            headerHeightBuffer = headerHeight
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = headerHeight + 240
                self.sendMoneyView.alpha = 1
            }
        }
        
        
    }
    
    func load()
    {
        if !isShowLoadCoinView
        {
            isShowLoadCoinView = true
            qrView.frame.origin.y = view.frame.height
            sendMoneyBackButton.isHidden = false
            //profileMenuButton.isHidden = true
            loadMoneyView = UIView().loadNib(name: "QRView") as! QRView
            loadMoneyView.frame = qrView.frame
            loadMoneyView.delegate = self
            
            for subView in qrView.subviews
            { subView.removeFromSuperview() }
            
            qrView.addSubview(loadMoneyView)
            
            qrView.isHidden = false
            qrView.translatesAutoresizingMaskIntoConstraints = true
            
            UIView.animate(withDuration: 0.3)
            {
                self.qrView.frame.origin.y = 0
                self.loadMoneyView.frame.origin.y = 0
            }
        }
        
    }
}

extension MainScreen: TransactionPopupDelegate2 {
    func close() {
        
        menuView.isHidden = false
        
            accountButton.isHidden = false
            //profileMenuButton.isHidden = false
        
        UIView.animate(withDuration: 1) {
            self.successView.frame.origin.y = (self.contentView.frame.maxY)
            self.successView.alpha = 0
            self.isSuccessView = false
            self.bottomView.isHidden = false

        }
        
    }
    
    
}

extension MainScreen: SendCoinDelegate // Wallet ekranı gönderme işlemi
{
    func sendCoin(params:SendTrx) // gelen parametrelerle birlikte gönder butonuna basıldı.
    {
        let ifPin = kullanici?.pincode
        
        if ifPin == -1 {
            openPinView()
        }else {
            
            
            BC.onSensitive = { [self] wallet, err in
                switch err {
                case "ok":
                    BC.sendTransaction2(recipient: params.recipient, fee: 900000, amount: params.amount, assetId: params.assetId, attachment: params.attachment, wallet:wallet)
                    break
                case "Canceled by user.":
                    let alert = UIAlertController(title: "Hatalı Pin Kodu", message: "İşleminiz iptal edilmiştir.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                    self.closeSendView()
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
                        self.closeSendView()
                    }
                    break
                }
                
            }
            
            
            BC.getSensitive(pin:false)
            
        }
         
        
        
    }
    
    func closeCoinSendView()
    {
        self.QR = nil //qr bilgisi sifirlama
        if isShowSendCoinView
        {
            isShowSendCoinView = false
            
            if isShowWallet {
                
                logoView.isHidden = true
                headerInfoLabel.isHidden = false
                homeAmountLabel.isHidden = false
                
            }else {
                
                logoView.isHidden = false
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
extension MainScreen: ProfileMenuDelegate // Profil doğrulama, profil ayarları gibi yan menü işlemleri
{
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

        
        //profil onay sureci
        
        switch kullanici?.status {
        case 0:
            let verifyProfileXib = UIView().loadNib(name: "VerifyAccountView") as! VerifyAccountView
            verifyProfileXib.kullanici = kullanici //kullanici bilgilerinin aktarilmasi
            
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
            verifyProfileXib.kullanici = kullanici //kullanici bilgilerinin aktarilmasi
            
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
    
    
    
    
    func showSuccess(mode: Int, transaction: [String : Any])
    {
        accountButton.isHidden = true
        //profileMenuButton.isHidden = true
        
        let asset = BC.returnAsset(assetId: (transaction["assetId"] as?  String)!)
        let amount = String ((transaction["amount"] as? Float64)! / (100000000))
        print(transaction)
        
        if isSuccessView {
            
            successView.titleLabel.text = "ÖDEME BAŞARILI"
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
                self.successView.frame.origin.y = self.contentScrollView.frame.maxY - self.contentScrollView.frame.width
                self.successView.alpha = 1
            }
             
        }
        
        
    }
    
    
    func showTermsofUse()
    {
        showLegal(mode: digilira.terms.init(title: digilira.termsOfUse.title, text: digilira.termsOfUse.text))
    }
    
    func showLegalText()
    {
        showLegal(mode: digilira.terms.init(title: digilira.legalView.title, text: digilira.legalView.text))
    }
    func showPinView() {
        isNewPin = true
        openPinView()
    }
}

extension MainScreen: PaymentCatViewsDelegate {
    func dismiss() {
        print("ok")
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
    }
}

extension MainScreen: VerifyAccountDelegate
{
    func dismissVErifyAccountView(user: digilira.user) // profil doğrulama sayfasının kapatılması
    {
        
            if QR != "EMPTY" && QR != nil {
                UserDefaults.standard.set("EMPTY", forKey: "QRURL")
                getOrder(address: self.QR!)
            }
            
        
        self.kullanici = user
        UIView.animate(withDuration: 0.3) {
            self.qrView.frame.origin.y = self.view.frame.height
            self.qrView.alpha = 0
        }
        menuXib.isHidden = false
        bottomView.isHidden = false
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
    func qrError(error: String) {
        switch error {
        case "notDP":
            let alert = UIAlertController(title: digilira.messages.qrErrorHeader, message: digilira.messages.qrErrorMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                self.dismissSendWithQr()
            }))
             
            
            self.present(alert, animated: true)
        default:
            break
        }
    }
    
    func dismissSendWithQr()
    {
        isShowQRButton = false
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
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
    
    func sendQR(ORDER: digilira.order) {
        
        sendMessage(SocketMessage.init(id: ORDER._id, status: "PROCESSING"))
        
        
        let auth = digiliraPay.auth()
        
        if (auth.status == 0) {
            alertError ()
            return
        }
        
        let odeme = digilira.odemeStatus.init(
            id: ORDER._id,
            status: "1",
            name: auth.name,
            surname: auth.surname
        )
        
        self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
        
        let data = SendTrx.init(merchant: ORDER.merchant,
                                recipient: ORDER.wallet,
                                assetId: ORDER.asset!,
                                amount: ORDER.rate,
                                fee: 900000,
                                fiat: ORDER.totalPrice!,
                                attachment: ORDER._id
        )
        send(params: data)
    }
    
    
}



extension MainScreen : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        isAlive = true
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isAlive = false        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("3")
    }
    
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
    static let orderClick = Notification.Name("orderClick")
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
        pinView.kullanici = kullanici
        
        if isTouchIDCanceled {
            pinView.isTouchIDCanceled = true
            self.isTouchIDCanceled = false
        }
        
        if !isNewPin {
            
            if kullanici?.pincode != -1 {
                
                pinView.isEntryMode = true
            }else {
                let alert = UIAlertController(title: "Pin Oluşturun", message: "Ödeme yapabilmek ve kripto varlıklarınızı transfer edebilmek için bir pin kodu oluşturmanız gerekmektedir.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                pinView.isInit = true
            }
        }else {
            
            if kullanici?.pincode != -1 {
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
        
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
        }
        
        
        QR = UserDefaults.standard.object(forKey: "QRURL") as! String?

        if QR != "EMPTY" && QR != nil {
            UserDefaults.standard.set("EMPTY", forKey: "QRURL")
            getOrder(address: self.QR!)
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

                self.digiliraPay.login() { (json, status) in
                    DispatchQueue.main.async {
                        self.kullanici = json
                    }
                 }
            }
         }
    }
    
    
}

class MyTapGesture: UITapGestureRecognizer {
    var floatValue = 0
    var qrAttachment = ""
}

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

public let kNotification = Notification.Name("kNotification")


class MainScreen: UIViewController {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileMenuButton: UIImageView!
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
    
    var tapProfileMenuGesture = UITapGestureRecognizer()
    var tapCloseProfileMenuGesture = UITapGestureRecognizer()
    
    var isShowProfileMenu = false
    var isShowWallet = false
    var isShowSendCoinView = false
    var isShowSettings = false
    var isShowQRButton = false
    var isShowLoadCoinView = false
    var isSuccessView = false
    
    private let refreshControl = UIRefreshControl()
    
    var isAlive = false
    
    var walletOperationsViewOrigin = CGPoint(x: 0, y: 0)
    
    var kullanici: digilira.user?
    
    var Balances: NodeService.DTO.AddressAssetsBalance?
    var Filtered: [NodeService.DTO.AssetBalance?] = []
    
    var headerHeightBuffer: CGFloat?
    var QR:String?
    
    var Assets = [
        "FjTB2DdymTfpYbCCdcFwoRbHQnEhQD11CUm6nAF7P1UD": "Bitcoin",
        "LVf3qaCtb9tieS1bHD8gg5XjWvqpBm5TaDxeSVcqPwn": "Ethereum",
        "49hWHwJcTwV7bq76NebfpEj8N4DpF8iYKDSAVHK9w9gF" : "Litecoin",
        "HGoEZAsEQpbA3DJyV9J3X1JCTTBuwUB6PE19g1kUYXsH" : "Waves"]
    
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
        
        
        //BC.rollback(wallet: kullanici!.wallet!)
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
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
    
    
    func getOrder(address: String) {
        
        digiliraPay.postData(PARAMS: address
        ) { (json) in
            
            DispatchQueue.main.async {
                
                let order = digilira.order.init(_id: (json["id"] as? String)!,
                                                merchant: (json["merchant"] as? String)!,
                                                user: json["merchant"] as? String,
                                                language: json["language"] as? String,
                                                order_ref: json["order_ref"] as? String,
                                                createdDate: json["createdDate"] as? String,
                                                order_date: json["order_date"] as? String,
                                                order_shipping: json["order_shipping"] as? Double,
                                                conversationId: json["conversationId"] as? String,
                                                rate: (json["rate"] as? Int64)!,
                                                totalPrice: json["totalPrice"] as? Double,
                                                paidPrice: json["paidPrice"] as? Double,
                                                refundPrice: json["refundPrice"] as? Double,
                                                currency: json["currency"] as? String,
                                                currencyFiat: json["currencyFiat"] as? Double,
                                                userId: json["userId"] as? String,
                                                paymentChannel: json["paymentChannel"] as? String,
                                                ip: json["ip"] as? String,
                                                registrationDate: json["registrationDate"] as? String,
                                                wallet: (json["wallet"] as? String)!,
                                                asset: json["asset"] as? String,
                                                successUrl: json["successUrl"] as? String,
                                                failureUrl: json["failureUrl"] as? String,
                                                callbackSuccess: json["callbackSuccess"] as? String,
                                                callbackFailure: json["callbackFailure"] as? String,
                                                mobile: json["mobile"] as? Int64,
                                                status: json["status"] as? Int64)
                
                
                self.sendQR(ORDER: order)
                
                
            }
        }
        
    }
    
    @objc func onDidReceiveData(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        let A = UserDefaults.standard.object(forKey: "QRURL")
        
        getOrder(address: A as! String)
        
        
    }
    
    @objc func onTrxCompleted(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        print("ok")
    }
     
    @objc func onOrderClicked(_ sender: Notification) {
        // Do what you need, including updating IBOutlets
        print(sender.userInfo)

        let alert = UIAlertController(title: "Sipariş detayları", message: "Sipariş detayları için kendinize iyi bakın.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))

        self.present(alert, animated: true)
        
        
        
        
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @objc private func refreshWeatherData(_ sender: Any) {
        fetch()
        
        coinTableView.reloadData()
        refreshControl.endRefreshing()
        
        
        
        
    }
    
    
    func fetch() { 
        BC.checkAssetBalance(address: kullanici!.wallet!){ (seed) in
            DispatchQueue.main.async {
                self.Balances = (seed)
                self.setTableView()
                self.setWalletView()
            }
        }
        
    }
    
    
    func verifyTrx(txid: String, id:String) {
        
        digiliraPay.request(rURL: digilira.node.url + "/transactions/info/" + txid,
                            METHOD: digilira.requestMethod.get
        ) { (json) in
            DispatchQueue.main.async {
                if json["message"] != nil {
                    print(json["message"]!)
                    sleep(1)
                    self.verifyTrx(txid: txid, id:id)
                } else {
                    
                    NotificationCenter.default.post(name: .didCompleteTask, object: nil)
                    self.showSuccess(mode: 2)
                    
                    let odeme = digilira.odemeStatus.init(id: id, txid: txid, status: "2")
                    self.sendMessage(SocketMessage.init(id: id, status: "SUCCESSFUL", txid: txid))
                    self.digiliraPay.setOdemeAliniyor(JSON: try? self.digiliraPay.jsonEncoder.encode(odeme))
                    
                    print(json)
                }
            }
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadMenu()
        
        headerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        headerView.layer.cornerRadius = 30
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
        
        profileMenuButton.isUserInteractionEnabled = true
        profileMenuButton.addGestureRecognizer(tapProfileMenuGesture)
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
        
        
        menuXib.setSelector(view: menuXib.homeView)
        
        
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
        walletView.coin = self.homeAmountLabel.text
        
        walletView.layer.zPosition = 0
        
        walletView.frameValue = walletView.frame
        walletView.setView()
        walletView.ViewOriginMaxXValue.y = menuView.frame.height
        contentScrollView.addSubview(walletView)
        
        contentScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(contentScrollView.subviews.count)
        
        if QR != nil {
            getOrder(address: QR!)
            QR = nil
        }
        
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
        goWalletScreen(coin: indexPath.item)
        menuXib.setSelector(view: menuXib.walletView)
        
    }
    
    @objc func handleTap(recognizer: MyTapGesture) {
        goWalletScreen(coin: recognizer.floatValue)
        menuXib.setSelector(view: menuXib.walletView)
        
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
    func goHomeScreen()
    {
        
        isShowSettings = false
        
        dismissLoadView()
        dismissProfileMenu()
        
        if isShowSendCoinView { //eger gonder ekrani aciksa kapat
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
        bottomView.isHidden = false
        
    }
    
    func goWalletScreen(coin: Int)
    {
        
        isShowSettings = false
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
            
            headerInfoLabel.text = Assets[(Filtered[coin]?.issueTransaction.assetId)!]
            walletOperationView = UIView().loadNib(name: "WalletOperationButtonSView") as! WalletOperationButtonSView
            let double = Double(Filtered[coin]!.balance) / Double(100000000)
            
            homeAmountLabel.text = (double).description
            
            walletOperationView.frame = CGRect(x: 0,
                                               y: homeAmountLabel.frame.maxY + 20,
                                               width: view.frame.width,
                                               height: 0)
            walletOperationView.delegate = self
            walletOperationView.alpha = 0
            
            headerHeightBuffer =  headerView.frame.size.height //bu mal degisip duruyo
            headerView.addSubview(walletOperationView)
            
            let headerHeight = headerView.frame.size.height
            
            
            UIView.animate(withDuration: 0.3, animations: {
                self.headerView.frame.size.height = headerHeight + (headerHeight / 2.2)
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
        
        var y = headerInfoLabel.frame.maxY
        var buffer = 200
        if !isShowSendCoinView
        {
            if params.attachment == "" { //bos send view
                homeAmountLabel.isHidden = false
                headerInfoLabel.isHidden = false
                //headerInfoLabel.text = "BAKİYEM"
                //headerInfoLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1.0)
                
                y = homeAmountLabel.frame.maxY
            }else { // qr send view
                headerInfoLabel.isHidden = true
                homeAmountLabel.isHidden = true
                buffer = 200
            }
            
            goHomeScreen()
            
            logoView.isHidden = true

            isShowSendCoinView = true
            sendMoneyBackButton.isHidden = false
            profileMenuButton.isHidden = true
            sendMoneyView = UIView().loadNib(name: "CoinSendView") as! CoinSendView
            sendMoneyView.transaction = params
            sendMoneyView.frame = CGRect(x: 0,
                                         y: y,
                                         width: view.frame.width,
                                         height: 50)
            
            sendMoneyView.amountTextField.text = (Double(params.amount) / Double(100000000)).description
            sendMoneyView.receiptTextField.text = params.merchant
            sendMoneyView.amountTextField.isEnabled = false
            sendMoneyView.receiptTextField.isEnabled = false
                        
            sendMoneyView.totalQuantity.text = ""
            sendMoneyView.commissionAmount.text = ""
            sendMoneyView.amountEquivalent.text = ""
            
            sendMoneyView.delegate = self
            walletOperationView.translatesAutoresizingMaskIntoConstraints = true
            walletOperationView.alpha = 0
            sendMoneyView.alpha = 0
            headerView.addSubview(sendMoneyView)
            
            let headerHeight = headerView.frame.size.height
            UIView.animate(withDuration: 0.3) {
                self.headerView.frame.size.height = headerHeight + CGFloat(buffer)
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
            profileMenuButton.isHidden = true
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
        // MARK: TODO
        print(params)
        
        BC.sendTransaction(recipient: params.recipient, fee: 900000, amount: params.amount, assetId: params.assetId, attachment: params.attachment){(res) in
            
            
            self.sendMessage(SocketMessage.init(id: params.attachment, status: "VERIFYING", txid: res.dictionary["id"] as? String))
            self.showSuccess(mode: 1)
            self.bottomView.isHidden = true
            self.closeCoinSendView()
            self.goHomeScreen()
            
            self.verifyTrx(txid: res.dictionary["id"] as! String, id: params.attachment)
        }
        
    }
    
    func closeCoinSendView()
    {
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
            profileMenuButton.isHidden = false
            let headerHeight = headerView.frame.size.height
            sendMoneyView.removeFromSuperview()
            UIView.animate(withDuration: 0.4, animations: {
                self.headerView.frame.size.height = headerHeight - 200
            }) { (_) in
                
                self.walletOperationView.translatesAutoresizingMaskIntoConstraints = true
                self.walletOperationView.frame = CGRect(x: 0,
                                                        y: self.homeAmountLabel.frame.maxY + 15,
                                                        width: self.view.frame.width,
                                                        height: 100)
                self.walletOperationView.alpha = 1
                
            }
            
            
            
        }
        
    }
}
extension MainScreen: ProfileMenuDelegate // Profil doğrulama, profil ayarları gibi yan menü işlemleri
{
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
    
    
    func showSuccess(mode: Int)
    {
        
        if isSuccessView {

            successView.titleLabel.text = "BAŞARILI"
            successView.remainingAmount.text = ""
            successView.remainingAmountInfoLabel.text = ""
            successView.infoLabel.text = ""
            
            successView.buttonLabrl.text = "Tamam"
            
            successView.headerImage.isHidden = false
            successView.buttonView.isHidden = false
            successView.backgroundColor = UIColor.green
        }else {
            
            successView = UIView().loadNib(name: "TransactionPopup") as! TransactionPopup
            
            successView.frame = CGRect(x: 20,
                                       y: contentScrollView.frame.maxY,
                                       width: contentScrollView.frame.width - 40,
                                       height: contentScrollView.frame.width )
            
            
            menuView.isHidden = true
            bottomView.isHidden = true
            
            successView.titleLabel.text = "DOĞRULANIYOR"
            successView.backgroundColor = UIColor.white
            
            successView.remainingAmount.text = ""
            successView.remainingAmountInfoLabel.text = ""
            successView.infoLabel.text = ""
            

            successView.headerImage.isHidden = true
            successView.buttonView.isHidden = true

            isSuccessView = true
            
            successView.layer.shadowColor = UIColor.black.cgColor
            successView.layer.shadowOpacity = 0.4
            successView.layer.shadowOffset = .zero
            successView.layer.shadowRadius = 3
            successView.layer.cornerRadius = 20
            successView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            
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
        showLegal()
    }
    
    func showLegalText()
    {
        showLegal()
    }
    func showPinView() {
        openPinView()
    }
}


extension MainScreen: ProfileSettingsViewDelegate
{
    func dismissProfileMenu() // profil ayarlarının kapatılması
    {
        isShowSettings = false
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
        profileMenuButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.qrView.frame.origin.y = self.view.frame.height
        }
    }
}

extension MainScreen: VerifyAccountDelegate
{
    func dismissVErifyAccountView(user: digilira.user) // profil doğrulama sayfasının kapatılması
    {
        self.kullanici = user
        UIView.animate(withDuration: 0.3) {
            self.qrView.frame.origin.y = self.view.frame.height
        }
        menuXib.isHidden = false
        bottomView.isHidden = false
    }
}



extension MainScreen: LegalDelegate // kullanım sözleşmesi gibi view'ların gösterilmesi
{
    func showLegal()
    {
        profileSettingsView.frame.origin.y = view.frame.height
        let legalXib = UIView().loadNib(name: "LegalView") as! LegalView
        legalXib.delegate = self
        legalXib.frame = CGRect(x: 0,
                                y: 0,
                                width: profileSettingsView.frame.width,
                                height: profileSettingsView.frame.height)
        
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
    }
}

extension MainScreen: SendWithQrDelegate
{
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
        print(error)
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
    
    func closePinView() {
        UIView.animate(withDuration: 0.3) {
            self.sendWithQRView.frame.origin.y = self.self.view.frame.height
            self.sendWithQRView.alpha = 0
        }
    }
    
    
}

class MyTapGesture: UITapGestureRecognizer {
    var floatValue = 0
    var qrAttachment = ""
}

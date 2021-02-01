//
//  PageCardView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 25.11.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


class PageCardView: UIView {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var totalPrice: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var products: UIView!
    @IBOutlet weak var payButton: UIView!
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var balanceCardView = BalanceCard()
    let generator = UINotificationFeedbackGenerator()
    
    weak var errors: ErrorsDelegate?

    weak var delegate: PageCardViewDeleGate?
    var Filtered: [digilira.DigiliraPayBalance] = []
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    var direction: UISwipeGestureRecognizer.Direction?
    var network: String = digilira.wavesNetwork
    var shoppingCart: [digilira.shoppingCart] = []
    
    var Ticker: binance.BinanceMarketInfo = []
    let binanceAPI = binance()
    var ticker: digilira.ticker?
    
    var bexTicker: bex.bexAllTicker?
    var marketInfo: bex.bexMarketInfo?

    var bexT = bex()
    
    var Order: PaymentModel?
    var currentPage: Int = 0
    
    @IBAction func changePage(_ sender: UIPageControl) {
        currentPage = sender.currentPage
        setBalanceView(index: sender.currentPage)
    }
    
    func setBalanceView(index:Int) {
        if Filtered.count >= currentPage {
            UIView.animate(withDuration: 0.5,
              animations: {
                var orgX = self.scrollAreaView.frame.width
                
                if let d = self.direction {
                    switch d {
                    case UISwipeGestureRecognizer.Direction.right:
                        orgX = 1 - self.scrollAreaView.frame.width
                        break
                    default:
                        break
                    }
                }
                
                self.scrollAreaView.subviews[self.scrollAreaView.subviews.count - 1].frame.origin.x = 1 - orgX
                self.scrollAreaView.subviews[self.scrollAreaView.subviews.count - 1].alpha = 0
              }, completion: {finished in
                self.scrollAreaView.subviews[0].removeFromSuperview()
              }
            )
 
            do {
                try scrollAreaView.addSubview(setCoinCard(scrollViewSize: scrollAreaView, layer: 0, coin: Filtered[currentPage]))
            } catch {
                print(error)
            }
            
        }
        
    }
    
    override func didMoveToSuperview() {

//        // Do any additional setup after loading the view, typically from a nib.
//        pageControl.numberOfPages = Filtered.count
//        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .allTouchEvents)
//        shoppingCart = []
//        setTableView()
    }
    
    
    override func awakeFromNib() { 
        setShad(view: totalPrice)
        setShad(view: products)
        setBtn(object: payButton, mode: 1)
        setBtn(object: cancelButton, mode: 0)
        setShad(view: scrollAreaView, cornerRad: 10, mask: true)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        let tapCancel = UITapGestureRecognizer(target: self, action: #selector(letsGO))
        cancelButton.addGestureRecognizer(tapCancel)
        cancelButton.isUserInteractionEnabled = true
        
        let tapPay = UITapGestureRecognizer(target: self, action: #selector(letsPay))
        payButton.addGestureRecognizer(tapPay)
        payButton.isUserInteractionEnabled = true
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        scrollAreaView.addGestureRecognizer(leftSwipe)
        scrollAreaView.addGestureRecognizer(rightSwipe)
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = false
    }
    
    @objc func letsGO()
    {
        if let orderId = Order {
            delegate?.cancel1(id: orderId.paymentModelID)
        }
    }
    
    @objc func letsPay()
    {
        if let order = Order {
            let t1 = Int64(NSDate().timeIntervalSince1970) * 1000
            let timestamp = order.createdDate

            let formatter4 = DateFormatter()
            formatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let then = formatter4.date(from: String(timestamp.description)) ?? Date()

            let t0 = (Int64(then.timeIntervalSince1970) * 1000)
            
            let delta = (t1 - t0) / 1000
            
            if delta > 120 {
                errors?.errorHandler(message: "Ödeme süresi doldu. Lütfen yeni QR kod okutunuz.", title: "Geçersiz QR Kod", error: true)
            } else {
                delegate?.dismissNewSend1(params: order, network: network)
            }
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        direction = sender.direction
        if sender.direction == .right
        {
            
            if pageControl.currentPage > 0 {
                pageControl.currentPage -= 1
                currentPage -= 1
                changePage(pageControl)
                generator.notificationOccurred(.success)
            } else {
                generator.notificationOccurred(.error)
                shake()
            }
        }
        
        if sender.direction == .left
        {
            if pageControl.currentPage < Filtered.count - 1 {
                pageControl.currentPage += 1
                currentPage += 1
                changePage(pageControl)
                generator.notificationOccurred(.success)
            } else {
                shake()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    func setShad(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
    
    func setBtn(object: UIView, mode: Int) {
        switch mode {
        case 1:
            let gradientColor1 = UIColor(red: 0.5961, green: 0.2, blue: 0.4549, alpha: 1.0) /* #983374 */
            let gradientColor2 = UIColor(red: 0.9686, green: 0.1255, blue: 0.1804, alpha: 1.0) /* #f7202e */
            
            let btnGradient = CAGradientLayer()
            btnGradient.frame = self.bounds
            btnGradient.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
            
            btnGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            btnGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            object.layer.insertSublayer(btnGradient, at: 0)
        default:
            let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0) /* #000000 */
            let color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) /* #333333 */
            
            let btnGradient = CAGradientLayer()
            btnGradient.frame = self.bounds
            btnGradient.colors = [color1.cgColor, color2.cgColor]
            
            btnGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            btnGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            object.layer.insertSublayer(btnGradient, at: 0)
        }
        
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 20
        
    }
    
    func rateBitexen (coin: digilira.DigiliraPayBalance, fiyat: Double ) throws -> (Double, String, Double)  {
         
        if let mi = marketInfo {
            let data = mi.data.markets
            for item in data {
                if item.baseCurrency == coin.tokenName {
                    let coinPrice = bexTicker?.data.ticker[ item.marketCode]
                    let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                    let coinDouble = Double(coinPrice!.lastPrice)
                    
                    let balance = Double(coin.availableBalance) / double
                    let balanceTL = balance * coinDouble!
                    let price = (fiyat / coinDouble!) * double
                    
                    if item.counterCurrency.rawValue == "TRY" {
                        return (price, coin.tokenName, balanceTL)
                    }
                }
            
            }
        }
        
        throw digilira.NAError.notListedToken
    }
    
    func setCoinCard(scrollViewSize: UIView, layer: CGFloat, coin:digilira.DigiliraPayBalance) throws -> UIView {
        balanceCardView = UIView().loadNib(name: "BalanceCard") as! BalanceCard
        let ticker = digiliraPay.ticker(ticker: Ticker)
 
        if let order = Order {
            let fiyat = order.totalPrice
                do {
                     
                    if coin.network == "bitexen" {
                        let icon = UIImage(named: "bitexen_hover-1")
                        
                        var amount = fiyat
                        var asset = "TRY"
                        var tlfiyat = fiyat
                        
                        switch coin.tokenName {
                        case "TRY":
                            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                            amount = fiyat * double
                            asset = "TRY"
                            tlfiyat = Double(coin.availableBalance) / double
                        default:
                            (amount, asset, tlfiyat) = try rateBitexen(coin: coin, fiyat: fiyat)
                        }
                        
                        network = coin.network
                         
                        balanceCardView.setView(desc: coin.tokenName,
                                                tl: MainScreen.df2so(tlfiyat),
                                                amount: MainScreen.int2so(coin.availableBalance, digits: coin.decimal),
                                                price: MainScreen.int2so(Int64(amount), digits: coin.decimal),
                                                symbol: coin.tokenName, icon: icon)
                        
                        
                        if coin.availableBalance >= (Int64(amount)) {
                            Order?.currency = asset
                            Order?.rate = (Int64(amount))
                            payButton.isUserInteractionEnabled = true
                            payButton.alpha = 1
                        } else {
                            payButton.isUserInteractionEnabled = false
                            payButton.alpha = 0.4
                        }
                        
                        if (asset == "TL") {
                            payButton.isUserInteractionEnabled = false
                            payButton.alpha = 0.4
                            shake()
                        }
                    } else {
                        
                        let (amount, asset, tlfiyat) = try digiliraPay.ratePrice(price: fiyat, asset: coin, symbol: ticker)
                        network = coin.network
                        let icon = UIImage(named: coin.tokenName)
                         
                        balanceCardView.setView(desc: coin.tokenName,
                                                tl: MainScreen.df2so(tlfiyat),
                                                amount: MainScreen.int2so(coin.availableBalance, digits: coin.decimal),
                                                price: MainScreen.int2so(Int64(amount), digits: coin.decimal),
                                                symbol: coin.tokenName, icon: icon)
                        
                        
                        if coin.availableBalance >= (Int64(amount)) {
                            Order?.currency = asset
                            Order?.rate = (Int64(amount))
                            payButton.isUserInteractionEnabled = true
                            payButton.alpha = 1
                        } else {
                            payButton.isUserInteractionEnabled = false
                            payButton.alpha = 0.4
                        }
                        
                        if (asset == "TL") {
                            payButton.isUserInteractionEnabled = false
                            payButton.alpha = 0.4
                            shake()
                        }
                        
                    }
                    
                    

                } catch  {
                    print(error)
                    throw error
                }

        }
        
        var orgX = scrollViewSize.frame.width
        
        if let d = direction {
            switch d {
            case UISwipeGestureRecognizer.Direction.right:
                orgX = 1 - scrollViewSize.frame.width
                break
            default:
                break
            }
        }
        
        balanceCardView.frame = CGRect(x: orgX,
                                       y: 0,
                                       width: scrollViewSize.frame.width,
                                       height: scrollViewSize.frame.height)

        
        let gradient = CAGradientLayer()
        gradient.frame = balanceCardView.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.6)
        gradient.locations = [0.0, 1.0]
        let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0) /* #000000 */
        let color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) /* #333333 */
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.cornerRadius = 10

        balanceCardView.layer.insertSublayer(gradient, at: 0)
        balanceCardView.layer.cornerRadius = 10
        
        UIView.animate(withDuration: 0.5)
        {
            self.balanceCardView.frame.origin.x = 0
            self.balanceCardView.alpha = 1
        }
        
        return balanceCardView
        
    }
    
    func setTableView()
    {
                // Do any additional setup after loading the view, typically from a nib.
                pageControl.numberOfPages = Filtered.count
                pageControl.addTarget(self, action: #selector(changePage(_:)), for: .allTouchEvents)
                shoppingCart = []
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = CGRect(x: 0,
                                 y: tableView.frame.height,
                                 width: products.frame.width,
                                 height: products.frame.height)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        products.addSubview(tableView)
        
        UIView.animate(withDuration: 0.7)
        {
            self.products.frame.origin.y = 0
            self.products.alpha = 1
        }
        
        if Filtered.count != 0 { 
            if Filtered.count >= currentPage {
                do {
                    try scrollAreaView.addSubview(setCoinCard(scrollViewSize: scrollAreaView, layer: 0, coin: Filtered[currentPage]))
                } catch {
                    print(error)
                    
                } 
            }
        } else {
            
            if Filtered.count == 0 {
                
                pageControl.numberOfPages = 1
                let coin = digilira.DigiliraPayBalance.init(
                    tokenName: digilira.demoCoin.tokenName,
                    tokenSymbol: digilira.demoCoin.tokenSymbol,
                    availableBalance: 0,
                    decimal: digilira.demoCoin.decimal,
                    balance: 0,
                    tlExchange: 0,
                    network: "",
                    wallet: ""
                )
                
                balanceCardView = UIView().loadNib(name: "BalanceCard") as! BalanceCard
                balanceCardView.setView(desc: coin.tokenName,
                                        tl: "0",
                                        amount: "0",
                                        price: "0",
                                        symbol: coin.tokenName, icon: UIImage(named: "ico2"))
                
                balanceCardView.balanceTL.isHidden = true
                balanceCardView.balanceTLicon.isHidden = true
                balanceCardView.totalTitle.isHidden = true
                balanceCardView.willPaidCoin.isHidden = true
                balanceCardView.paidCoin.isHidden = true
                 
                balanceCardView.frame = CGRect(x: 0,
                                               y: 0,
                                               width: scrollAreaView.frame.width,
                                               height: scrollAreaView.frame.height)

                
                let gradient = CAGradientLayer()
                gradient.frame = balanceCardView.bounds
                gradient.startPoint = CGPoint(x: 0.0, y: 0.6)
                gradient.locations = [0.0, 1.0]
                let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0) /* #000000 */
                let color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) /* #333333 */
                gradient.colors = [color1.cgColor, color2.cgColor]
                gradient.cornerRadius = 10

                balanceCardView.layer.insertSublayer(gradient, at: 0)
                balanceCardView.layer.cornerRadius = 10
                
                UIView.animate(withDuration: 0.5)
                {
                    self.balanceCardView.frame.origin.x = 0
                    self.balanceCardView.alpha = 1
                }
                
                scrollAreaView.addSubview(balanceCardView)
                payButton.alpha = 0.4
                payButton.isUserInteractionEnabled = false
                
                errors?.errorCaution(message: "Ödeme yapabilmek için hesabınıza bakiye yüklemeniz gerekmektedir.", title: "Bakiye Yükleyin")
            }
        }
        
    }
    
}

extension PageCardView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingCart = []
        if let order = Order {
            if let products = order.products {
                for product in products {
                    if let productName = product.order_pname {
                        if let productPrice = product.order_price {
                            shoppingCart.append(digilira.shoppingCart.init(label: productName, price: productPrice, mode: 1))
                            
                        }
                    }
                }
            }
                
//                if  let kargo = order.orderShipping {
//                    shoppingCart.append(digilira.shoppingCart.init(label: "Kargo Ücreti", price: kargo, mode: 1))
//                }
                
               let total = order.totalPrice
                    shoppingCart.append(digilira.shoppingCart.init(label: "Toplam", price: total, mode: 2))
                
            
        }
        return shoppingCart.count
    }
    
    @objc func handleTap(recognizer: MyTapGesture) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = UITableViewCell().loadXib(name: "PayTableViewCell") as? PayTableViewCell
        {
            let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
            
            tapped.floatValue = indexPath[1]
            cell.addGestureRecognizer(tapped)
            
            cell.prodName.text = shoppingCart[indexPath[1]].label
            cell.prodPrice.text = "₺" + MainScreen.df2so(shoppingCart[indexPath[1]].price)
            
            
            switch shoppingCart[indexPath[1]].mode {
            case 2:
                cell.BGView.backgroundColor = .systemGreen
                break
            case -1:
                cell.discountView.isHidden = false
                break
            default:
                cell.BGView.backgroundColor = .clear
            }
            return cell
            
        }else
        { return UITableViewCell() }
    }
}

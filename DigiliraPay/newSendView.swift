//
//  newSendView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 18.10.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


class newSendView: UIView {
    var selectedCountry: String?
    
    weak var delegate: NewCoinSendDelegate?
    var balanceCardView = BalanceCard()

    @IBOutlet weak var recipient: UIView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var coinSwitch: UISegmentedControl!
    @IBOutlet weak var content: UIView!

    @IBOutlet weak var pasteLbl: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var fetchQR: UIImageView!
    @IBOutlet weak var recipientText: UILabel!
     
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollAreaView: UIView!
    weak var errors: ErrorsDelegate?

    let generator = UINotificationFeedbackGenerator()
    var direction: UISwipeGestureRecognizer.Direction?
    
    var currentPage: Int = 0
    var kullanici: digilira.auth?
    
    var address1: String?
    var assetId: String?
    
    var Filtered: [digilira.DigiliraPayBalance] = []
    var Coins: [digilira.coin] = []
    let BC = Blockchain()

    var transaction: SendTrx?
    private var amount: Double = 0.0
    private var price: Double = 0.0
    private var coinPrice: Double?
    private var usdPrice: Double?
 
    var Ticker: binance.BinanceMarketInfo = []
    let binanceAPI = binance()
    var ticker: digilira.ticker?

    private var decimal: Bool = false
    
    public var address: String?
    
    private var selectedCoinX: digilira.coin?
    private var selectedIndex: Int = 0
    
    let digiliraPay = digiliraPayApi()
    
    @objc func sendMoneyButton() {
        sendView.alpha = 0.4
        sendView.isUserInteractionEnabled = false
        var isMissing = false
        
        let isAmount = amount
 
        if let transaction = transaction {
            if transaction.destination == digilira.transactionDestination.foreign || transaction.destination == nil {
                if let coin = selectedCoinX {
                    if !checkAddress(network: coin.network, address: recipientText.text!) {
                        recipientText.textColor = .red
                        isMissing = true
                    }
                }
            }
        }
        
        
        if isMissing {
            shake()
            
            errors?.errorHandler(message: "Girdiğiniz bilgileri kontrol ederek tekrar deneyin.", title: "Bir Hata Oluştu", error: true)
            
            sendView.alpha = 1
            sendView.isUserInteractionEnabled = true
            return
        }
        
        if transaction?.network == digilira.transactionDestination.domestic {
            transaction?.memberCheck = true
            transaction?.destination = digilira.transactionDestination.domestic
        }
        
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            if !transaction!.memberCheck {
                if !checkAddress(network: coin.network, address: recipientText.text!) {
                    recipientText.textColor = .red
                    isMissing = true
                }
                
                let external = digilira.externalTransaction.init(network: coin.network,
                                                                 address: recipientText.text,
                                                                 amount: Int64(isAmount * double),
                                                                 assetId: coin.token)
                
                digiliraPay.onMember = { res, data in
                    DispatchQueue.main.async {
                        switch res {
                        case true:
                            let trx = SendTrx.init(merchant: data?.owner!,
                                                   recipient: (data?.wallet)!,
                                                   assetId: data?.assetId!,
                                                   amount: data?.amount!,
                                                   fee: digilira.sponsorTokenFee,
                                                   fiat: self.price * double,
                                                   attachment: data?.message,
                                                   network: data?.network!,
                                                   destination: data?.destination!,
                                                   massWallet: data?.wallet,
                                                   memberCheck: true
                            )
                            
                            
                            self.delegate?.sendCoinNew(params: trx)
                        default:
                            return
                        }
                    }
                }
                
                
                digiliraPay.isOurMember(external: external)
                
            }else {
                transaction?.amount = Int64(isAmount * double)
                delegate?.sendCoinNew(params: transaction!)
            }
             
        }
    }
    
    func eval(template: String, address: String) -> Bool {
        let addressTest = NSPredicate(format: "SELF MATCHES %@", template)
        let result = addressTest.evaluate(with: address)
        return result
    }
    
    func checkAddress(network: String, address: String) -> Bool {
        
        let bitcoinSegwit = "^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$"
        let bitcoinReg = "^[13][a-km-zA-HJ-NP-Z0-9]{26,33}$"
        let ethereumReg = "^0x[a-fA-F0-9]{40}$"
        let wavesreg = "^[3][a-zA-Z0-9]{34}"
        
        var regexString = wavesreg

        switch network {
        case digilira.bitcoin.network:
            regexString = bitcoinReg
        case digilira.ethereum.network:
            regexString = ethereumReg
            break
        case digilira.waves.network:
            regexString = wavesreg
            break
        default:
            break
        }
        
        let result = eval(template: regexString, address: address)
        
        if (!result) {
            let wavresult = eval(template: wavesreg, address: address)
             
            if wavresult {
                getPage(x: digilira.waves.tokenName)
                return true
            }
            
            let btcresult = eval(template: bitcoinReg, address: address)
            
            if btcresult {
                getPage(x: digilira.bitcoin.tokenName)
                return true
            }
             
            let btcresultSegwit = eval(template: bitcoinSegwit, address: address)
            
            if btcresultSegwit {
                getPage(x: digilira.bitcoin.tokenName)
                return true
            }
            
            let ethresult = eval(template: ethereumReg, address: address)
            
            if ethresult {
                getPage(x: digilira.ethereum.tokenName)
                return true
            }

        }
        
        if result {
            recipientText.textColor = .black
        }
        return result
    }
    
    func shakeScreen() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        
        self.layer.add(animation, forKey: "position")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.textColor = .black
        
        let str = textField.text
        let replaced = str!.replacingOccurrences(of: ",", with: ".")
        textField.text! = replaced
        
        var maxLength: Int = 8
        
        if replaced.contains(".") {
            decimal = true
        } else {
            decimal = false
        }
        
        let needle: Character = "."
        if let idx = str!.firstIndex(of: needle) {
            let pos = str!.distance(from: str!.startIndex, to: idx)
            maxLength = 9 + pos
            if pos > 8 {
                maxLength = 0
            }
            
        }
        else {
            print("Not found")
        }
        
        if  textField.text!.count > maxLength {
            if textField.text!.last != "." {
                textField.text!.removeLast()
            }
            return
        }
        
        
        if let coin = selectedCoinX {
            guard Float.init(textField.text!) != nil else {
                textField.text = ""
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                return
            }
            
            if textField.text == "" {
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                return}
            setCoinPrice()
            calcPrice(text: textField.text!)
        }
        
    }
    func setQR (params: SendTrx) {

        if params.destination == digilira.transactionDestination.foreign {

            recipientText.isEnabled = true
            textAmount.isEnabled = true
            pasteLbl.isHidden = false
            errors?.errorCaution(message: "Bu cüzdan adresi DigiliraPay'de kayıtlı bir adres değildir. Transferinizden komisyon ücreti düşecektir.", title: "Dikkat")
            scrollAreaView.isUserInteractionEnabled = false


        }
         
        findToken( tokenName: params.assetId! )
        
        switch params.network! {
        case digilira.bitcoin.network:
            selectedCoinX = digilira.bitcoin
        case digilira.ethereum.network:
            selectedCoinX = digilira.ethereum
        case digilira.waves.network, "domestic":
            
            recipientText.isEnabled = false
            textAmount.isEnabled = true
            scrollAreaView.isUserInteractionEnabled = false
            pasteLbl.isHidden = true

            switch params.assetId {
            case digilira.bitcoin.token:
                selectedCoinX = digilira.bitcoin
                break
            case digilira.ethereum.token:
                selectedCoinX = digilira.ethereum
                break
            case digilira.waves.token:
                selectedCoinX = digilira.waves
                break
            case digilira.charity.token:
                selectedCoinX = digilira.charity
                break
            default:
                return
                    setCoinPrice()
            }
        default:
            return
        }
        
        
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            amount = (Double(params.amount!) / double)
            price = Double(params.fiat!)
            

            recipientText.textColor = .black
            textAmount.textColor = .black
            
            recipientText.text = params.merchant
            
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
 
            if params.destination == digilira.transactionDestination.interwallets {

                recipientText.isEnabled = false
            }
            if params.destination == digilira.transactionDestination.domestic {

                recipientText.isEnabled = false
                textAmount.isEnabled = false
            }
            
            if params.destination == digilira.transactionDestination.foreign {
                let isValid = checkAddress(network: coin.network, address: params.merchant!)
                if !isValid {
                    recipientText.textColor = .red
                }
                
            }
        }
    }
    
    func getPage(x: String) {
        do {
            let y = try BC.returnCoin(tokenName: x)
            for (i, c) in Filtered.enumerated() {
                if y.tokenName == c.tokenName
                {
                    selectedCoinX = y
                    pageControl.currentPage = i
                    changePage(pageControl)
                    return
                }
            }
            errors?.errorHandler(message: y.tokenName + " bakiyeniz bulunmamaktadır.", title: "Bir Hata Oluştu", error: true)
        } catch  {
            print(error)
        }
    }
    
    func findToken(tokenName:String) {
        do {
            let x = try BC.returnAsset(assetId: tokenName)
            getPage(x:x.tokenName)
        } catch  {
            print(error)
        }
    }
    
    func setTextAmount() {
        if coinSwitch.selectedSegmentIndex == 0 { //₺
            textAmount.text = price.description
        }
        
        if coinSwitch.selectedSegmentIndex == 1 { //token
            textAmount.text = amount.description
        }
    }

    @objc func calcPrice(text: String) {
        if let coin = selectedCoinX {
            if text == "" {
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                return
            }
            if coinSwitch.selectedSegmentIndex == 0 { //₺
                price = Double.init(text)!
                amount =  price / (coinPrice!)
                
                    coinSwitch.setTitle("₺", forSegmentAt: 0)
                    coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)

                commissionLabel.text = "Transfer ücreti: " + String(format: "%." + coin.decimal.description + "f", (amount * 0.005))  + " " + coin.symbol
                balanceCardView.willPaidCoin.text = String(format: "%." + coin.decimal.description + "f", amount)

            }
            
            if coinSwitch.selectedSegmentIndex == 1 { //token
                amount = Double.init(text)!
                price = (coinPrice!) * amount
                
                    coinSwitch.setTitle("₺", forSegmentAt: 0)
                    coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)

                balanceCardView.willPaidCoin.text = String(format: "%." + coin.decimal.description + "f", amount)
                commissionLabel.text = "Transfer ücreti: " + String(format: "%." + coin.decimal.description + "f", (amount * 0.005))  + " " + coin.symbol
            }
            
        }
    }
    
       @objc func amounTap() {
        let rec = recipientText.text!
        if rec == "" {
            errors?.errorCaution(message: "Alıcı eklemek için Yapıştır ve QR kod butonlarını kullanabilirsiniz. ", title: "Dikkat")
        }

        

       }
    
    @IBAction func pasteAddress(_ sender: Any) {

        weak var pb: UIPasteboard? = .general
        guard let text = pb?.string else { return}
        recipientText.textColor = .black
        
        if let coin = selectedCoinX {
            if checkAddress(network: coin.network, address: text) {
                recipientText.text = text
                memCheck()
                
            } else {
                errors?.errorHandler(message: "Geçerli bir adres bulunamadı. Seçtiğiniz kripto varlık ile göndermek istediğiniz adresin uyuştuğunu kontrol ediniz. \n\nYapıştırmaya çalıştığınız adres:\n\n" + text, title: "Tekrar Deneyin", error: true)
            }
        }
        
        
       
     
    }
    
    func memCheck() {
        let isAmount = amount
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            let external = digilira.externalTransaction.init(network: coin.network,
                                                             address: recipientText.text,
                                                             amount: Int64(isAmount * double),
                                                             assetId: coin.token)
            
            digiliraPay.onMember = { res, data in
                DispatchQueue.main.async { [self] in
                    switch res {
                    case true:
                        
                        transaction?.merchant = data?.owner!
                        transaction?.recipient = (data?.wallet)!
                        transaction?.assetId = data?.assetId!
                        transaction?.amount = data?.amount!
                        transaction?.fee = digilira.sponsorTokenFee
                        transaction?.fiat = self.price * double
                        transaction?.attachment = data?.message
                        transaction?.network = data?.network!
                        transaction?.destination = data?.destination!
                        transaction?.massWallet = data?.wallet
                        transaction?.memberCheck = true
                         
                        recipientText.text = data?.owner
                         
                    default:
                        return
                    }
                }
            }
            digiliraPay.isOurMember(external: external)
        }
    }
    
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        transaction = nil
        delegate?.dismissNewSend()
    }
    
    
    override func awakeFromNib()
    {
        
        transaction?.destination = digilira.transactionDestination.foreign
        
        do {
            let user = try secretKeys.userData()
            kullanici = user
        } catch {
            print (error)
        }
        
        coinSwitch.selectedSegmentIndex = 1
        sendView.layer.cornerRadius = 25
         
        setShad(view: scrollAreaView, cornerRad: 10, mask: true)
        setShad(view: content, mask: false)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let recipientTap = UITapGestureRecognizer(target: self, action: #selector(amounTap))

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        scrollAreaView.addGestureRecognizer(leftSwipe)
        scrollAreaView.addGestureRecognizer(rightSwipe)
        recipient.isUserInteractionEnabled = true
        recipient.addGestureRecognizer(recipientTap)
 
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = false
        
        let tapSend: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendMoneyButton))
        sendView.isUserInteractionEnabled = true
        sendView.addGestureRecognizer(tapSend)
        
        textAmount?.addDoneCancelToolbar()
        textAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        coinSwitch.selectedSegmentIndex = 1
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getQR))
        fetchQR.isUserInteractionEnabled = true
        fetchQR.addGestureRecognizer(tap)
        
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(switchChanged))
        coinSwitch.addGestureRecognizer(tap2)
                 
        textAmount.layer.cornerRadius = 5
        recipientText.layer.cornerRadius = 5


    }
    
    @objc func switchChanged() {
        if coinSwitch.selectedSegmentIndex == 1 {
            coinSwitch.selectedSegmentIndex = 0
        } else {
            coinSwitch.selectedSegmentIndex = 1
        }
        
        changePage(pageControl)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        recipientText.text = ""
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
    
    @IBAction func changePage(_ sender: UIPageControl) {
        
        
        currentPage = sender.currentPage
        setBalanceView(index: sender.currentPage)
        setAdress()

        setCoinPrice()
        calcPrice(text: textAmount.text!)
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
    
    
    func setAdress()  {

        do {
            let c = try BC.returnCoin(tokenName: Filtered[currentPage].tokenName)
            selectedCoinX = c
        } catch {
            print(error)
        }
         
    }
 
    func setCoinCard(scrollViewSize: UIView, layer: CGFloat, coin:digilira.DigiliraPayBalance) throws -> UIView {
        balanceCardView = UIView().loadNib(name: "BalanceCard") as! BalanceCard
        let ticker = digiliraPay.ticker(ticker: Ticker)
        
                do {
                    let (_, asset, tlfiyat) = try digiliraPay.ratePrice(price: amount, asset: coin.tokenName, symbol: ticker, digits: coin.decimal, network: coin.network)
                    
                    balanceCardView.setView(desc: coin.tokenName,
                                            tl: MainScreen.df2so(tlfiyat),
                                            amount: MainScreen.int2so(coin.availableBalance, digits: coin.decimal),
                                            price: MainScreen.int2so(Int64(amount), digits: coin.decimal),
                                            symbol: coin.tokenName)
                    
                    balanceCardView.balanceTL.isHidden = true
                    balanceCardView.balanceTLicon.isHidden = true
                    balanceCardView.totalTitle.isHidden = true
                    if coin.availableBalance >= (Int64(amount)) {
                        
                        
                    } else {
                        balanceCardView.willPaidCoin.textColor = .systemPink
                        balanceCardView.paidCoin.textColor = .systemPink
                        balanceCardView.balanceCoin.textColor = .systemPink
                       
                    }
                    
                    if (asset == "TL") {
                        balanceCardView.willPaidCoin.textColor = .systemPink
                        balanceCardView.paidCoin.textColor = .systemPink
                        balanceCardView.balanceCoin.textColor = .systemPink
                       
                        shake()
                    }
                } catch  {
                    print(error)
                    throw error
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
    
    private func setShad(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
    
    func setCoinPrice () {
        if let coin = selectedCoinX {
            _ = Double(truncating: pow(10,coin.decimal) as NSNumber)

            if let fiyatlama = ticker {
                
                switch coin.network {
                case digilira.bitcoin.network:
                    coinPrice = (fiyatlama.btcUSDPrice)! * (fiyatlama.usdTLPrice)!
                    break
                case digilira.ethereum.network:
                    coinPrice = (fiyatlama.ethUSDPrice)! * (fiyatlama.usdTLPrice)!
                    break
                case digilira.waves.network:
                    switch coin.tokenName {
                    case digilira.waves.tokenName:
                        coinPrice = (fiyatlama.wavesUSDPrice)! * (fiyatlama.usdTLPrice)!
                        break
                    case digilira.charity.tokenName:
                        coinPrice = 1
                        break
                    default:
                        coinPrice = 0
                    }
                    break
                case "digilira":
                    coinPrice = 0
                    break
                default:
                    coinPrice = 0
                    break
                }
                calcPrice(text: textAmount.text!)
            }

        }
    }
    
    func set() {
        
        if Filtered.count == 0 {
            return
        }
        
        do {
            try scrollAreaView.addSubview(setCoinCard(scrollViewSize: scrollAreaView, layer: 0, coin: Filtered[currentPage]))
        } catch {
            print(error)
        }
        
        pageControl.numberOfPages = Filtered.count
        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .allTouchEvents)
        
        setBalanceView(index: currentPage)
        setAdress()

        setCoinPrice()
        calcPrice(text: textAmount.text!)
    }
    
    override func didMoveToSuperview() {
        if (transaction != nil) {
            setQR(params: transaction!)
        }
    }
    
    @objc func getQR () {
        transaction = nil
        delegate?.readAddressQR()
    }
 
    @objc func action1() {
        self.endEditing(true)
    }
}


extension UITextField {
    
    enum PaddingSpace {
        case left(CGFloat)
        case right(CGFloat)
        case equalSpacing(CGFloat)
    }
    
    func addPadding(padding: PaddingSpace) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        switch padding {
        
        case .left(let spacing):
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always
            
        case .right(let spacing):
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = rightPaddingView
            self.rightViewMode = .always
            
        case .equalSpacing(let spacing):
            let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = equalPaddingView
            self.leftViewMode = .always
            // right
            self.rightView = equalPaddingView
            self.rightViewMode = .always
        }
    }
}



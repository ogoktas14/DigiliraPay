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
    @IBOutlet weak var recipientText: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var b10: UIView!
    @IBOutlet weak var b100: UIView!
    @IBOutlet weak var b50: UIView!
    @IBOutlet weak var b25: UIView!
    weak var errors: ErrorsDelegate?
    let lang = Localize()

    let generator = UINotificationFeedbackGenerator()
    var direction: UISwipeGestureRecognizer.Direction?
    
    var currentPage: Int = 0
    var kullanici: Constants.auth?
    
    var address1: String?
    var assetId: String?
    
    var isWavesNetwork: Bool = false
    var isEthereumNetwork: Bool = false

    var Filtered: [Constants.DigiliraPayBalance] = []
    var Coins: [WavesListedToken] = []
    let BC = BlockchainService()
    
    var transaction: SendTrx?
    private var amount: Double = 0.0
    private var price: Double = 0.0
    private var coinPrice: Double?
    private var usdPrice: Double?
    
    var Ticker: BinanceService.BinanceMarketInfo = []
    let binanceAPI = BinanceService()
    var ticker: Constants.ticker?
    
    private var decimal: Bool = false
    
    public var address: String?
    
    private var selectedCoinX: WavesListedToken?
    private var selectedIndex: Int = 0
    
    let digiliraPay = DigiliraPayService()

    @objc func sendMoneyButton() {
        
        sendView.alpha = 0.4
        sendView.isUserInteractionEnabled = false
        var isMissing = false
        
        let isAmount = amount
        
        guard var t = transaction else {
            return
        }
        
        if !isWavesNetwork {
            if t.destination == Constants.transactionDestination.foreign {
                if let coin = selectedCoinX {
                    if !isEthereumNetwork {
                        if !checkAddress(network: coin.network, address: recipientText.title(for: .normal)!) {
                            recipientText.setTitleColor(.red, for: .normal)
                            isMissing = true
                        }
                    }

                }
            }
            if t.destination == Constants.transactionDestination.interwallets {
        
                if recipientText.title(for: .normal  ) == "" {
                        recipientText.setTitleColor(.red, for: .normal)
                        isMissing = true
                    }
                
            }
        } else {
            if t.destination == Constants.transactionDestination.foreign {
                t.destination = Constants.transactionDestination.unregistered
                t.recipient = t.externalAddress
                transaction = t
            }
        }
        
        
        if isMissing {
            shake()
            
            errors?.evaluate(error: Constants.NAError.missingParameters)
            
            sendView.alpha = 1
            sendView.isUserInteractionEnabled = true
            return
        }
        
        if t.network == Constants.transactionDestination.domestic {
            t.memberCheck = true
            t.destination = Constants.transactionDestination.domestic
        }
        
        if let user = kullanici {
            if let name = user.firstName {
                if let surname = user.lastName {
                    t.me = name + " " + surname
                }
            }
        }
        
        t.fiat = price
         
        if let coin = selectedCoinX {
            
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            t.amount = Int64(isAmount * double)
            var minAmount = 0
            var minTotal = minAmount

            switch coin.tokenName {
            case "Bitcoin":
                if t.destination != Constants.transactionDestination.foreign  {
                    minAmount = 300
                    minTotal = minAmount
                } else {
                    minAmount = 100000
                    minTotal = Int((coin.gatewayFee) * (double) ) + minAmount
                }
                break
            case "Ethereum":
                if t.destination != Constants.transactionDestination.foreign  {
                    minAmount = 10000
                    minTotal = minAmount
                } else {
                    minAmount = 1000000
                    minTotal = Int((coin.gatewayFee) * (double) ) + minAmount
                }
                break
            case "Waves":
                minAmount = 1000000
                minTotal = minAmount
                break
            case "Tether USDT":
                if t.destination != Constants.transactionDestination.foreign {
                    minAmount = 100000
                    minTotal = minAmount
                } else {
                    minAmount = 10000000
                    minTotal = Int((coin.gatewayFee) * (double) ) + minAmount
                }
                break
            default:
                minAmount = Int(double)
                minTotal = minAmount
                break
            }
            
            if t.amount! < minTotal {

                sendView.alpha = 1
                sendView.isUserInteractionEnabled = true
                errors?.evaluate(error: Constants.NAError.noAmount)
                return
            }
            transaction = t
            checkConfirmation()
        }
    }
    
    func eval(template: String, address: String) -> Bool {
        let addressTest = NSPredicate(format: "SELF MATCHES %@", template)
        let result = addressTest.evaluate(with: address)
        return result
    }
    
    func checkAddress(network: String, address: String) -> Bool {
        isWavesNetwork = false
        isEthereumNetwork = false
        let env = BC.returnEnv()
        
        var bitcoinSegwit = "^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,62}$"
        if env == "testnet" {
            bitcoinSegwit = "^(tb1|[13])[a-zA-HJ-NP-Z0-9]{25,62}$"
        }
        
        let bitcoinReg = "^(m[a-z]|[13])[a-km-zA-HJ-NP-Z0-9]{26,33}$"
        let ethereumReg = "^0x[a-fA-F0-9]{40}$"
        let wavesreg = "^[3][a-zA-Z0-9]{34}"
        
        var regexString = wavesreg
        
        switch network {
        case Constants.bitcoinNetwork:
            regexString = bitcoinReg
        case Constants.ethereumNetwork:
            regexString = ethereumReg
            break
        case Constants.wavesNetwork:
            regexString = wavesreg
            break
        default:
            break
        }
        
        let result = eval(template: regexString, address: address)
        
        if (!result) {
            let wavresult = eval(template: wavesreg, address: address)
            
            if wavresult {
                getPage(x: Constants.wavesNetwork)
                isWavesNetwork = true
                return true
            }
            
            let btcresult = eval(template: bitcoinReg, address: address)
            
            if btcresult {
                getPage(x: Constants.bitcoinNetwork)
                return true
            }
            
            let btcresultSegwit = eval(template: bitcoinSegwit, address: address)
            
            if btcresultSegwit {
                getPage(x: Constants.bitcoinNetwork)
                return true
            }
            
            let ethresult = eval(template: ethereumReg, address: address)
            
            if ethresult {
                isEthereumNetwork = true
                getPage(x: Constants.ethereumNetwork)
                return true
            }
        }
        
        if result {
            getPage(x: network)
            recipientText.setTitleColor(.black, for: .normal)
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
        
        let floatRegex = "^[0-9]*(?:.[0-9]*)?$"
        let result = eval(template: floatRegex, address: textField.text!)
        if !result {
            textField.text = ""
        }
        textField.textColor = .black
        
        guard let str = textField.text else {
            errors?.evaluate(error: Constants.NAError.missingParameters)
            return
        }
        
        let replaced = str.replacingOccurrences(of: ",", with: ".")
        textField.text = replaced
        
        var maxLength: Int = 8
        
        if replaced.contains(".") {
            decimal = true
        } else {
            decimal = false
        }
        
        let needle: Character = "."
        if let idx = str.firstIndex(of: needle) {
            let pos = str.distance(from: str.startIndex, to: idx)
            maxLength = 9 + pos
            if pos > 8 {
                maxLength = 0
            }
            
        }
        
        if  str.count > maxLength {
            if str.last != "." {
                textField.text!.removeLast()
            }
            return
        }
        setCoinPrice()
    }
    
    @objc func proceed2Transfer(_ sender: Notification) {
        
        if let data = sender.userInfo {
            if let result = data["confirmation"] {
                if result as! Bool {
                    
                    guard let params = transaction else {
                        errors?.evaluate(error: Constants.NAError.anErrorOccured)
                        return
                    }
                    delegate?.sendCoinNew(params: params)
                    
                }
                sendView.alpha = 1
                sendView.isUserInteractionEnabled = true
            }
        }
    }
    
    func checkConfirmation() {
        guard let coin = selectedCoinX else {
            return
        }
        if let t = transaction {
            
            guard let m = t.amount else {return}
            guard t.recipient != "" && t.recipient != nil else {return}
            
            let balance = Filtered[currentPage].availableBalance
            
            //TO-DO check destination and calculate fee margin
            
            var komisyon:Double = 0.005
            var komisyonCoin = "Waves"
            var remark = lang.getLocalizedString(Localize.keys.fee_remark_unregistered.rawValue)
            
            var agKomisyonu: Double = 0
            var agCoin = coin.tokenName

            if t.destination == Constants.transactionDestination.foreign {
                
                agKomisyonu = coin.gatewayFee
                agCoin = coin.tokenName
                
                komisyon = 5
                komisyonCoin = "DigiliraPay"
            }
            
            if  t.destination == Constants.transactionDestination.interwallets {
                
                komisyon = 5
                komisyonCoin = "DigiliraPay"
                remark = lang.getLocalizedString(Localize.keys.fee_remark_interwallets.rawValue)
            }
            
            if balance < m {
                errors?.errorCaution(message: lang.getLocalizedString(Localize.keys.out_of_balance_message.rawValue), title: lang.getLocalizedString(Localize.keys.out_of_balance_header.rawValue))
                sendView.isUserInteractionEnabled = true
                sendView.alpha = 1
                return
            }
            
            let miktar = m.int2FormattedString(digits: coin.decimal) + " " + coin.tokenSymbol
            var minTotal = miktar

            if t.destination == Constants.transactionDestination.foreign {
                let double = Double(m) / Double(truncating: pow(10,coin.decimal) as NSNumber)
                minTotal = String(format: "%." + coin.decimal.description + "f", double - agKomisyonu) + " " + coin.tokenSymbol
                remark = lang.getLocalizedString(Localize.keys.fee_remark_foreign.rawValue)
            }
             
            let confirmationMessage = Constants.txConfMsg.init(
                title: lang.getLocalizedString(Localize.keys.transfer_confirmation.rawValue),
                message: lang.getLocalizedString(Localize.keys.check_your_transfer.rawValue),
                l1: t.merchant!,
                sender: t.me,
                l2: minTotal,
                l3: komisyon.description + " " + komisyonCoin,
                l4: miktar,
                t2: agKomisyonu.description + " " + agCoin , 
                c2: coin.tokenName,
                yes: lang.getLocalizedString(Localize.keys.confirm.rawValue),
                remark: remark,
                no:lang.getLocalizedString(Localize.keys.reject.rawValue),
                icon: "caution"
            )
            errors?.transferConfirmation(txConMsg: confirmationMessage, destination: .trxConfirm)
        }
    }
    
    func foreignTrx() {
        errors?.errorCaution(message: lang.getLocalizedString(Localize.keys.not_digilirapay_wallet.rawValue), title: lang.getLocalizedString(Localize.keys.attention.rawValue))
    }
    
    func setQR () {
        
        guard let params = transaction else {
            errors?.evaluate(error: Constants.NAError.anErrorOccured)
            return
        }
        
        if params.destination == Constants.transactionDestination.foreign {
            
            recipientText.isEnabled = true
            textAmount.isEnabled = true
            foreignTrx()
            scrollAreaView.isUserInteractionEnabled = false
        }
        
        if params.recipient == "" {
            scrollAreaView.isUserInteractionEnabled = true
        } else {
            scrollAreaView.isUserInteractionEnabled = false
        }
        
        findToken( tokenName: params.assetId! )
        
        recipientText.isEnabled = true
        textAmount.isEnabled = true
        
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            amount = (Double(params.amount!) / double)
            price = Double(params.fiat)
            
            if let text = textAmount.text {
                if text != "" {
                    if text != amount.description {
                        calcPrice(text: text)
                    }
                }
            }
            
            recipientText.setTitleColor(.black, for: .normal)
            textAmount.textColor = .black
            
            recipientText.setTitle(params.merchant, for: .normal)
            
            coinSwitch.setTitle("₺", forSegmentAt: 0)
            coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
            
            if params.destination == Constants.transactionDestination.interwallets {
                
                recipientText.isEnabled = true
            }
            if params.destination == Constants.transactionDestination.domestic {
                
                recipientText.isEnabled = true
                textAmount.isEnabled = false
            }
            
            if params.destination == Constants.transactionDestination.foreign {
                let isValid = checkAddress(network: coin.network, address: params.merchant!)
                if !isValid {
                    recipientText.setTitleColor(.red, for: .normal)
                }
            }
        }
    }
    
    func getPage(x: String) {
        var X = x
        if let au = assetId {
            X = au
            isWavesNetwork = false
            isEthereumNetwork = false
        }
        
        do {
            let y = try BC.returnAsset(assetId: X)
            
            if y.network == "waves" {
                isWavesNetwork = true
                scrollAreaView.isUserInteractionEnabled = true
            }
            if y.network == "ethereum" {
                isEthereumNetwork = true
                scrollAreaView.isUserInteractionEnabled = true
            }
            for (i, c) in Filtered.enumerated() {
                if y.tokenName == c.tokenName
                {
                    selectedCoinX = y
                    pageControl.currentPage = i
                    changePage(pageControl)
                    return
                }
            }
            DispatchQueue.main.async { [self] in
                let localizedString = String(format: lang.getLocalizedString(Localize.keys.x_token_balance_not_found.rawValue), y.tokenName)
                
                errors?.errorHandler(message: localizedString,
                                     title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                                     error: true)
            }
        } catch  {
            DispatchQueue.main.async { [self] in
                errors?.errorHandler(message: lang.getLocalizedString(Localize.keys.token_not_supported.rawValue),
                                     title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue),
                                     error: true)
            }
            return
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
  
    @objc func calcPrice(text: String) {
        if let coin = selectedCoinX {
            if text == "" {
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                amount = 0
                balanceCardView.willPaidCoin.text = String(format: "%." + coin.decimal.description + "f", 0)
                return
            }
            if coinSwitch.selectedSegmentIndex == 0 { //₺
                if let d = Double.init(text) {
                    price = d
                }
                amount =  price / (coinPrice!)
                
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                
                balanceCardView.willPaidCoin.text = String(format: "%." + coin.decimal.description + "f", amount)
            }
            
            if coinSwitch.selectedSegmentIndex == 1 { //token
                if let d = Double.init(text) {
                    amount = d
                }
                price = (coinPrice!) * amount
                
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                
                balanceCardView.willPaidCoin.text = String(format: "%." + coin.decimal.description + "f", amount)
            }
            if let t = transaction {
                 
                var minAmount: Double = 0
                switch coin.tokenName {
                case "Bitcoin":
                    if t.destination == Constants.transactionDestination.interwallets || isWavesNetwork {
                        minAmount = 0.000003
                    } else {
                        minAmount = 0.001
                    }
                    break
                case "Ethereum":
                    if t.destination == Constants.transactionDestination.interwallets || isWavesNetwork {
                        minAmount = 0.0001
                    } else {
                        minAmount = 0.01
                    }
                    break
                case "Waves":
                    minAmount = 0.01
                    break
                case "Tether USDT":
                    if t.destination == Constants.transactionDestination.interwallets || isWavesNetwork {
                        minAmount = 0.1
                    } else {
                        minAmount = 10
                    }
                    break
                default:
                    minAmount = 1
                    break
                }

                if t.destination == Constants.transactionDestination.foreign && !isWavesNetwork {
                    let minTotal = coin.gatewayFee + minAmount
                    let localizedString = String(format: lang.getLocalizedString(Localize.keys.commision_info.rawValue),
                                                 coin.network.capitalized,
                                                 minAmount.description,
                                                 coin.tokenName,
                                                 coin.tokenName,
                                                 coin.gatewayFee.description,
                                                 coin.tokenName,
                                                 minTotal.description,
                                                 coin.tokenName,
                                                 coin.network.capitalized
                                                 )

                    commissionLabel.text = localizedString
                    if isEthereumNetwork {
                        if coin.tokenName != "Tether USDT" && coin.tokenName != "Ethereum" {
                            let localizedString = String(format: lang.getLocalizedString(Localize.keys.cannot_send_x_token_to_x_network.rawValue), Constants.ethereumNetwork.capitalized, coin.tokenName)
                            
                            sendView.isUserInteractionEnabled = false
                            sendView.alpha = 0.4
                            commissionLabel.text = localizedString
                        } else {
                            sendView.isUserInteractionEnabled = true
                            sendView.alpha = 1
                        }
                    }
                    commissionLabel.isHidden = false
                } else {
                    let localizedString = String(format: lang.getLocalizedString(Localize.keys.min_transfer_amount.rawValue), String(format: "%.\(coin.decimal)f", minAmount), coin.tokenName)
                    commissionLabel.text = localizedString
                    commissionLabel.isHidden = false
                    
                    if t.destination != Constants.transactionDestination.interwallets {
                        if coin.symbol == "ONET" {
                            sendView.isUserInteractionEnabled = false
                            sendView.alpha = 0.4
                            
                                let localizedString = String(format: lang.getLocalizedString(Localize.keys.cannot_send_x_token_to_x_network.rawValue), Constants.wavesNetwork.capitalized, coin.tokenName)
                            
                            commissionLabel.text = localizedString
                        } else {
                            sendView.isUserInteractionEnabled = true
                            sendView.alpha = 1
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func pasteAddress(_ sender: Any) {
        
        weak var pb: UIPasteboard? = .general
        guard let text = pb?.string else { return}
        recipientText.setTitleColor(.black, for: .normal)
        
        if let coin = selectedCoinX {
            var adres = text
            
            let isWavesAsset = text.components(separatedBy: "&assetId=")
            
            if isWavesAsset.count > 1 {
                assetId = isWavesAsset[1].description
                
                let wavesAddress = isWavesAsset[0].components(separatedBy: "?amount=")
                
                adres = wavesAddress[0]
            }
            
            if checkAddress(network: coin.network, address: adres) {
                recipientText.setTitle(adres, for: .normal)
                
                scrollAreaView.isUserInteractionEnabled = false
                
                if isWavesNetwork {
                    scrollAreaView.isUserInteractionEnabled = true
                }
                
                if isEthereumNetwork {
                    scrollAreaView.isUserInteractionEnabled = true
                }
                
                memCheck()
                
            } else {
                let localizedString = String(format: lang.getLocalizedString(Localize.keys.cannot_find_a_valid_address.rawValue), text)
                errors?.errorHandler(message: localizedString, title: lang.getLocalizedString(Localize.keys.try_again.rawValue), error: true)
            }
        }
    }
    
    func memCheck() {
        errors?.waitPlease()
        let isAmount = amount
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            let external = Constants.externalTransaction.init(network: coin.network,
                                                             address: recipientText.title(for: .normal),
                                                             amount: Int64(isAmount * double),
                                                             assetId: coin.token)
            BC.onError = { [self] res in
                errors?.removeWait()
                errors?.evaluate(error: Constants.NAError.E_400)
            }
            
            BC.onMember = { res, data in
                DispatchQueue.main.async { [self] in
                    if (data?.isTether)! {
                        getPage(x: "Tether USDT")
                    }
                    errors?.removeWait()
                    switch res {
                    case true:
                        
                        guard let data = data else {
                            errors?.evaluate(error: Constants.NAError.anErrorOccured)
                            return
                        }
                        
                        if data.destination == Constants.transactionDestination.foreign {
                            foreignTrx()
                        }
                        
                        if var t = transaction {
                            t.merchant = data.owner!
                            t.externalAddress = data.owner!
                            t.recipient = (data.wallet)!
                            t.assetId = data.assetId!
                            t.amount = data.amount!
                            t.fee = Constants.sponsorTokenFee
                            t.fiat = self.price * double
                            t.attachment = data.message
                            t.network = data.network!
                            t.destination = data.destination!
                            t.massWallet = data.wallet
                            t.memberCheck = true
                            recipientText.setTitle(data.owner, for: .normal)
                            
                            if data.destination == Constants.transactionDestination.interwallets {
                                t.feeAssetId = Constants.sponsorToken
                            }
                            
                            if data.destination == Constants.transactionDestination.foreign {
                                t.feeAssetId = ""
                            }
                            
                            transaction = t
                        }
                    case false:
                        break
                    }
                }
            }
            BC.isOurMember(external: external)
        }
    }
     
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend()
    }
    
    override func awakeFromNib()
    {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(proceed2Transfer), name: .trxConfirm, object: nil)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        scrollAreaView.addGestureRecognizer(leftSwipe)
        scrollAreaView.addGestureRecognizer(rightSwipe)
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = false
        
        let tapSend: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendMoneyButton))
        sendView.isUserInteractionEnabled = true
        sendView.addGestureRecognizer(tapSend)
        
        let tapB100: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bXXX(_:)))
        let tapB050: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bXXX(_:)))
        let tapB025: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bXXX(_:)))
        let tapB010: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bXXX(_:)))
        
        b100.isUserInteractionEnabled = true
        b50.isUserInteractionEnabled = true
        b25.isUserInteractionEnabled = true
        b10.isUserInteractionEnabled = true
        
        b100.addGestureRecognizer(tapB100)
        b50.addGestureRecognizer(tapB050)
        b25.addGestureRecognizer(tapB025)
        b10.addGestureRecognizer(tapB010)
        
        b100.alpha = 0.4
        b50.alpha = 0.4
        b25.alpha = 0.4
        b10.alpha = 0.4
        
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
    
    @objc func bXXX(_ g: UITapGestureRecognizer) {
        let balance = Filtered[currentPage].availableBalance
        let decimal = Filtered[currentPage].decimal
        generator.notificationOccurred(.success)

        b100.alpha = 0.4
        b50.alpha = 0.4
        b25.alpha = 0.4
        b10.alpha = 0.4
        
        switch g.view?.restorationIdentifier {
        case "b100":
            textAmount.text = balance.int2FormattedString(digits: decimal)
            b100.alpha = 1
            break
        case "b50":
            textAmount.text = (balance / 2).int2FormattedString(digits: decimal)
            b50.alpha = 1
            break
        case "b25":
            textAmount.text = (balance / 4).int2FormattedString(digits: decimal)
            b25.alpha = 1
            break
        case "b10":
            textAmount.text = (balance / 10).int2FormattedString(digits: decimal)
            b10.alpha = 1
            break
        default:
            textAmount.text = "0"
            break
        }
        calcPrice(text: textAmount.text!)
    }
    
    @objc func switchChanged() {
        if coinSwitch.selectedSegmentIndex == 1 {
            coinSwitch.selectedSegmentIndex = 0
            
            b100.alpha = 0.2
            b50.alpha = 0.2
            b25.alpha = 0.2
            b10.alpha = 0.2
            
            b100.isUserInteractionEnabled = false
            b50.isUserInteractionEnabled = false
            b25.isUserInteractionEnabled = false
            b10.isUserInteractionEnabled = false
            
        } else {
            coinSwitch.selectedSegmentIndex = 1
            
            b100.alpha = 0.4
            b50.alpha = 0.4
            b25.alpha = 0.4
            b10.alpha = 0.4
            
            b100.isUserInteractionEnabled = true
            b50.isUserInteractionEnabled = true
            b25.isUserInteractionEnabled = true
            b10.isUserInteractionEnabled = true
        }
         
        changePage(pageControl)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if !isWavesNetwork && !isEthereumNetwork {
            recipientText.setTitle("", for: .normal)
        }
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
    
    @IBAction func tapRecipient(_ sender: UIButton) {
        let rec = recipientText.title(for: .normal)
        if rec == "" {
            errors?.errorCaution(message: lang.getLocalizedString(Localize.keys.use_buttons_to_add_an_address.rawValue),
                                 title: lang.getLocalizedString(Localize.keys.attention.rawValue))
        }
    }
    
    @IBAction func changePage(_ sender: UIPageControl) {
        
        currentPage = sender.currentPage
        setBalanceView(index: sender.currentPage)
        setAdress()
        
        setCoinPrice()
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
            let c = try BC.returnAsset(assetId: Filtered[currentPage].tokenName)
            selectedCoinX = c
            
            if var t = transaction {
                
                t.assetId = c.token
                t.network = c.network
                
                transaction = t
            }
        } catch {
            print(error)
        }
    }
    
    func setCoinCard(scrollViewSize: UIView, layer: CGFloat, coin:Constants.DigiliraPayBalance) throws -> UIView {
        balanceCardView = UIView().loadNib(name: "BalanceCard") as! BalanceCard
        let ticker = digiliraPay.ticker(ticker: Ticker)
        
        if isEthereumNetwork {
            if coin.tokenName != "Tether USDT" && coin.tokenName != "Ethereum" {
                sendView.isUserInteractionEnabled = false
                sendView.alpha = 0.4
            } else {
                sendView.isUserInteractionEnabled = true
                sendView.alpha = 1
            }
        }
        
        do {
            let (_, asset, tlfiyat) = try digiliraPay.ratePrice(price: amount, asset: coin, symbol: ticker)
            
            balanceCardView.setView(desc: coin.tokenName,
                                    tl: MainScreen.df2so(tlfiyat),
                                    amount: coin.availableBalance.int2FormattedString(digits: coin.decimal),
                                    price: (Int64(amount).int2FormattedString(digits: coin.decimal)),
                                    symbol: coin.tokenName, icon: UIImage(named: coin.tokenName))
            
            balanceCardView.balanceTL.isHidden = true
            balanceCardView.balanceTLicon.isHidden = true
            balanceCardView.totalTitle.isHidden = false
            balanceCardView.totalTitle.text = lang.getLocalizedString(Localize.keys.ammount_to_be_sent.rawValue)
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
            
            if let fiyatlama = ticker {
                
                switch coin.network {
                case Constants.bitcoinNetwork:
                    coinPrice = (fiyatlama.btcUSDPrice)! * (fiyatlama.usdTLPrice)!
                    break
                case Constants.ethereumNetwork:
                    switch coin.symbol {
                    case "ETH", "WETH":
                        if let tl = fiyatlama.usdTLPrice {
                            if let eth = fiyatlama.ethUSDPrice {
                                coinPrice = (eth * tl)
                            }
                        }
                    case "USDT":
                            if let usdt = fiyatlama.usdTLPrice {
                                let tick = (usdt)
                                coinPrice = tick
                            }
                        break
                    default:
                        break
                    }
                    break
                case Constants.wavesNetwork:
                    switch coin.tokenName {
                    case Constants.waves.tokenName:
                        coinPrice = (fiyatlama.wavesUSDPrice)! * (fiyatlama.usdTLPrice)!
                        break
                    default:
                        coinPrice = 1
                    }
                    break
                case "digilira":
                    coinPrice = 1
                    break
                default:
                    coinPrice = 1
                    break
                }
                calcPrice(text: textAmount.text!)
            }
        }
    }
    
    func set() {
        
        if Filtered.count == 0 {
            coinSwitch.isUserInteractionEnabled = false
            sendView.isUserInteractionEnabled = false
            sendView.alpha = 0.4
            pageControl.numberOfPages = 1
            let coin = Constants.DigiliraPayBalance.init(
                tokenName: Constants.demoCoin.tokenName,
                tokenSymbol: Constants.demoCoin.tokenSymbol,
                availableBalance: 0,
                decimal: Constants.demoCoin.decimal,
                balance: 0,
                tlExchange: 0,
                network: "",
                wallet: kullanici!.wallet
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
            errors?.errorCaution(message: lang.getLocalizedString(Localize.keys.deposit_to_send_tokens_message.rawValue), title: lang.getLocalizedString(Localize.keys.deposit_to_send_tokens_header.rawValue))  
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
    }
    
    override func didMoveToSuperview() {
        
    }
    
    @objc func getQR () {
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

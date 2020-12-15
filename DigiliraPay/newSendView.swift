//
//  newSendView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 18.10.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


class newSendView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedCountry: String?
    
    weak var delegate: NewCoinSendDelegate?
    
    var pickerData: [digilira.coin] = [digilira.coin]()
    let thePicker = UIPickerView()
    
    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var siparis: UIView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var coinLbl: UILabel!
    @IBOutlet weak var coinTextField: UITextField!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var coinSwitch: UISegmentedControl!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var fetchQR: UIImageView!
    @IBOutlet weak var recipientText: UITextField!
    @IBOutlet weak var adresBtn: UIButton!
    
    var transaction: SendTrx?
    private var amount: Double = 0.0
    private var price: Double = 0.0
    private var coinPrice: Double?
    private var usdPrice: Double?
    var ticker: digilira.ticker?
    private var decimal: Bool = false
    
    public var address: String?
    
    private var selectedCoinX: digilira.coin?
    private var selectedIndex: Int = 0
    
    let digiliraPay = digiliraPayApi()
    
    @objc func sendMoneyButton() {
        var isMissing = false
        
        let isAmount = amount
        if isAmount == 0.0 || isAmount == 0 {
            textAmount.attributedPlaceholder = NSAttributedString(string: textAmount.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            textAmount.textColor = .red
            isMissing = true
        }
        
        if recipientText.text == "" {
            recipientText.attributedPlaceholder = NSAttributedString(string: recipientText.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            isMissing = true
        }
        
        if let coin = selectedCoinX {
            if coin.network == "" {
                adresBtn.setTitleColor(.red, for: .normal)
                isMissing = true
            }
        }
        
        if let transaction = transaction {
            if transaction.destination == digilira.transactionDestination.foreign {
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
    
    func checkAddress(network: String, address: String) -> Bool {
        var regexString = ""
        
        if transaction?.destination != digilira.transactionDestination.foreign {
            return true
        }
        
        switch network {
        case digilira.bitcoin.network:
            regexString = "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"
        case digilira.ethereum.network:
            regexString = "^0x[a-fA-F0-9]{40}$"
            break
        case digilira.waves.network:
            regexString = "^[3][a-zA-Z0-9]{34}"
            break
        default:
            regexString = "^[3][a-zA-Z0-9]{34}"
        }
        let addressTest = NSPredicate(format: "SELF MATCHES %@", regexString)
        let result = addressTest.evaluate(with: address)
        
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
        
        if params.products != nil {
            
            for (index, item) in params.products!.enumerated() {
                setCustomCell(view1: siparis, rowIndex: index, info: item.order_pname!, price: item.order_price!)
            }
        }
        
        
        if params.products == nil {
            for subView in siparis.subviews
            { subView.removeFromSuperview() }
        }
        
        if params.destination == digilira.transactionDestination.foreign {
            adresBtn.isEnabled = true
            recipientText.isEnabled = true
            textAmount.isEnabled = true
        }
        
        switch params.network! {
        case digilira.bitcoin.network:
            selectedCoinX = digilira.bitcoin
        case digilira.ethereum.network:
            selectedCoinX = digilira.ethereum
        case digilira.waves.network, "domestic":
            
            adresBtn.isEnabled = false
            recipientText.isEnabled = false
            textAmount.isEnabled = true
            
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
            
            adresBtn.setTitleColor(.black, for: .normal)
            recipientText.textColor = .black
            textAmount.textColor = .black
            
            recipientText.text = params.merchant
            coinSwitch.setTitle(price.description + " ₺", forSegmentAt: 0)
            coinSwitch.setTitle(amount.description + " " + coin.symbol, forSegmentAt: 1)
            adresBtn.setTitle(coin.tokenName, for: .normal)
            
            setPlaceHolderText()
            
            if params.destination == digilira.transactionDestination.interwallets {
                adresBtn.isEnabled = false
                recipientText.isEnabled = false
            }
            if params.destination == digilira.transactionDestination.domestic {
                adresBtn.isEnabled = false
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
    
    func setTextAmount() {
        if coinSwitch.selectedSegmentIndex == 0 { //₺
            textAmount.text = price.description
        }
        
        if coinSwitch.selectedSegmentIndex == 1 { //token
            textAmount.text = amount.description
        }
    }
    
    func setCustomCell(view1: UIView, rowIndex: Int, info: String, price: Double) {
        let height1 = CGFloat(30)
        
        let width = self.coinView.frame.width
        let label = UILabel(frame: CGRect(x: view1.frame.origin.x, y: (height1 * 2 + 10) * CGFloat(rowIndex) , width: width, height: height1))
        let priceLbl = UILabel(frame: CGRect(x: view1.frame.origin.x, y: label.frame.maxY, width: width, height: height1))
        let solidLine = UIView(frame: CGRect(x: view1.frame.origin.x, y: priceLbl.frame.maxY, width: width, height: 2))
        
        solidLine.backgroundColor = .lightGray
        
        label.textAlignment = .left
        label.text = info
        
        priceLbl.textAlignment = .left
        priceLbl.text = String(price) + " ₺"
        
        
        label.backgroundColor = .white
        //To set the font Dynamic
        label.font = UIFont(name: "Avenir", size: 20.0)
        priceLbl.font = UIFont(name: "Avenir", size: 26.0)
        
        view1.addSubview(label)
        view1.addSubview(priceLbl)
        view1.addSubview(solidLine)
        
        view1.frame.size.height = solidLine.frame.maxY
        view1.frame.size.width = width
        
    }
    
    
    func calcPrice(text: String) {
        if let coin = selectedCoinX {
            if text == "" {
                coinSwitch.setTitle("₺", forSegmentAt: 0)
                coinSwitch.setTitle(coin.symbol, forSegmentAt: 1)
                return
            }
            if coinSwitch.selectedSegmentIndex == 0 { //₺
                price = Double.init(text)!
                amount =  price / (coinPrice!)
                
                coinSwitch.setTitle(String(format: "%.2f", price) + " ₺", forSegmentAt: 0)
                coinSwitch.setTitle(String(format: "%.8f", amount) + " " + coin.symbol, forSegmentAt: 1)
                commissionLabel.text = "Transfer ücreti: " + String(format: "%.2f", (price * 0.005)) + " ₺"
            }
            
            if coinSwitch.selectedSegmentIndex == 1 { //token
                amount = Double.init(text)!
                price = (coinPrice!) * amount
                
                coinSwitch.setTitle(String(format: "%.2f", price) + " ₺", forSegmentAt: 0)
                coinSwitch.setTitle(String(format: "%.8f", amount) + " " + coin.symbol, forSegmentAt: 1)
                commissionLabel.text = "Transfer ücreti: " + String(format: "%.8f", (amount * 0.005))  + " " + coin.symbol
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        adresBtn.setTitle(pickerData[0].tokenName, for: .normal)
        //        coinTextField.text = pickerData[0].tokenName
        selectedCoinX = pickerData[0]
        setCoinPrice()
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        adresBtn.setTitle(pickerData[row].tokenName, for: .normal)
        adresBtn.setTitleColor(.black, for: .normal)
        selectedCoinX = pickerData[row]
        selectedIndex = row
        setCoinPrice()
        
        return pickerData[row].tokenName // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        adresBtn.setTitle(pickerData[row].tokenName, for: .normal)
        //        coinTextField.text = pickerData[row].tokenName
        selectedCoinX = pickerData[row]
        selectedIndex = row
        setCoinPrice()
    }
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var isPicker = false
    
    @IBAction func YOUR_BUTTON__TAP_ACTION(_ sender: UIButton) {
        
        if isPicker {
            return
        }
        dismissKeyboard()
        isPicker = true
        
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        picker.selectRow(selectedIndex, inComponent: 0, animated: true)
        
        self.addSubview(picker)
        
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Tamam", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        if let coin = selectedCoinX {
            if !checkAddress(network: coin.network, address: recipientText.text!) {
                recipientText.textColor = .red
                
            } else {
                
            }
            
            isPicker = false
            toolBar.removeFromSuperview()
            picker.removeFromSuperview()
        }
    }
    
    @IBAction func amounTap(_ sender: Any) {
        onDoneButtonTapped()
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend()
    }
    
    
    override func awakeFromNib()
    {
        coinSwitch.selectedSegmentIndex = 1
        sendView.layer.cornerRadius = 25
        pickerData = digilira.networks
        
        let tapSend: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendMoneyButton))
        sendView.isUserInteractionEnabled = true
        sendView.addGestureRecognizer(tapSend)
        
        recipientText?.addDoneCancelToolbar()
        textAmount?.addDoneCancelToolbar()
        textAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        coinSwitch.selectedSegmentIndex = 1
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getQR))
        fetchQR.isUserInteractionEnabled = true
        fetchQR.addGestureRecognizer(tap)
        
        siparis.translatesAutoresizingMaskIntoConstraints = true;
        
        
        adresBtn.layer.cornerRadius = 5
        textAmount.layer.cornerRadius = 5
        recipientText.layer.cornerRadius = 5
        recipientText.addPadding(padding: .left(10))
        textAmount.addPadding(padding: .left(10))
        adresBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    func setCoinPrice () {
        if let coin = selectedCoinX {
            let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
            if transaction?.amount != nil {
                commissionLabel.text = "Transfer ücreti: " + String(    Double   ((transaction?.amount)! * 5 / 1000)  / double)
            }
            
            switch coin.network {
            case digilira.bitcoin.network:
                coinPrice = (ticker?.btcUSDPrice)! * (ticker?.usdTLPrice)!
                break
            case digilira.ethereum.network:
                coinPrice = (ticker?.ethUSDPrice)! * (ticker?.usdTLPrice)!
                break
            case digilira.waves.network:
                switch coin.tokenName {
                case digilira.waves.tokenName:
                    coinPrice = (ticker?.wavesUSDPrice)! * (ticker?.usdTLPrice)!
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
    
    override func didMoveToSuperview() {
        if (transaction != nil) {
            setQR(params: transaction!)
        }
        //setCoinPrice()
    }
    
    @objc func getQR () {
        delegate?.readAddressQR()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        setPlaceHolderText()
    }
    
    func setPlaceHolderText() {
        
        if let coin = selectedCoinX {
            switch coinSwitch.selectedSegmentIndex
            {
            case 0:
                
                if price == 0.0 {
                    textAmount.placeholder = "Miktar (₺)"
                } else {
                    textAmount.text = String(format: "%.2f", price)
                }
            case 1:
                if amount == 0.0 {
                    textAmount.placeholder = "Miktar (" + coin.symbol + ")"
                }else {
                    textAmount.text = String(format: "%.8f", amount)
                }
            default:
                break;
            }
            coinSwitch.setTitle(String(format: "%.2f", price) + " ₺", forSegmentAt: 0)
            coinSwitch.setTitle(String(format: "%.8f", amount) + " " + coin.symbol, forSegmentAt: 1)
        }
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



//
//  newSendView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 18.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit


class newSendView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedCountry: String?
    
    weak var delegate: NewCoinSendDelegate?
    
    var pickerData: [digilira.coin] = [digilira.coin]()
    let thePicker = UIPickerView()

    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var coinLbl: UILabel!
    @IBOutlet weak var coinTextField: UITextField!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var coinSwitch: UISegmentedControl!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var fetchQR: UIImageView!
    @IBOutlet weak var recipientText: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var transaction: SendTrx?
    private var amount: Double?
    private var price: Double?
    private var coinPrice: Double?
    private var usdPrice: Double?
    var ticker: digilira.ticker?
    private var decimal: Bool = false

    public var address: String?
     
    private var selectedCoinX: digilira.coin = digilira.coin.init(token: "", symbol: "", tokenName: "", network: "")
    
    let digiliraPay = digiliraPayApi()

    @IBAction func sendMoneyButton(_ sender: Any) {
        let isAmount = Double(textAmount.text!)
        if isAmount == 0.0 { return }
        if coinTextField.text == "" {return}
        if recipientText.text == "" {return}
        
        transaction?.amount = Int64(isAmount! * 100000000)
        delegate?.sendCoinNew(params: transaction!)
    }
  
    @objc func textFieldDidChange(_ textField: UITextField) {
        
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
        guard Float.init(textField.text!) != nil else {
            textField.text = ""
            coinSwitch.setTitle("₺", forSegmentAt: 0)
            coinSwitch.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return
            
        }

        if textField.text == "" {
            coinSwitch.setTitle("₺", forSegmentAt: 0)
            coinSwitch.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return}
         
        calcPrice(text: textField.text!)
 
    }
    
    func calcPrice(text: String) {
        if text == "" {
            coinSwitch.setTitle("₺", forSegmentAt: 0)
            coinSwitch.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return
        }
        if coinSwitch.selectedSegmentIndex == 0 { //₺
            amount = Double.init(text)!
            price =  amount! / (coinPrice!)
 
            coinSwitch.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            coinSwitch.setTitle(String(format: "%.8f", price!) + " " + selectedCoinX.symbol, forSegmentAt: 1)
            commissionLabel.text = "Transfer ücreti: " + String(format: "%.2f", (amount! * 0.005)) + " ₺"
        }
        
        if coinSwitch.selectedSegmentIndex == 1 { //token
            price = Double.init(text)!
            amount = (coinPrice!) * price!
            coinSwitch.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            coinSwitch.setTitle(String(format: "%.8f", price!) + " " + selectedCoinX.symbol, forSegmentAt: 1)
            commissionLabel.text = "Transfer ücreti: " + String(format: "%.8f", (price! * 0.005))  + " " + selectedCoinX.symbol
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        coinTextField.text = pickerData[0].tokenName
        selectedCoinX = pickerData[0]
        setCoinPrice()
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].tokenName // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        coinTextField.text = pickerData[row].tokenName
        selectedCoinX = pickerData[row]
        setCoinPrice()
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend()
    }
    

    override func awakeFromNib()
    {
        pickerData = digilira.networks
        
        createPickerView()
        dismissPickerView()
        recipientText?.addDoneCancelToolbar()
        textAmount?.addDoneCancelToolbar()
        textAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        btnSend.layer.cornerRadius = 20
        coinSwitch.selectedSegmentIndex = 1
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getQR))
        fetchQR.isUserInteractionEnabled = true
        fetchQR.addGestureRecognizer(tap)
        ticker = digiliraPay.ticker()
    }
    
    func setCoinPrice () {
        if transaction?.amount != nil {
            commissionLabel.text = "Transfer ücreti: " + String(    Double   ((transaction?.amount)! * 5 / 1000)  / 100000000   )
        }
        
        switch selectedCoinX.network {
        case "bitcoin":
            coinPrice = (ticker?.btcUSDPrice)! * (ticker?.usdTLPrice)!
            break
        case "ethereum":
            coinPrice = (ticker?.ethUSDPrice)! * (ticker?.usdTLPrice)!
            break
        case "waves":
            switch selectedCoinX.tokenName {
            case "Waves":
                coinPrice = (ticker?.wavesUSDPrice)! * (ticker?.usdTLPrice)!
                break
            case "Kızılay":
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
    
    override func didMoveToSuperview() {
        setCoinPrice()
    }
    
    @objc func getQR () {
        delegate?.readAddressQR()
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        coinTextField.inputView = pickerView
    }
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(action1))

        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        coinTextField.inputAccessoryView = toolBar
    }
    
    @objc func action1() {
          self.endEditing(true)
    }
 
}
 
 

extension UIView {
    
}

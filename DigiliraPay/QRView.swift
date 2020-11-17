//
//  QRView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 3.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Photos

class QRView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var adressInfoLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
     @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var switchCurrency: UISegmentedControl!
    @IBOutlet weak var copyIcon: UIImageView!
    @IBOutlet weak var copyAddress: UIView!
    @IBOutlet weak var adresBtn: UIButton!
    

    weak var delegate: LoadCoinDelegate?
    let pasteboard = UIPasteboard.general
    public var address: String?

    private var amount: Double?
    private var price: Double?
    private var assetId: String = ""
    private var selectedCoin: String?
    private var coinPrice: Double?
    private var usdPrice: Double?
    
    let thePicker = UIPickerView()
    private var decimal: Bool = false
    var pickerData: [digilira.coin] = [digilira.coin]()

    let digiliraPay = digiliraPayApi()
    var ticker: digilira.ticker?
    var kullanici: digilira.user?
 
    
    public var selectedCoinX: digilira.coin = digilira.coin.init(token: "", symbol: "", tokenName: "", network: "")

    override func awakeFromNib()
    {
        
        shareButtonView.clipsToBounds = true
        shareButtonView.layer.cornerRadius = 6
        textAmount?.addDoneCancelToolbar()
        
        textAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        copyAddress.layer.cornerRadius = 5
        copyAddress.layer.shadowColor = UIColor.black.cgColor
        copyAddress.layer.shadowOpacity = 0.2
        copyAddress.layer.shadowOffset = .zero
        copyAddress.layer.shadowRadius = 1
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipboard))
        copyAddress.isUserInteractionEnabled = true
        copyAddress.addGestureRecognizer(tap)
        
        pickerData = digilira.networks
         
        textAmount.isEnabled = false
        switchCurrency.isEnabled = false

        shareButtonView.isHidden = true
        copyIcon.isHidden = true
 

        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                delegate?.dismissLoadView()
            default:
                break
            }
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        switchCurrency.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
    }
    
    @objc func copyToClipboard() {
        if address == nil {return}
        copyIcon.image = UIImage(named: "checkImg")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.copyIcon.image = UIImage(named: "copyImg")

        }
        pasteboard.string = address
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        adresBtn.setTitle(pickerData[0].tokenName, for: .normal)
        selectedCoinX = pickerData[0]
        setCoinPrice()
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedCoinX = pickerData[row]
        setAdress()
        return pickerData[row].tokenName // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        adresBtn.setTitle(pickerData[row].tokenName, for: .normal)
        selectedCoinX = pickerData[row]
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
        self.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Tamam", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped() {
        isPicker = false
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    @IBAction func amounTap(_ sender: Any) {
        onDoneButtonTapped()
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    
    func setAdress()  {
        
        
        switch selectedCoinX.network {
        case digilira.bitcoin.network:
            coinPrice = (ticker?.btcUSDPrice)! * (ticker?.usdTLPrice)!
            address = kullanici?.btcAddress
            break
        case digilira.ethereum.network:
            coinPrice = (ticker?.ethUSDPrice)! * (ticker?.usdTLPrice)!
            address = kullanici?.ethAddress
            break
        case digilira.waves.network:
            switch selectedCoinX.tokenName {
            case digilira.waves.tokenName:
                coinPrice = (ticker?.wavesUSDPrice)! * (ticker?.usdTLPrice)!
                address = kullanici?.wallet
                assetId = digilira.waves.token
                break
            case digilira.charity.tokenName:
                address = kullanici?.wallet
                assetId = digilira.charity.token
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
        
        
        
    }
    func setCoinPrice () {

        setAdress()
        
        if textAmount.text == nil {
            textAmount.text = "0"
        }
        
        let image = generateQRCode(from: selectedCoinX.network, network: selectedCoinX.network, address: address!, amount: textAmount.text!, assetId: assetId)
        qrImage.image = image
        textAmount.text = ""
        setPlaceHolderText()
//        adresTextView.text = address
        adresBtn.setTitle(address, for: .normal)
        switchCurrency.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
        switchCurrency.setTitle("₺", forSegmentAt: 0)
        textAmount.isEnabled = true
        switchCurrency.isEnabled = true
        adressInfoLabel.text = selectedCoinX.tokenName + " Yatır"
        shareButtonView.isHidden = false
        copyIcon.isHidden = false
        
        calcPrice(text: textAmount.text!)
    }
    
    
    func calcPrice(text: String) {
        if text == "" {
            switchCurrency.setTitle("₺", forSegmentAt: 0)
            switchCurrency.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return
        }
        if switchCurrency.selectedSegmentIndex == 0 { //₺
            amount = Double.init(text)!
            price =  amount! / (coinPrice!)
 
            switchCurrency.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(format: "%.8f", price!) + " " + selectedCoinX.symbol, forSegmentAt: 1)
        }
        
        if switchCurrency.selectedSegmentIndex == 1 { //token
            price = Double.init(text)!
            amount = (coinPrice!) * price!
            switchCurrency.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(format: "%.8f", price!) + " " + selectedCoinX.symbol, forSegmentAt: 1)
        }
        
        let image = generateQRCode(from: selectedCoinX.network, network: selectedCoinX.network, address: address!, amount: String(price!), assetId: assetId)
        qrImage.image = image
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
            switchCurrency.setTitle("₺", forSegmentAt: 0)
            switchCurrency.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return
            
        }

        if textField.text == "" {
            switchCurrency.setTitle("₺", forSegmentAt: 0)
            switchCurrency.setTitle(selectedCoinX.symbol, forSegmentAt: 1)
            return}
        
        usdPrice = ticker?.usdTLPrice
        
 
        calcPrice(text: textField.text!)
  
        
        
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        setPlaceHolderText()
    }
    
    func setPlaceHolderText() {
        let isAmount = textAmount.text
        switch switchCurrency.selectedSegmentIndex
        {
        case 0:
            if isAmount == "" {
                textAmount.placeholder = "Miktar (₺)"
            } else {
                textAmount.text = String(format: "%.2f", amount!)
            }
        case 1:
            if isAmount == "" {
                textAmount.placeholder = "Miktar (" + selectedCoinX.symbol + ")"
            }else {
                textAmount.text = String(format: "%.8f", price!)
            }
        default:
            break;
        }
    }
    override func didMoveToSuperview() {
        
        //adressLabel.text = address
        if selectedCoinX.network == "" {return}
        let image = generateQRCode(from: selectedCoinX.network, network: selectedCoinX.network, address: address!, amount: textAmount.text!, assetId: assetId)
        qrImage.image = image
    }

    @IBAction func shareButton(_ sender: Any)
    {
        shareButtonView.isHidden = true
        let buffer = textAmount.text
        if textAmount.text == "" {
            switchCurrency.isHidden = true
        }
        copyIcon.isHidden = true
        textAmount.text = (kullanici?.firstName)! + " " + (kullanici?.lastName)!
        textAmount.isEnabled = false

        delegate?.shareQR(image: takeScreenshot())
        textAmount.text = buffer
        textAmount.isHidden = false
        textAmount.isEnabled = true
        copyIcon.isHidden = false

        switchCurrency.isHidden = false
        shareButtonView.isHidden = false
    }
 

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("ok")
    }

    
    func generateQRCode(from string: String, network: String, address: String, amount: String, assetId: String) -> UIImage? {
        var miktar = amount
        if miktar == "" {
            miktar = "0.0"
        }
        let doubleStop = ":".data(using: String.Encoding.ascii)
        let amountPrefix = "?amount=".data(using: String.Encoding.ascii)
        let assetIdPrefix = "&assetId=".data(using: String.Encoding.ascii)
        var data = string.data(using: String.Encoding.ascii)! + doubleStop! + address.data(using: String.Encoding.ascii)! + amountPrefix! + miktar.data(using: String.Encoding.ascii)!

        if network == "waves" {
            let assetIdData = assetId.data(using: String.Encoding.ascii)
            data = data + assetIdPrefix! + assetIdData!
        }
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}

extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}


extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Tamam", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension Data {

    /// Data into file
    ///
    /// - Parameters:
    ///   - fileName: the Name of the file you want to write
    /// - Returns: Returns the URL where the new file is located in NSURL
    func dataToFile(fileName: String) -> NSURL? {

        // Make a constant from the data
        let data = self

        // Make the file path (with the filename) where the file will be loacated after it is created
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            // Write the file from data into the filepath (if there will be an error, the code jumps to the catch block below)
            try data.write(to: URL(fileURLWithPath: filePath))

            // Returns the URL where the new file is located in NSURL
            return NSURL(fileURLWithPath: filePath)

        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }

        // Returns nil if there was an error in the do-catch -block
        return nil

    }
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    

}

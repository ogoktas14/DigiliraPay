//
//  QRView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 3.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Photos

class QRView: UIView {

    @IBOutlet weak var adressInfoLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var switchCurrency: UISegmentedControl!
    @IBOutlet weak var copyIcon: UIImageView!
    @IBOutlet weak var copyAddress: UIView!
    
    weak var delegate: LoadCoinDelegate?
    let pasteboard = UIPasteboard.general
    public var address: String?
    public var network: String?
    public var tokenName: String?

    private var amount: Double?
    private var price: Double?
    
    private var coinPrice: Double?
    private var usdPrice: Double?
    
    public var adSoyad: String?
    
    private var decimal: Bool = false

    let digiliraPay = digiliraPayApi()
    var ticker: digilira.ticker?

    override func awakeFromNib()
    {
        
        shareButtonView.clipsToBounds = true
        shareButtonView.layer.cornerRadius = 6
        textAmount?.addDoneCancelToolbar()
        
        textAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        ticker = digiliraPay.ticker()
        
        copyAddress.layer.cornerRadius = 5
        copyAddress.layer.shadowColor = UIColor.black.cgColor
        copyAddress.layer.shadowOpacity = 0.2
        copyAddress.layer.shadowOffset = .zero
        copyAddress.layer.shadowRadius = 1
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipboard))
        copyAddress.isUserInteractionEnabled = true
        copyAddress.addGestureRecognizer(tap)
        



        
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
    
    override func didMoveToWindow() {
        switchCurrency.setTitle(tokenName, forSegmentAt: 1)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
    }
    
    @objc func copyToClipboard() {
        adressInfoLabel.fadeTransition(0.4)
        adressInfoLabel.text = "ADRES KOPYALANDI"
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.adressInfoLabel.text = "ADRES"

        }
        pasteboard.string = address
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
            switchCurrency.setTitle(tokenName!, forSegmentAt: 1)
            return
            
        }

        if textField.text == "" {
            switchCurrency.setTitle("₺", forSegmentAt: 0)
            switchCurrency.setTitle(tokenName!, forSegmentAt: 1)
            return}
        
        usdPrice = ticker?.usdTLPrice
        
        switch tokenName {
        case "BTC":
            coinPrice = ticker?.btcUSDPrice
        case "ETH":
            coinPrice = ticker?.ethUSDPrice
        case "WAVES":
            coinPrice = ticker?.wavesUSDPrice
        default:
            return
        }
        
        if switchCurrency.selectedSegmentIndex == 0 { //₺
            amount = Double.init(textField.text!)!
            price =  amount! / (usdPrice! * coinPrice!)
            let image = generateQRCode(from: network! + ":" + address! + "?amount=" + String(price!))
            qrImage.image = image

            
            switchCurrency.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(format: "%.8f", price!) + " " + tokenName!, forSegmentAt: 1)
        }
        
        if switchCurrency.selectedSegmentIndex == 1 { //token
            price = Double.init(textField.text!)!
            amount = (usdPrice! * coinPrice!) * price!
            switchCurrency.setTitle(String(format: "%.2f", amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(format: "%.8f", price!) + " " + tokenName!, forSegmentAt: 1)
            let image = generateQRCode(from: network! + ":" + address! + "?amount=" + String(price!))
            qrImage.image = image


        }
        
        
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
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
                textAmount.placeholder = " Miktar (" + tokenName! + ")"
            }else {
                textAmount.text = String(format: "%.8f", price!)
            }
        default:
            break;
        }
    }
    
    override func didMoveToSuperview() {
        
        adressLabel.text = address
        if network == nil {return}
        let image = generateQRCode(from: network! + ":" + address!)
        qrImage.image = image
    }

    @IBAction func shareButton(_ sender: Any)
    {
        shareButtonView.isHidden = true
        adressInfoLabel.text = adSoyad!
        if textAmount.text == "" {
            textAmount.isHidden = true
            switchCurrency.isHidden = true
        }
        delegate?.shareQR(image: takeScreenshot())
        adressInfoLabel.text = "ADRES"
        textAmount.isHidden = false
        switchCurrency.isHidden = false
        shareButtonView.isHidden = false
    }
 

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("ok")
    }
    

    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

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

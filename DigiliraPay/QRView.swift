//
//  QRView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 3.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

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

    private var amount: Float?
    private var price: Float?
    
    private var coinPrice: Float?
    private var usdPrice: Float?

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
    
    override func didMoveToWindow() {
        switchCurrency.setTitle(tokenName, forSegmentAt: 1)
    }
    
    @objc func copyToClipboard() {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        let alert = UIAlertController(title: "Adres Kopyalandı",message: tokenName! + " adresiniz kopyalandı...",
                                      preferredStyle: UIAlertController.Style.alert)
        window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
        pasteboard.string = address
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let image = generateQRCode(from: network! + ":" + address! + "?amount=" + textField.text!)
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
            amount = Float.init(textField.text!)!
            price =  amount! / (usdPrice! * coinPrice!)
            
            switchCurrency.setTitle(String(amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(price!) + " " + tokenName!, forSegmentAt: 1)
        }
        
        if switchCurrency.selectedSegmentIndex == 1 { //token
            price = Float.init(textField.text!)!
            amount = (usdPrice! * coinPrice!) * price!
            switchCurrency.setTitle(String(amount!) + " ₺", forSegmentAt: 0)
            switchCurrency.setTitle(String(price!) + " " + tokenName!, forSegmentAt: 1)
        }
        
        
        
        qrImage.image = image
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        let isAmount = textAmount.text
        switch switchCurrency.selectedSegmentIndex
        {
        case 0:
            if isAmount == "" {
                textAmount.placeholder = "₺ Miktarı Giriniz.."
            } else {
                textAmount.text = String(amount!)
            }
        case 1:
            if isAmount == "" {
                textAmount.placeholder = tokenName! + " Miktarı Giriniz.."
            }else {
                textAmount.text = String(price!)
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
        // image to share
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        let activityViewController = UIActivityViewController(activityItems: [generateQRCode(from: network! + ":" + address!)] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self
        
        window?.rootViewController?.presentedViewController?.present(activityViewController, animated: true, completion: nil)

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

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

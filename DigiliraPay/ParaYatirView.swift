//
//  ParaYatirView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 7.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ParaYatirView:UIView {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var content: UIView!
    
    @IBOutlet weak var imgCopy: UIImageView!
    @IBOutlet weak var imgSave: UIImageView!
    @IBOutlet weak var imgShare: UIImageView!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var copyView: UIView!
    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l5: UILabel! 
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    @IBOutlet weak var v4: UIView!
    @IBOutlet weak var v5: UIView!

    var ccView = CreditCardView()
    let generator = UINotificationFeedbackGenerator()
    
    weak var delegate: LoadCoinDelegate?
    weak var errors: ErrorsDelegate?
    
    var Filtered: [WavesListedToken] = []
    let BC = Blockchain()
    
    private var selectedCoinX: WavesListedToken?
    
    var direction: UISwipeGestureRecognizer.Direction?
    private var decimal: Bool = false
    var shoppingCart: [digilira.shoppingCart] = []
    let pasteboard = UIPasteboard.general
    
    var Ticker: binance.BinanceMarketInfo = []
    let binanceAPI = binance()
    var ticker: digilira.ticker?
    
    var currentPage: Int = 0
    
    private var amount: Double = 0.0
    private var price: Double = 0.0
    
    var address1: String?
    var assetId: String?
    
    var kullanici: digilira.auth?
    
    var datas:[digilira.DepositLine] = []
    
    func constants (coin: String, symbol: String, min: String, mode: Int){
        v1.isHidden = true
        v2.isHidden = true
        v3.isHidden = true
        v4.isHidden = true
        v5.isHidden = true
        
        var array:[String] = []
        switch mode {
        case 0:
             array = [
                "Herhangi bir yatırma limiti bulunmamaktadır.",
                "Bu adrese dilediğiniz kadar " + coin + " gönderebilirsiniz."
            ]
        case 1:
             array = [
                "One Tower AVM resmi sadakat jetonudur.",
                "One Tower AVM içerisinde yer alan standlarda One Tower jetonlarınız ile alışveriş yapabilirsiniz.",
                "One Tower jetonları başka DigiliraPay kullanıcıları arasında ücretsiz olarak transfer edebilir, birleştirerek harcanabilir.",
                "One Tower jetonlarının nakdi bir karşılığı bulunmamaktadır. AVM'nin kendisi tarafından belirlenen promosyon ürünler, yine AVM tarafından belirlenen jeton bedelleri ile satın alınabilmektedir.",
                "One Tower jetonları hakkında bilgiye onetoweravm.com.tr adresinden ulaşabilirsiniz."
            ]
        default:
             array = [
                "Bu adrese sadece " + coin + " gönderin. Bu adrese " + coin + " dışında yapılan gönderimler kayıplara neden olur.",
                "Minimum yatırım tutarı " + min + " " + symbol + "'dir. Bu tutarın altındaki yatırma işlemleri iade edilmeyecektir.",
                "Gönderdiğiniz turar blokzincirde onaylandıktan sonra DigiliraPAY hesabınıza aktarılacaktır.",
                "Cüzdan adresinizi kopyalamak için adrese basabilirsiniz. Kopyaladığınız adres ile yapıştırdığınız adresi mutlaka kontrol edin.",
                "Ödeme almak için QR kodunuzu paylaşabilirsiniz."
            ]
        }
        for (i, c) in array.enumerated() {
            switch i {
            case 0:
                l1.text = c
                v1.isHidden = false
            case 1:
                l2.text = c
                v2.isHidden = false
            case 2:
                l3.text = c
                v3.isHidden = false
            case 3:
                l4.text = c
                v4.isHidden = false
            case 4:
                l5.text = c
                v5.isHidden = false
            default:
                break
            }
            
        }

        
    }
    
    override func awakeFromNib() {
        
        setShad(view: scrollAreaView, cornerRad: 10, mask: true)
        setShad(view: content, mask: false)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyToClipboard))
        imgCopy.isUserInteractionEnabled = true
        imgCopy.addGestureRecognizer(tap)
        
        let share: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shareButton))
        imgShare.isUserInteractionEnabled = true
        imgShare.addGestureRecognizer(share)
        
        let save: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveButton))
        imgSave.isUserInteractionEnabled = true
        imgSave.addGestureRecognizer(save)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        scrollAreaView.addGestureRecognizer(leftSwipe)
        scrollAreaView.addGestureRecognizer(rightSwipe)
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = false
        
        do {
            let user = try secretKeys.userData()
            kullanici = user
        } catch {
            print (error)
        }
        
        shareView.layer.cornerRadius = 25
        copyView.layer.cornerRadius = 25
        saveView.layer.cornerRadius = 25
        
        
        if let user = kullanici {
            if user.status == 0 {
                DispatchQueue.main.async { [self] in
                    self.errors?.errorHandler(message: "Hesabınıza para yükleyebilmek için profil onayı sürecini tamamlamanız gerekmektedir.", title: "Profil Onayı", error: true)
                }
            }
        }
    }
    
    @objc func copyToClipboard() {
        generator.notificationOccurred(.success)
        UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.copyView.alpha = 0
            self.copyView.isUserInteractionEnabled = false
        }, completion: { [self]_ in
            if address1 == nil {return}
            imgCopy.image = UIImage(named: "success")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.imgCopy.image = UIImage(named: "copyImg")
                
            }
            pasteboard.string = address1
            
            self.copyView.alpha = 1
            self.copyView.isUserInteractionEnabled = true
        })
    }
    
    @objc func shareButton()
    {
        generator.notificationOccurred(.success)
        UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.shareView.alpha = 0.4
            self.shareView.isUserInteractionEnabled = false
        }, completion: { [self]_ in
            
            do {
                let user = try secretKeys.userData()
                
                if user.firstName != nil {
                    if user.lastName != nil {
                        popup(image: takeScreenshot())
                    }
                } else {
                    errors?.evaluate(error: digilira.NAError.emptyAuth)
                    
                }
            } catch {
                errors?.evaluate(error: digilira.NAError.emptyAuth)
            }
            self.shareView.alpha = 1
            self.shareView.isUserInteractionEnabled = true
        })
        
    }
    
    @objc func saveButton()
    {
        
        PHPhotoLibrary.requestAuthorization { [self] status in
            if status == .authorized {
                generator.notificationOccurred(.success)
                DispatchQueue.main.async {
                    UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
                        self.saveView.alpha = 0.4
                        self.saveView.isUserInteractionEnabled = false
                    }, completion: { [self]_ in
                        
                        UIImageWriteToSavedPhotosAlbum(takeScreenshot(), self, #selector(saveError), nil)
                    })
                }
                
            }
            
        }
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            errors?.errorHandler(message: "Ayarlar menüsünden Galeri'ye erişim izni vermeniz gerekmektedir.", title: "Dikkat", error: true)
            break
        default:
            break
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        errors?.errorHandler(message: "QR Kodunuz galeriye kaydedildi", title: "Başarılı", error: false)
        imgSave.alpha = 1
        
        self.saveView.alpha = 1
        self.saveView.isUserInteractionEnabled = true
    }
    
    func popup (image: UIImage?) {
        //do things
        if let image = image {
            
            DispatchQueue.main.async {
                if let pngImageData = image.pngData() {
                    // Write the png image into a filepath and return the filepath in NSURL
                    if let pngImageURL = pngImageData.dataToFile(fileName:  UUID().uuidString + ".png") {
                        
                        // Create the Array which includes the files you want to share
                        var filesToShare = [Any]()
                        
                        // Add the path of png image to the Array
                        filesToShare.append(pngImageURL)
                        
                        let activityViewController = UIActivityViewController(activityItems:filesToShare, applicationActivities: nil)
                        if #available(iOS 13.0, *) {
                            activityViewController.isModalInPresentation = true
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.saveToCameraRoll ]
                        self.window?.rootViewController?.presentedViewController?.present(activityViewController, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    private func setShad(view: UIView, cornerRad: CGFloat = 0, mask: Bool = false) {
        view.layer.shadowOpacity = 0.2
        view.layer.cornerRadius = cornerRad
        view.layer.masksToBounds = mask
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1, height: 1)
        
    }
    
    @objc func letsGO()
    {
        delegate?.dismissLoadView()
    }
    
    @IBAction func btnExit(_ sender: Any) {
        delegate?.dismissLoadView()
    }
    
    @IBAction func changePage(_ sender: UIPageControl) {
        print(currentPage)
        currentPage = sender.currentPage
        setBalanceView(index: sender.currentPage)
        
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
    
    
    func setCoin() throws -> String? {
        let coin = Filtered[currentPage]
        
        switch coin.network {
        case digilira.bitcoinNetwork:
            let address = kullanici?.btcAddress
            constants(coin: "Bitcoin", symbol: "BTC", min: "0.001", mode: -1)
            return address
        case digilira.ethereumNetwork: 
            switch coin.tokenName {
            case "Tether USDT":
                constants(coin: "ERC-20 USDT Tether", symbol: "USDT", min: "10", mode: -1)

                let address = kullanici?.tetherAddress
                return address
            default:
                let address = kullanici?.ethAddress
                constants(coin: "Ethereum", symbol: "ETH", min: "0.01", mode: -1)

                return address
            }
        case digilira.wavesNetwork:
            
            switch coin.tokenName {
            case "One Tower":
                constants(coin: "One Tower", symbol: "", min: "", mode: 1)
            default:
                constants(coin: "Waves", symbol: "", min: "", mode: 0)
            }
            
            let address = kullanici?.wallet
            return address
        default:
            let address = kullanici?.wallet
            return address
        }
        
    }
    
    func setCoinCard(scrollViewSize: UIView, layer: CGFloat, coin:WavesListedToken) throws -> UIView {
        ccView = UIView().loadNib(name: "CreditCardView") as! CreditCardView
        let ad = "Satoshi"
        let soyad = "Nakamoto"
        do {
            let address = try setCoin()
             
            if let kullanici = kullanici {
                let name = kullanici.firstName ?? ad
                let surname =  kullanici.lastName ?? soyad
                let isim = name + " " + surname
                if let adres = address {
                    if let a = generateQRCode(from: coin.network, network: coin.network, address: adres, amount: "0", assetId: coin.token) {
                        ccView.setView(tokenName: coin.tokenName, wallet: address!, qr: a, ad:isim)
                    }
                }
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
        
        ccView.frame = CGRect(x: orgX,
                              y: 0,
                              width: scrollViewSize.frame.width,
                              height: scrollViewSize.frame.height)
        
        
        
        UIView.animate(withDuration: 0.5)
        {
            self.ccView.frame.origin.x = 0
            self.ccView.alpha = 1
        }
        
        return ccView
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
        shoppingCart = []
    }
    
    
    
    func generateQRCode(from string: String, network: String, address: String, amount: String, assetId: String) -> UIImage? {
        var miktar = amount
        if miktar == "" {
            miktar = "0.0"
        }
        let doubleStop = ":".data(using: String.Encoding.ascii)
        let amountPrefix = "?amount=".data(using: String.Encoding.ascii)
        let assetIdPrefix = "&assetId=".data(using: String.Encoding.ascii)
        var data = string.data(using: String.Encoding.ascii)! + doubleStop! + address.data(using: String.Encoding.ascii)!
        
        self.address1 = address
        
        if network == "waves" {
            let assetIdData = assetId.data(using: String.Encoding.ascii)
            data = data + amountPrefix! + miktar.data(using: String.Encoding.ascii)! + assetIdPrefix! + assetIdData!
            if assetId != "WAVES" {
                self.address1 = address + "?amount=0&assetId=" + assetId
            }
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

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
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

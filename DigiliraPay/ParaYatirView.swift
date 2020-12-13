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
    @IBOutlet weak var totalAmount: UIView!
    @IBOutlet weak var totalAmountText: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchCurrency: UISegmentedControl!
    @IBOutlet weak var imgCopy: UIImageView!
    @IBOutlet weak var imgSave: UIImageView!
    @IBOutlet weak var imgShare: UIImageView!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var copyView: UIView!


    var ccView = CreditCardView()
    let generator = UINotificationFeedbackGenerator()
    
    weak var delegate: LoadCoinDelegate?
    weak var errors: ErrorsDelegate?

    var Filtered: [digilira.DigiliraPayBalance] = []
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    
    private var selectedCoinX: digilira.coin?

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
        
        
        
    }
    
    @objc func copyToClipboard() {
        
        generator.notificationOccurred(.success)
        UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.copyView.alpha = 0
            self.copyView.isUserInteractionEnabled = false
        }, completion: { [self]_ in
            if address1 == nil {return}
            imgCopy.image = UIImage(named: "checkImg")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.imgCopy.image = UIImage(named: "copyImg")

            }
            pasteboard.string = address1
            
            errors?.errorHandler(message: "Cüzdan adresiniz kopyalandı: " + address1!, title: "Başarılı", error: false)
            
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
                    errors?.errorHandler(message: "İsim bilgisi okunamadı, lütfen yeniden giriş yapın.", title: "Bir Hata Oluştu", error: true)
                }
            } catch {
                errors?.errorHandler(message: "Kullanıcı bilgileri okunamadı, lütfen yeniden giriş yapın.", title: "Bir Hata Oluştu", error: true)
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
        
        let coin = Filtered[currentPage]

            if let d = Double(replaced) {
                switchCurrency.setTitle("₺", forSegmentAt: 0)
                switchCurrency.setTitle(coin.tokenSymbol, forSegmentAt: 1)
                calcPrice(amo: d, coin: coin)
            }

    }
    
    func calcPrice(amo: Double, coin: digilira.DigiliraPayBalance) {
        _ = digiliraPay.ticker(ticker: Ticker)

        do {
            
            if amo == 0.0 {
                switchCurrency.setTitle("₺", forSegmentAt: 0)
                switchCurrency.setTitle(coin.tokenSymbol, forSegmentAt: 1)
                return
            }
            if switchCurrency.selectedSegmentIndex == 0 { //₺
                price = amo
                amount = amo / coin.tlExchange
                totalAmountLabel.text = "MİKTAR GİRİNİZ [ ₺ ]"
                switchCurrency.setTitle(String(format: "%.2f", price) + " ₺", forSegmentAt: 0)
                switchCurrency.setTitle(String(format: "%.8f", amount) + " " + coin.tokenSymbol, forSegmentAt: 1)
            }
            
            if switchCurrency.selectedSegmentIndex == 1 { //token
                price = coin.tlExchange * amo
                amount = amo
                totalAmountLabel.text = "MİKTAR GİRİNİZ [ " + coin.tokenSymbol + " ]"
                switchCurrency.setTitle(String(format: "%.2f", price) + " ₺", forSegmentAt: 0)
                switchCurrency.setTitle(String(format: "%.8f", amount) + " " + coin.tokenSymbol, forSegmentAt: 1)
            }
            
        } catch {
            print(error)
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
    func setPlaceHolderText() {
        let isAmount = totalAmountText.text
        
        let coin = Filtered[currentPage]
        switch switchCurrency.selectedSegmentIndex
        {
        case 0:
            if isAmount == "" {
                totalAmountLabel.text = "MİKTAR GİRİNİZ [ ₺ ]"
            } else {
                totalAmountText.text = String(format: "%.2f", amount)
            }
        case 1:
            if isAmount == "" {
                totalAmountLabel.text = "MİKTAR GİRİNİZ [ " + coin.tokenSymbol + " ]"
            }else {
                totalAmountText.text = String(format: "%." + coin.decimal.description + "f" , price)
            }
        default:
            break;
        }
        
    }
    @IBAction func indexChanged(sender: UISegmentedControl) {
        setPlaceHolderText()
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
        setAdress()
    }
    
    func setAdress()  {
        do {
            let user = try secretKeys.userData()
            let coin = Filtered[currentPage].tokenName
            switch coin {
            case digilira.bitcoin.tokenName:
                address1 = user.btcAddress
                break
            case digilira.ethereum.tokenName:
                address1 = user.ethAddress
                break
            case digilira.waves.tokenName:
                address1 = user.wallet
                assetId = digilira.waves.token
                break
            case digilira.charity.tokenName:
                address1 = user.wallet
                assetId = digilira.charity.token
            break
            case "digilira":
                break
            default:
                break
            }
        } catch {
            
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
    
    
    func setCoin() throws -> (digilira.coin, String?, String) {
        let coin = Filtered[currentPage]
        
        switch coin.network {
        case "waves":
            
            switch coin.tokenName {
            case digilira.bitcoin.tokenName:
                let address = kullanici?.btcAddress
                return (digilira.bitcoin, address, "NA")
            case digilira.ethereum.tokenName:
                let address = kullanici?.ethAddress
                return (digilira.ethereum, address, "NA")
            case digilira.waves.tokenName:
                let address = kullanici?.wallet
                return (digilira.waves, address, digilira.charity.token)
            case digilira.charity.tokenName:
                let address = kullanici?.wallet
                return (digilira.charity, address, digilira.charity.token)
            default:
                throw digilira.NAError.notListedToken
            }
        case "bitexen":
            let c = digilira.coin.init(token: coin.tokenName, symbol: coin.tokenSymbol, tokenName: coin.tokenName, decimal: coin.decimal, network: coin.network, tokenSymbol: coin.tokenSymbol)
            return (c, coin.tokenSymbol, coin.tokenName)
        default:
            throw digilira.NAError.notListedToken
        }
    }
    
    func setCoinCard(scrollViewSize: UIView, layer: CGFloat, coin:digilira.DigiliraPayBalance) throws -> UIView {
        ccView = UIView().loadNib(name: "CreditCardView") as! CreditCardView
        
        do {
            let (coin, address, asset) = try setCoin()
            self.address1 = address
            if let kullanici = kullanici {
                let name = kullanici.firstName! + " " + kullanici.lastName!
                switch coin.network {
                case "bitexen":
                    ccView.setView(tokenName: coin.tokenName, wallet: address!, qr: UIImage.init(), ad:name)
                    break
                case "waves", "ethereum", "bitcoin":
                    if let a = generateQRCode(from: coin.network, network: coin.network, address: address!, amount: "0", assetId: asset) {
                        ccView.setView(tokenName: coin.tokenName, wallet: address!, qr: a, ad:name)
                    }
                default:
                    break
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
        print(Filtered)
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
    
    override func didMoveToWindow() {
            
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

        if network == "waves" {
            let assetIdData = assetId.data(using: String.Encoding.ascii)
            data = data + amountPrefix! + miktar.data(using: String.Encoding.ascii)! + assetIdPrefix! + assetIdData!
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

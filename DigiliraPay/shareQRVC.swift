//
//  shareQRVC.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 17.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit
import Photos



class ShareQRVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    var loadMoneyView = QRView()
    let pasteboard = UIPasteboard.general
    public var address: String?
    public var network: String?
    public var tokenName: String?
    public var adSoyad: String?

    private var amount: Double?
    private var price: Double?
    
    private var coinPrice: Double?
    private var usdPrice: Double?

    let digiliraPay = digiliraPayApi()
    var ticker: digilira.ticker?
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        shareQRScreen()
    }
    
    func shareQRScreen() {
         
        loadMoneyView = UIView().loadNib(name: "QRView") as! QRView

        loadMoneyView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: view.frame.width,
                                     height: view.frame.height)
        loadMoneyView.delegate = self
        
        loadMoneyView.tokenName = tokenName
        loadMoneyView.network = network
        loadMoneyView.address = address
        loadMoneyView.adSoyad = adSoyad

        mainView.addSubview(loadMoneyView)
        mainView.isHidden = false
        mainView.translatesAutoresizingMaskIntoConstraints = true
        
    }
    
    
    func popup (image: UIImage?) {
        PHPhotoLibrary.requestAuthorization { status in
          if status == .authorized {
            //do things
          }
            
        }
         
        // Convert the image into png image data
        let pngImageData = image!.pngData()

        // Write the png image into a filepath and return the filepath in NSURL
        let pngImageURL = pngImageData?.dataToFile(fileName:  UUID().uuidString + ".png")

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of png image to the Array
        filesToShare.append(pngImageURL!)
        
        // image to share

        
        let activityViewController = UIActivityViewController(activityItems:filesToShare , applicationActivities: nil)
        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        //activityViewController.popoverPresentationController?.sourceView = self
        
        present(activityViewController, animated: true)
    }
    
    
}


extension ShareQRVC: LoadCoinDelegate
{
    func dismissLoadView() // para yükleme sayfasının gizlenmesi
    {
//        isShowLoadCoinView = false
//        sendMoneyBackButton.isHidden = true
//
//        UIView.animate(withDuration: 0.3) {
//            self.qrView.frame.origin.y = self.view.frame.height
//        }
//        for subView in self.qrView.subviews
//        { subView.removeFromSuperview() }
    }
    
    func shareQR(image: UIImage?) {
        popup(image: image!)
    }
}

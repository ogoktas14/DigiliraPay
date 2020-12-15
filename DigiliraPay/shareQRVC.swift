//
//  shareQRVC.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 17.10.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit
import Photos



class ShareQRVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    var sendMoneyView = newSendView()
    
    let pasteboard = UIPasteboard.general
    public var address: String?
    public var network: String?
    public var tokenName: String?
    public var adSoyad: String?

    var ticker: digilira.ticker?
    private var amount: Double?
    private var price: Double?
    
    private var coinPrice: Double?
    private var usdPrice: Double?

    let digiliraPay = digiliraPayApi()
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {

    }

    func goNewSendView() {
         
        if let sendMoneyView = UIView().loadNib(name: "newSendView") as? newSendView {
            
            sendMoneyView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: view.frame.width,
                                         height: view.frame.height)

            mainView.addSubview(sendMoneyView)
            mainView.isHidden = false
            mainView.translatesAutoresizingMaskIntoConstraints = true
        }
        
    }
    
    
    func popup (image: UIImage?) {
        PHPhotoLibrary.requestAuthorization { status in
          if status == .authorized {
            //do things
          }
            
        }
         
        if let image = image {
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
                    present(activityViewController, animated: true)
                }
            }
        }
    }
}


extension ShareQRVC: LoadCoinDelegate
{
    func errorHandler(message: String) {
        print(message)
    }
    
    func dismissLoadView() // para yükleme sayfasının gizlenmesi
    {

    }
    
    func shareQR(image: UIImage?) {
        if let image = image {
            popup(image: image)
        }
    }
}
 

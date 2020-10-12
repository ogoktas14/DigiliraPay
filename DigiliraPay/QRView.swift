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
    @IBOutlet weak var speratorView: UIView!
    @IBOutlet weak var copyLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var delegate: LoadCoinDelegate?
    let pasteboard = UIPasteboard.general
    public var address: String?
    public var network: String?

    override func awakeFromNib()
    {
        speratorView.backgroundColor = UIColor(red:0.61, green:0.77, blue:0.99, alpha:1.0)
        copyLabel.textColor = UIColor(red:0.61, green:0.77, blue:0.99, alpha:1.0)
        
        shareButtonView.clipsToBounds = true
        shareButtonView.layer.cornerRadius = 6
        
    }
    
    override func didMoveToSuperview() {
        
        adressLabel.text = address
        let image = generateQRCode(from: network! + ":" + address!)
        pasteboard.string = address

        qrImage.image = image
    }

    @IBAction func shareButton(_ sender: Any)
    {
        delegate?.dismissLoadView()
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

//
//  DepositeMoneyView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 13.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit


class DepositeMoneyView: UIView {
    
    var amount: Float? = 0
    var fiat: Float? = 0
    var decimal: Bool = false
    var satoshi: Int? = 0
    var address: String? = ""
    var network: String? = ""
    var source: String? = ""
    
    var transferMode: Int? = 0
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var confirmView: UIView!

    weak var delegate: DepositeMoneyDelegate?

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var estLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBAction func btn1(_ sender: UIButton) {
        let val =  (sender.titleLabel?.text)!
        if  satoshi == 8 {return}
       
        if !decimal {
            if  amountLabel.text!.count > 8 {
                return
                
            }
        }
        
        if amountLabel.text == "0" {
            if val != "." {
                amountLabel.text = val
                return
            }
        }
        
        if (decimal) {
            satoshi! += 1
        }
        
        if val == "." && decimal == true {return}
        amountLabel.text = amountLabel.text! + val
        
        if val == "." {
            decimal = true
        }
        

    }
    @IBAction func btnDelete(_ sender: Any) {
        
        var a = amountLabel.text
        let deleted = a?.last
        if deleted == "." {decimal = false}
        a!.removeLast()
        amountLabel.text = a
        
        if a?.count == 0 {
            amountLabel.text = "0"
        }
        
        
        if (decimal) {
            satoshi! -= 1
        }
        

    }
    
    
    override func awakeFromNib()
    {
        amountLabel.text = "0"
        let tapGestureOK = depositeGesture(target: self, action: #selector(self.tapRecognized))
        tapGestureOK.floatValue = Float.init(amountLabel.text!)
        let tapGestureCancel = UITapGestureRecognizer(target: self, action: #selector(self.cancel))

        confirmView.addGestureRecognizer(tapGestureOK)
        cancelView.addGestureRecognizer(tapGestureCancel)
        
    }
    
    @objc func tapRecognized(gesture: MyTapGesture) {
        amount = Float.init(amountLabel.text!)
        switch transferMode {
        case 0:
            imgView.isHidden = false
            confirmView.isHidden = true
            imgView.backgroundColor = .white
            stackView.isHidden = true
            //estLabel.text = "0xda50bed471c69d75458c50ff05575ee7bac904d4"
            estLabel.adjustsFontSizeToFitWidth = true
            estLabel.minimumScaleFactor = 0.5
            imgView.image = generateQRCode(from: "ethereum:0xda50bed471c69d75458c50ff05575ee7bac904d4")
        case 1:
            //pep para cuzdan
            delegate?.confirmInternalWallet(amount: amount!, fiat: fiat!, network: network!, address: address!, source: source!)
            delegate?.closeDeposite()
            break
        default:
            break
        }
        
    }
    
    
    func confirm () {
        
    }
    
    @objc func cancel(esture: UITapGestureRecognizer) {
        delegate?.closeDeposite()
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





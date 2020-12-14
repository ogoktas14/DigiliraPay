//
//  CoinTableViewCell.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinAmount: UILabel!
    @IBOutlet weak var type: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        BGView.layer.cornerRadius = 0

        let shadow0 = UIView(frame: CGRect(x: 0, y: 0, width: 384, height: 75))
        shadow0.layer.cornerRadius = 21
        shadow0.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadow0.layer.shadowColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5).cgColor
        shadow0.layer.shadowOpacity = 1
        shadow0.layer.shadowRadius = 14
        BGView.addSubview(shadow0)

        let shadow1 = UIView(frame: CGRect(x: 0, y: 0, width: 384, height: 75))
        shadow1.layer.cornerRadius = 21
        shadow1.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadow1.layer.shadowColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5).cgColor
        shadow1.layer.shadowOpacity = 1
        shadow1.layer.shadowRadius = 14
        BGView.addSubview(shadow1)
        
        coinName.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
        type.textColor = UIColor(red:0.68, green:0.68, blue:0.68, alpha:1.0)
        coinAmount.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateCell (val:String) {
//        self.coinCode.text = val
    }
    
}

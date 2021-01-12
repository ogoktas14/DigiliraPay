//
//  CoinTableViewCell.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyIcon: UIView!
    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinAmount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var emptyCoin: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coinName.textColor = .darkGray
        type.textColor = .lightGray
        coinAmount.textColor = .darkGray
        emptyIcon.layer.cornerRadius = emptyIcon.frame.size.height / 2
    }

}

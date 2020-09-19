//
//  transactionHistoryCell.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 30.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class transactionHistoryCell: UITableViewCell {

    @IBOutlet weak var operationImage: UIImageView!
    @IBOutlet weak var operationTitle: UILabel!
    @IBOutlet weak var operationDate: UILabel!
    @IBOutlet weak var operationAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

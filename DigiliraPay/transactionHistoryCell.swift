//
//  transactionHistoryCell.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class transactionHistoryCell: UITableViewCell {
    
    @IBOutlet weak var operationImage: UIImageView!
    @IBOutlet weak var operationTitle: UILabel!
    @IBOutlet weak var operationDate: UILabel!
    @IBOutlet weak var operationAmount: UILabel!
    let lang = Localize()

    override func awakeFromNib() {
        super.awakeFromNib()
        operationTitle.text = lang.getLocalizedString(Localize.keys.no_transaction.rawValue)
        operationDate.text = lang.getLocalizedString(Localize.keys.transaction_access_area.rawValue)
    }    
}

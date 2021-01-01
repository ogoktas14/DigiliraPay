//
//  TransactionHistoryDetailCellHeader.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class TransactionHistoryDetailCellHeader: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellTitle.textColor = .darkGray
        cellAmount.textColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(image: UIImage, title: String, amount: String)
    {
        cellImage.image = image
        cellTitle.text = title
        cellAmount.text = amount
    }
    
}

//
//  TransactionHistoryDetailCellDeatils.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class TransactionHistoryDetailCellDeatils: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellTitle.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
        cellDetail.textColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(image: UIImage, title: String, detail: String)
    {
        cellImage.image = image
        cellTitle.text = title
        cellDetail.text = detail
    }
}

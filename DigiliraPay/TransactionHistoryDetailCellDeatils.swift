//
//  TransactionHistoryDetailCellDeatils.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class TransactionHistoryDetailCellDeatils: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetailBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellTitle.textColor = .darkGray
        cellDetailBtn.setTitleColor(.darkGray, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(image: UIImage, title: String, detail: String)
    {
        cellImage.image = image
        cellTitle.text = title
        cellDetailBtn.setTitle(detail, for: .normal)
    }
}

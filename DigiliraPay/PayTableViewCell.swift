//
//  PayTableViewCell.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 24.11.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit




class PayTableViewCell: UITableViewCell {
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var prodPrice: UILabel! 
    @IBOutlet weak var BGView: UIView! 
 
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
     }
    
}
 

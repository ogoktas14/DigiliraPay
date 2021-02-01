//
//  PayTableViewCell.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 24.11.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

class PayTableViewCell: UITableViewCell {
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var discountView: UIView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
     }
    
}

class CommissionsLineCell: UITableViewCell {
   @IBOutlet weak var prodName: UILabel!
   @IBOutlet weak var prodPrice: UILabel!
   @IBOutlet weak var BGView: UIView!
   @IBOutlet weak var discountView: UIView!
 
   override func awakeFromNib() {
       super.awakeFromNib()
    }
   
}

class CommissionsTableViewCell: UITableViewCell {
   @IBOutlet weak var icon: UIImageView!
   @IBOutlet weak var tokenName: UILabel!
   @IBOutlet weak var send: UILabel!
   @IBOutlet weak var receive: UILabel!
 
   override func awakeFromNib() {
       super.awakeFromNib()
    }
   
}


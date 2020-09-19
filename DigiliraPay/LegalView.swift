//
//  LegalView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Locksmith
class LegalView: UIView {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var confirmView: UIView!
    
    weak var delegate: LegalDelegate?
    override func awakeFromNib()
    {
        try? Locksmith.deleteDataForUserAccount(userAccount: "sensitive")

        confirmView.clipsToBounds = true
        confirmView.layer.cornerRadius = 6
    }
    @IBAction func goBackButton(_ sender: Any)
    {
        delegate?.dismissLegalView()
    }
}

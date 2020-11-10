//
//  selectCoinView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 9.11.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit

class selectCoinView: UIView  {
    
    weak var delegate: SelectCoinViewDelegate?

    
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend()
    }
    
    
}

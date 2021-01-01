//
//  CollectionViewCellExtension.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell
{
    func loadXib(name: String) -> UITableViewCell
    {
        return Bundle.main.loadNibNamed(name, owner: self, options: nil)?.first as! UITableViewCell
    }
}

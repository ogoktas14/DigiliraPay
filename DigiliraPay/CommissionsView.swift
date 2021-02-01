//
//  CommissionsView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 1.02.2021.
//  Copyright © 2021 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit



class CommissionsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var lines:[digilira.line] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().loadXib(name: "CommissionsLineCell") as! CommissionsLineCell
        let cell2 = UITableViewCell().loadXib(name: "CommissionTableCell") as! CommissionsTableViewCell
        print(lines)
        switch lines[indexPath[1]].mode {
        case "text":
            cell.prodName.text = lines[indexPath[1]].text
            return cell
        default:
            cell2.tokenName.text = lines[indexPath[1]].text
            cell2.send.text = lines[indexPath[1]].l1
            cell2.receive.text = lines[indexPath[1]].l2
            cell2.icon.image = lines[indexPath[1]].icon ?? UIImage(named: "BTC")
            return cell2
        }
    }
    
    
    weak var delegate: BitexenAPIDelegate?
    weak var errors: ErrorsDelegate?
    @IBOutlet weak var tableView: UITableView!

    
    @IBAction func btnExit(_ sender: Any) {
        delegate?.dismissBitexen()
    }
  
    
}

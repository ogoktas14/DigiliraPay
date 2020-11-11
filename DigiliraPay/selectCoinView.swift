//
//  selectCoinView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 9.11.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit

class selectCoinView: UIView, UITableViewDelegate  {
    
    weak var delegate: SelectCoinViewDelegate?
    @IBOutlet weak var viewTable: UIView!
    var Filtered: [digilira.DigiliraPayBalance] = []
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()

    var Order: digilira.order?
    
    let tableView = UITableView()
    
    override func awakeFromNib()
    {
        
    }
    
    override func didMoveToSuperview() {
        setupTableView()
        print(Order?.totalPrice)

    }
    
    
    
    
    func setupTableView() {
    viewTable.addSubview(tableView)
      tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

      tableView.topAnchor.constraint(equalTo: viewTable.topAnchor).isActive = true
      tableView.leftAnchor.constraint(equalTo: viewTable.leftAnchor).isActive = true
      tableView.bottomAnchor.constraint(equalTo: viewTable.bottomAnchor).isActive = true
      tableView.rightAnchor.constraint(equalTo: viewTable.rightAnchor).isActive = true
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CoinTableViewCell")
        tableView.reloadData()

    }
 
    func dismissKeyboard() {
        self.endEditing(true)
    }
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend(params: Order!)
    }
    
    
}
extension selectCoinView: UITableViewDataSource {
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Filtered.count
  }
    @objc func handleTap(recognizer: MyTapGesture) {
        if let price = Order?.totalPrice {
            let (amount, asset) = digiliraPay.ratePrice(price: price, asset: recognizer.assetName)
            print(amount, asset)
            let balance = Filtered[recognizer.floatValue].availableBalance
            self.Order?.asset = asset
            if balance < (Int64(amount)) {
                return
            }
            self.Order?.rate = (Int64(amount))
            delegate?.dismissNewSend(params: Order!)
        }
         
    }
    
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = UITableViewCell().loadXib(name: "CoinTableViewCell") as? CoinTableViewCell
    {
        let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
        
        tapped.floatValue = indexPath[1]
        cell.addGestureRecognizer(tapped)
 
        if Filtered.count > 0 {
            
            let asset = Filtered[indexPath[1]]
            cell.coinIcon.image = UIImage(named: asset.tokenName)
            cell.coinName.text = asset.tokenName
            tapped.assetName = asset.tokenName

            let double = Double(asset.balance) / Double(100000000)
            cell.coinAmount.text = (double).description
            cell.coinCode.text = (asset.tokenSymbol)
 
        }
        return cell
    }else
    { return UITableViewCell() }

  }
}

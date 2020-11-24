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
    var Filtered: [digilira.DigiliraPayBalance] = []
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()

    var Ticker: binance.BinanceMarketInfo = []
    let binanceAPI = binance()
    var ticker: digilira.ticker?

    var Order: digilira.order?
    
    @IBOutlet weak var viewTable: UIView!
    @IBOutlet weak var siparisView: UIView!
    
    let tableView = UITableView()

    override func awakeFromNib()
    {
        siparisView.translatesAutoresizingMaskIntoConstraints = true;
        tableView.translatesAutoresizingMaskIntoConstraints = true;
        
        binanceAPI.onBinanceError = { res, sts in
            print("error")
        }
        
        binanceAPI.onBinanceTicker = { [self] res, sts in
            ticker = digiliraPay.ticker(ticker: res)
        }
        binanceAPI.getTicker()
    }
    
    override func didMoveToSuperview() {

    }
    
    func setCustomCell(view1: UIView, rowIndex: Int, info: String, price: Double) {
        let height1 = CGFloat(30)
        
        let width = self.frame.width - 40
        let originX = view1.frame.origin.x + 20
        let label = UILabel(frame: CGRect(x: originX, y: (height1 * 2 + 10) * CGFloat(rowIndex) , width: width, height: height1))
        let priceLbl = UILabel(frame: CGRect(x: originX, y: label.frame.maxY, width: width, height: height1))
        let solidLine = UIView(frame: CGRect(x: originX, y: priceLbl.frame.maxY, width: width, height: 2))

        solidLine.backgroundColor = .lightGray
        
        label.textAlignment = .left
        label.text = info
        
        priceLbl.textAlignment = .left
        priceLbl.text = String(price) + " ₺"


        label.backgroundColor = .white
        //To set the font Dynamic
        label.font = UIFont(name: "Avenir", size: 20.0)
        priceLbl.font = UIFont(name: "Avenir", size: 26.0)
        
        view1.addSubview(label)
        view1.addSubview(priceLbl)
        view1.addSubview(solidLine)
        
        view1.frame.size.height = solidLine.frame.maxY
        view1.frame.size.width = width

    }

    func adjustTableViewHeight() {
         var height = tableView.contentSize.height
         let maxHeight = (tableView.superview?.frame.size.height)! - self.tableView.frame.origin.y

        if height > maxHeight {
            height = maxHeight
        }

        selectCoinView.animate(withDuration: 0.5) {
            //Assuming 'tableViewHeightConstraint` is an IBOutlet from your storyboard/XIB
             //self.tableViewHeightConstraint.constant = height
             self.tableView.setNeedsUpdateConstraints()
         }
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
        
        tableView.frame.size.height = 400
        if Order?.products != nil {

            for (index, item) in Order!.products!.enumerated() {
                setCustomCell(view1: siparisView, rowIndex: index, info: item.order_pname!, price: item.order_price!)
            }
        }
        
        
        if Order?.products == nil {
            for subView in siparisView.subviews
            { subView.removeFromSuperview() }
        }
        
        

    }
 
    func dismissKeyboard() {
        self.endEditing(true)
    }
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.cancel()
    }
    
    
}
extension selectCoinView: UITableViewDataSource {
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Filtered.count
  }
    @objc func handleTap(recognizer: MyTapGesture) {
        if let price = Order?.totalPrice {
            if let ticky = ticker  {
                let (amount, asset) = digiliraPay.ratePrice(price: price, asset: recognizer.assetName, symbol: ticky)
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
            cell.type.text = "₺" + MainScreen.df2so(asset.tlExchange)
            tapped.assetName = asset.tokenName

            let double = Double(asset.balance) / Double(100000000)
            cell.coinAmount.text = MainScreen.df2so(double, digits: 8)
            cell.coinCode.text = (asset.tokenSymbol)
 
        }
        
        return cell
        
    }else
    { return UITableViewCell() }

  }
}

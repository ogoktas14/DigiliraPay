//
//  WalletView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class WalletView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var transactionHistory: UIView!
    @IBOutlet weak var slideIndicatorView: UIView!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyInfo: UILabel!
    
    private var customView: UIView!
    
    var ViewOriginMaxXValue: CGPoint = CGPoint(x: 0, y: 0)
    var tableView = UITableView()
    
    var transactionHistoryOrigin: CGPoint = CGPoint(x: 0, y: 0)
    var transactionHistoryOriginLast: CGPoint = CGPoint(x: 0, y: 0)
    
    var transactionDetailView = TransactionDetailView()
    var transactionDetail = TRXTRX()
    private let refreshControl = UIRefreshControl()

    var frameValue = CGRect()
    var throwEngine = ErrorHandling()

    let BC = Blockchain()
    var trxs:[digilira.transfer] = []

    var kullanici: digilira.auth = try! secretKeys.userData()
  
    var coin: String = ""
     
    override func awakeFromNib()
    { 
        setView()

    }
     
    func setView()
    {
        headerLabel.textColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
        
        transactionHistory.layer.cornerRadius = 10
        //slideIndicatorView.backgroundColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0)
        //slideIndicatorView.layer.cornerRadius = 3
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        transactionHistory.layer.cornerRadius = 6
        
        transactionHistoryOrigin = transactionHistory.frame.origin
        transactionHistoryOriginLast = transactionHistoryOrigin
        
        tableView.refreshControl = refreshControl
        
        refreshControl.attributedTitle = NSAttributedString(string: "Güncellemek için çekiniz..")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        
        readHistory(coin: coin)
        
        emptyView.alpha = 0
        
    }
    
    @objc private func refreshData(_ sender: Any) {
        readHistory(coin: coin)
    }
    
    func readHistory (coin: String) {

        tableView.isUserInteractionEnabled = true
        self.trxs.removeAll()
        BC.checkTransactions(address: self.kullanici.wallet){ (data) in
            DispatchQueue.main.async { [self] in
                print(trxs.count)
                data.forEach { trx in
                    
                    let dateWaves = (978307200 + (trx["timestamp"] as! Int)) * 1000
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" //Specify your format that you want
                    let strDate = dateFormatter.string(from: Date(milliseconds: Int64(dateWaves)) )
                    var attachment: String?
                    if attachment == "null" {
                        print("1")
                    }
                    if (trx["type"] as? Int64 == 4) {
                        if (trx["assetId"] as? String != nil) {
                            if (trx["attachment"] as? String != "") {
                                attachment = self.BC.base58(data: (trx["attachment"] as? String)!)
                            }
                            
                            do {
                                let asset = try self.BC.returnAsset(assetId: trx["assetId"] as! String)
                                
                                
                                var isOK = false
                                if coin == "" {
                                    isOK = true
                                }
                                
                                if asset.tokenName == coin {
                                    isOK = true
                                }
                                
                                
                                if isOK {
                                    self.trxs.append (digilira.transfer.init(type: trx["type"] as? Int64,
                                                                             id: trx["id"] as? String,
                                                                             sender: trx["sender"] as? String,
                                                                             senderPublicKey: trx["senderPublicKey"] as? String,
                                                                             fee: trx["fee"] as! Int64,
                                                                             timestamp: strDate,
                                                                             version: trx["version"] as? Int,
                                                                             height: trx["height"] as? Int64,
                                                                             recipient: trx["recipient"] as? String,
                                                                             amount: (trx["amount"] as! Int64),
                                                                             assetId: asset.token,
                                                                             attachment: attachment
                                    ))
                                    
                                }
                            } catch  {
                                throwEngine.evaluateError(error: error)
                            }
                            

                            
                        }
                    }
        
                    if (trx["type"] as? Int64 == 11) {
                        if (trx["assetId"] as? String != nil) {
                            if (trx["attachment"] as? String != "") {
                                attachment = self.BC.base58(data: (trx["attachment"] as? String)!)
                            }
                            
                            do {
                            let asset = try self.BC.returnAsset(assetId: trx["assetId"] as! String)
                                
                                var isOK = false
                                if coin == "" {
                                    isOK = true
                                }
                                
                                if asset.tokenName == coin {
                                    isOK = true
                                }
                                if isOK == true {
                                    self.trxs.append (digilira.transfer.init(type: trx["type"] as? Int64,
                                                                             id: trx["id"] as? String,
                                                                             sender: trx["sender"] as? String,
                                                                             senderPublicKey: trx["senderPublicKey"] as? String,
                                                                             fee: trx["fee"] as! Int64,
                                                                             timestamp: strDate,
                                                                             version: trx["version"] as? Int,
                                                                             height: trx["height"] as? Int64,
                                                                             recipient: "not",
                                                                             amount: (trx["totalAmount"] as! Int64),
                                                                             assetId: asset.token,
                                                                             attachment: attachment
                                    ))
                                }
                                
                                
                            } catch  {
                                
                            }
                            
                            
 
                        }
                    }
                }
                self.tableView.reloadData()
                self.setTableView()
                self.refreshControl.endRefreshing()

            }
        }
    }
    
    
    
    func setTableView()
    {
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: frameValue.width,
                                 height: frameValue.height)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        transactionHistory.addSubview(tableView)
    }

    
    @IBAction func slideGesture(_ sender: UIPanGestureRecognizer)
    {
        transactionHistory.translatesAutoresizingMaskIntoConstraints = true
        if let gestureView = sender.view
        {
            let shift = sender.translation(in: gestureView)
            transactionHistory.frame.origin.y = CGFloat(transactionHistoryOriginLast.y) + shift.y
            
            if sender.state == .ended
            {
                if transactionHistory.frame.origin.y > transactionHistoryOrigin.y * 2
                {
                    let yValue = self.frame.height - self.transactionHistoryOrigin.y - self.ViewOriginMaxXValue.y - 80
                    UIView.animate(withDuration: 0.5) {
                        self.transactionHistory.frame.origin.y = yValue
                    }
                }
                else
                {
                    UIView.animate(withDuration: 0.5) {
                        self.transactionHistory.frame.origin.y = CGFloat(self.transactionHistoryOrigin.y)
                    }
                }
                
                transactionHistoryOriginLast = transactionHistory.frame.origin
            }
        }
    }
}

extension WalletView: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trxs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().loadXib(name: "transactionHistoryCell") as! transactionHistoryCell
        if trxs.count == 0 {
            return cell
        }
        
        if let assetId = trxs[indexPath[1]].assetId  {
            do {
                let coin = try BC.returnAsset(assetId: assetId)
                let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                cell.operationAmount.text = (Double(trxs[indexPath[1]].amount) / double).description
                cell.operationTitle.text = coin.tokenName
                cell.operationDate.text = trxs[indexPath[1]].timestamp!
                 
                if (trxs[indexPath[1]].recipient == kullanici.wallet) {cell.operationImage.image = UIImage(named: "send")}
                if (trxs[indexPath[1]].sender == kullanici.wallet) {cell.operationImage.image = UIImage(named: "receive")}
                
                self.tableView.rowHeight = 60

                let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
                tapped.floatValue = indexPath[1]
                cell.addGestureRecognizer(tapped)
            } catch {
                throwEngine.evaluateError(error: error)
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        transactionDetailView.originValue.y = 0
        transactionDetailView.originValueLast = transactionDetailView.originValue
        
        UIView.animate(withDuration: 0.3) {
            self.transactionDetailView.frame.origin.y = 0
            //            self.tableView.alpha = 0.3
        }
    }
    
 
    
    @objc func handleTap(recognizer: MyTapGesture) { // gecmisini sorgula
        
        print(recognizer.floatValue)
        showDetail(index: recognizer.floatValue)
    }
    
    func showSuccess(index: Int)
    {
        transactionDetail = UIView().loadNib(name: "TransactionDetailPopup") as! TRXTRX

        //pinView.lbl01.text = trxs[index].id
        transactionDetail.alpha = 0

        transactionDetail.layer.cornerRadius = 0
        transactionDetail.frame = CGRect(x: 0,
                               y: (self.superview?.frame.maxY)!,
                               width: tableView.frame.width,
                               height: tableView.frame.height)
        
        transactionDetail.delegate = self
        
        transactionHistory.addSubview(transactionDetail)
        transactionHistory.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.transactionDetail.frame.origin.y = 0
            self.transactionDetail.alpha = 1
        }
    }
    
    func showDetail(index: Int)
    {
        tableView.isUserInteractionEnabled = false
        transactionDetailView = UIView().loadNib(name: "TransactionDetailView") as! TransactionDetailView

        //pinView.lbl01.text = trxs[index].id
        transactionDetailView.alpha = 0

        transactionDetailView.layer.cornerRadius = 10
        transactionDetailView.frame = CGRect(x: tableView.frame.width * 0.05,
                               y: tableView.frame.height,
                               width: tableView.frame.width * 0.9,
                               height: tableView.frame.height)
        
        
        transactionDetailView.delegate = self
        transactionDetailView.transaction = trxs[index]
        
        transactionHistory.addSubview(transactionDetailView)
        transactionHistory.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.transactionDetailView.frame.origin.y =  self.tableView.frame.height * 0.2
            self.transactionDetailView.alpha = 1
        }
        
    }
}
extension WalletView: TransactionDetailCloseDelegate
{
    func close()
    {
        tableView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.transactionDetailView.frame.origin.y = self.transactionHistory.frame.size.height
            self.tableView.alpha = 1
        }
    }
}

extension WalletView: TRXTRXDel {
    func closeDetail() {
            UIView.animate(withDuration: 0.3) {
            self.transactionDetail.frame.origin.y = self.transactionDetail.frame.size.height
            self.transactionDetail.alpha = 0
        }
    }
  
}

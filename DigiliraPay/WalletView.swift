//
//  WalletView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 30.08.2019.
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
    
    private let refreshControl = UIRefreshControl()
    
    var frameValue = CGRect()
    var throwEngine = ErrorHandling()
    
    let BC = Blockchain()
    var trxs:[digilira.transfer] = []
    var wallet: String?
    var ad_soyad: String?
    
    var coin: String = ""
    var onSight:Bool = false
    
    override func awakeFromNib()
    {
        setView()
    }
    
    func setView()
    {
        headerLabel.textColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
        
        transactionHistory.layer.cornerRadius = 10
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        transactionHistory.layer.cornerRadius = 6
        
        transactionHistoryOrigin = transactionHistory.frame.origin
        transactionHistoryOriginLast = transactionHistoryOrigin
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        refreshControl.alpha = 0
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: frameValue.width,
                                 height: frameValue.height)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        transactionHistory.addSubview(tableView)
        readHistory()
        emptyView.alpha = 0
    }
    
    @objc private func refreshData(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            refreshControl.endRefreshing()
        }
        tableView.isUserInteractionEnabled = false
        readHistory()
    }
    
    func readHistory () {
        
        if onSight{
            throwEngine.waitPlease()
        }
        
        refreshControl.isHidden = true
        
        tableView.isUserInteractionEnabled = false
        self.trxs.removeAll()
        if let walletAddress = wallet {
             
            var notlisted = false
            BC.checkTransactions(address: walletAddress){ (data) in
                DispatchQueue.main.async { [self] in
                    data.forEach { trx in
                        if let d = trx.data {
                            do {
                                let type = try JSONDecoder().decode(TransactionType.self, from: d)
                                
                                if type.type == 4 {
                                    notlisted = false
                                    let value = try JSONDecoder().decode(TransferTransactionModel.self, from: d)
                                    
                                    guard value.assetID != digilira.sponsorToken else { return }
                                    guard value.assetID != digilira.paymentToken else { return }
                                                                      
                                    do {
                                        let tokenName = try BC.returnAsset(assetId: value.assetID)
                                        if coin != "" {
                                            if coin != tokenName.tokenName {return}
                                        }
                                    } catch {
                                        switch error {
                                        case digilira.NAError.notListedToken:
                                            notlisted = true
                                        default:
                                            break
                                        }
                                    }
                                    
                                    guard notlisted == false else { return }
                                    let dateWaves = (978307200 + (value.timestamp)) * 1000
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = NSLocale.current
                                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                                    let strDate = dateFormatter.string(from: Date(milliseconds: Int64(dateWaves)) )
                                    let remarks = self.BC.base58(data: value.attachment ?? "Qmxva3ppbmNpciBUcmFuc2Zlcmk=")
                                    
                                    self.trxs.append (digilira.transfer.init(type: value.type,
                                                                             id: value.id,
                                                                             sender: value.sender,
                                                                             senderPublicKey: value.senderPublicKey,
                                                                             fee: value.fee,
                                                                             timestamp: strDate,
                                                                             version: value.version,
                                                                             recipient: value.recipient,
                                                                             amount: value.amount,
                                                                             assetId: value.assetID,
                                                                             attachment:remarks
                                    ))
                                }
                            } catch {

                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                    self.removeDetail()
                    self.refreshControl.endRefreshing()
                    throwEngine.removeAlert()
                    self.tableView.isUserInteractionEnabled = true
                }
            }
            
            
        }
    }
    
    func removeDetail() {
        if transactionDetailView.alpha == 1 {
            UIView.animate(withDuration: 0.4, animations: { [self] in
                transactionDetailView.alpha = 0
                transactionDetailView.frame.origin.y = self.frame.height
            })
        }
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
        if trxs.count == 0 {
            return 1
        }
        return trxs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().loadXib(name: "transactionHistoryCell") as! transactionHistoryCell
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        if trxs.count == 0 {
            
            return cell
        }
      
            do {
               
                let coin = try BC.returnAsset(assetId: trxs[indexPath[1]].assetId)
                
                cell.operationAmount.text = MainScreen.int2so(trxs[indexPath[1]].amount, digits: coin.decimal)
                cell.operationTitle.text = coin.tokenName
                cell.operationDate.text = trxs[indexPath[1]].timestamp!
                
                if let walletAddress = wallet {
                    
                    if (trxs[indexPath[1]].recipient == walletAddress) {
                        cell.operationImage.image = UIImage(named: "receive")
                        
                    }
                    if (trxs[indexPath[1]].sender == walletAddress) {
                        cell.operationImage.image = UIImage(named: "send")
                    }
                    
                    if (trxs[indexPath[1]].sender == trxs[indexPath[1]].recipient) {
                        cell.operationImage.image = UIImage(named: "receive")
                    }
                }
                
                self.tableView.rowHeight = 60
                
                let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
                tapped.floatValue = indexPath[1]
                cell.addGestureRecognizer(tapped)
            } catch {
                throwEngine.evaluateError(error: error)
            }
     
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        transactionDetailView.originValue.y = 0
        transactionDetailView.originValueLast = transactionDetailView.originValue
    }
    
    @objc func handleTap(recognizer: MyTapGesture) { // gecmisini sorgula
        showDetail(index: recognizer.floatValue)
    }
    
    func showDetail(index: Int)
    {
        if index <= trxs.count {
            tableView.isUserInteractionEnabled = false
            transactionDetailView = UIView().loadNib(name: "TransactionDetailView") as! TransactionDetailView
            
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
    
    func alertO(order:PaymentModel) {
        throwEngine.alertOrder(order: order)
    }
    
    func alertT(message: String, title: String) {
        throwEngine.alertTransaction(title: title, message: message, verifying: true)
    }
    
    func alertEr(error: Error) {
        throwEngine.evaluateError(error: error)
    }
    
    func alertTransfer(order: TransferModel) {
        if let coin = try? BC.returnAsset(assetId: order.assetID) {
            var m = "Gelen Transfer"
            if wallet == order.wallet {
                m = "Giden Transfer"
            }
            
            let t = digilira.txConfMsg.init(title: "Transfer Detayları",
                                            message: m,
                                            l1: "Gönderici: " + order.myName,
                                            l2: "Alıcı: " + order.recipientName,
                                            l3: "Token: " + coin.tokenSymbol,
                                            l4: "Miktar: " + MainScreen.int2so(order.amount, digits: coin.decimal),
                                            l5: "TL Karşılığı: ₺" + order.tickerTl,
                                            l6: "",
                                            yes: "Tamam",
                                            no: "",
                                            icon: "success")
            throwEngine.transferConfirmation(txConMsg: t, destination: .trxConfirm)
        }
    }
}

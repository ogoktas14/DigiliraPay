//
//  TransactionDetailView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class TransactionDetailView: UIView
{
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideIndicator: UIView!
    
    var frameValue = CGRect()
    var tableView: UITableView = UITableView()
    
    var originValue: CGPoint = CGPoint(x: 0, y: 0)
    var originValueLast: CGPoint = CGPoint(x: 0, y: 0)
    
    var crud = centralRequest()
    var transaction:Constants.transfer?

    let BC = BlockchainService()
    let lang = Localize()

    var fetching: Bool = false
    let generator = UINotificationFeedbackGenerator()
    
    var cp: String?
    
    weak var delegate: TransactionDetailCloseDelegate?
    override func awakeFromNib()
    {
        
        slideIndicator.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        slideIndicator.layer.cornerRadius = 3
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        slideView.layer.cornerRadius = 10
        
    }
    
    override func didMoveToSuperview() {
        setView()
    }
    
    func setView()
    {
        tableView.frame = CGRect(x: 0,
                                 y: slideView.frame.size.height,
                                 width: self.frame.width,
                                 height: self.frame.height - slideView.frame.size.height)
        tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 300, right: 0)
        tableView.layer.cornerRadius = 20
        self.tableView.rowHeight = 70
        
        originValueLast.y = self.frame.height * 0.2
        
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        self.addSubview(tableView)
    }
    
    
    @objc func copyText (recognizer: CopyGesture) {
        if let cp = recognizer.cp {
            let pasteboard = UIPasteboard.general
            pasteboard.string = cp
        }
        generator.notificationOccurred(.success)
        if let btn = recognizer.btn {
            let a = btn.title(for: .normal)
            btn.setTitle(recognizer.msg, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                btn.setTitle(a, for: .normal)
            }
        }
    }
    
    @objc func getOr(recognizer: MyTapGesture) {
        if recognizer.qrAttachment == lang.getLocalizedString(Localize.keys.other.rawValue) {
            generator.notificationOccurred(.error)
            return
        }
        
        crud.onError = { [self] error, sts in
            delegate?.alertEr(error: error)
        }
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        do {
            let k = try secretKeys.userData()
            
            var tid = recognizer.qrAttachment
            if recognizer.qrAttachment == "DIGILIRAPAY TRANSFER" {
                tid = recognizer.trxId
                recognizer.assetName = "transfer"
            }
            
            let sign = try BC.bytization([recognizer.assetName, tid, k.id], timestamp)
                
                generator.notificationOccurred(.success)
                let data = Constants.transferGetModel.init(mode: recognizer.assetName,
                                                          user: k.id,
                                                          transactionId: tid,
                                                          signed: sign.signature,
                                                          publicKey: sign.publicKey,
                                                          timestamp: timestamp, wallet: sign.wallet)
                
                crud.onResponse = { data, sts in
                    DispatchQueue.main.async { [self] in

                        switch recognizer.assetName {
                        case "transfer":
                            do {
                                let tm2 = try crud.decodeDefaults(forKey: data, conformance: TransferModel.self)
                                
                                delegate?.alertTransfer(order: tm2)
                                generator.notificationOccurred(.success)
                                
                            } catch {
                                print (error)
                            }
                        case "payment":
                            do {
                                let tm1 = try crud.decodeDefaults(forKey: data, conformance: PaymentModel.self)
                                
                                delegate?.alertO(order: tm1)
                                generator.notificationOccurred(.success)
                                
                            } catch {
                                print (error)
                                delegate?.alertEr(error: Constants.NAError.anErrorOccured)
                            }
                        default:
                            break
                        }
                    }
                }
                
                crud.request(rURL: crud.getApiURL() + Constants.api.transferGet, postData: try? JSONEncoder().encode(data), signature: data.signed)
                
                DispatchQueue.main.async { [self] in
                    delegate?.alertT(message: lang.getLocalizedString(Localize.keys.details_loading.rawValue),
                                     title: lang.getLocalizedString(Localize.keys.details.rawValue))
                
            }
        } catch {
            delegate?.alertEr(error: Constants.NAError.anErrorOccured)
        }
        

    }

    @IBAction func slideGesture(_ sender: UIPanGestureRecognizer)
    {
        self.translatesAutoresizingMaskIntoConstraints = true
        if let gestureView = sender.view
        {
            let shift = sender.translation(in: gestureView)
            self.frame.origin.y = CGFloat(originValueLast.y) + shift.y
            
            if sender.state == .ended
            {
                if self.frame.origin.y > originValue.y * 2
                {
                    delegate?.close()
                }
                else
                {
                    UIView.animate(withDuration: 0.5) {
                        self.self.frame.origin.y = CGFloat(self.originValue.y)
                    }
                }
                originValueLast = self.frame.origin
            }
        }
    }
    
}
extension TransactionDetailView: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let address_copied = lang.getLocalizedString(Localize.keys.address_copied.rawValue)
        let transfer_time = lang.getLocalizedString(Localize.keys.transfer_time.rawValue)
        let click_to_see_details = lang.getLocalizedString(Localize.keys.click_to_see_deta.rawValue)
        let transfer_type = lang.getLocalizedString(Localize.keys.transfer_type.rawValue)
        let receiver = lang.getLocalizedString(Localize.keys.receiver.rawValue)
        let sender = lang.getLocalizedString(Localize.keys.sender.rawValue)
        let other =  lang.getLocalizedString(Localize.keys.details.rawValue)
        
        if indexPath.row == 0
        {
            if let cell = UITableViewCell().loadXib(name: "TransactionHistoryDetailCellHeader") as? TransactionHistoryDetailCellHeader {
                
                if let t = transaction {
                     
                    do {
                        let coin = try BC.returnAsset(assetId: t.assetId)
                        
                        cell.cellImage.image = UIImage(named: coin.tokenSymbol)
                        
                        cell.cellTitle.text = coin.tokenName
                        cell.cellAmount.text = t.amount.int2FormattedString(digits: coin.decimal)
                        
                    } catch  {
                    }
                    
                }
                return cell
            }
        }
        else
        {
            if let cell = UITableViewCell().loadXib(name: "TransactionHistoryDetailCellDeatils") as? TransactionHistoryDetailCellDeatils {
                
                if let t = transaction {
                    switch indexPath.row {
                   
                    case 1:
                        cell.setView(image: UIImage(named: "send")!, title: sender, detail: t.sender!)
                        let tapped = CopyGesture.init(target: self, action: #selector(copyText))
                        tapped.cp = t.sender
                        tapped.btn = cell.cellDetailBtn
                        tapped.msg = address_copied
                        cell.addGestureRecognizer(tapped)
                    case 2:
                        cell.setView(image: UIImage(named: "receive")!, title: receiver, detail: t.recipient!)
                        
                        let tapped = CopyGesture.init(target: self, action: #selector(copyText))
                        tapped.cp = t.recipient
                        tapped.btn = cell.cellDetailBtn
                        tapped.msg = address_copied
                        cell.addGestureRecognizer(tapped)
                    case 3:
                        cell.setView(image: UIImage(named: "time")!, title: transfer_time, detail: t.timestamp!)
                    case 4:
                        cell.setView(image: UIImage(named: "verifying")!, title: click_to_see_details, detail: t.attachment ?? other )
                        
                        if (t.attachment == other) {
                            cell.setView(image: UIImage(named: "verifying")!, title: transfer_type, detail: t.attachment ?? other )
                        }
                        
                        let tapped = MyTapGesture.init(target: self, action: #selector(getOr))
                        tapped.qrAttachment = t.attachment ?? other
                        
                        tapped.trxId = t.id!
                        if t.attachment == "DIGILIRA TRANSFER" {
                            tapped.assetName = "transfer"
                        }
                        tapped.assetName = "payment"
                        cell.addGestureRecognizer(tapped)
                        
                    case 5:
                        break
                    //cell.setView(image: UIImage(), title: "Komisyon", detail: "0.00001325 BTC")
                    default:
                        break
                    }
                    
                }
                
                return cell
                
                
            }
        }
        return UITableViewCell()
    }
    
}

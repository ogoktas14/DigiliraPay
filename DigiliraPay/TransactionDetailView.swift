//
//  TransactionDetailView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
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
    
    var transaction:digilira.transfer?
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    
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
        if recognizer.qrAttachment == "-" {
            generator.notificationOccurred(.error)
        }
        
        digiliraPay.onError = { [self] res, sts in
            delegate?.alertEr(error: res)
        }
        
        if recognizer.qrAttachment == "DIGILIRAPAY TRANSFER" {
            generator.notificationOccurred(.error)
            digiliraPay.onGetTransfer = { [self] res in
                delegate?.alertTransfer(order: res)
            }
            digiliraPay.getTransfer(PARAMS: recognizer.trxId)
            DispatchQueue.main.async { [self] in
                delegate?.alertT(message: "Transder detaylarınız yükleniyor...", title: "Transfer detayları")

            }
            
            return
        }
        
        if fetching {
            return
        }
        fetching = true
        generator.notificationOccurred(.success)
        
        fetching = false
        
        digiliraPay.onGetOrder = { [self] res in
            delegate?.alertO(order: res)
        }
        digiliraPay.getOrder(PARAMS: recognizer.qrAttachment)
        DispatchQueue.main.async { [self] in
            delegate?.alertT(message: "Sipariş detaylarınız yükleniyor...", title: "Sipariş detayları")

        }
    }
    
    @objc func handleTap (recognizer: MyTapGesture) {
        if recognizer.qrAttachment == "-" {
            generator.notificationOccurred(.error)
        }
        if fetching {
            return
        }
        fetching = true
        generator.notificationOccurred(.success)
        
        let QrDict:[String: String] = ["qr": recognizer.qrAttachment]
        NotificationCenter.default.post(name: .orderClick, object: nil, userInfo: QrDict )
        fetching = false
        
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
        if indexPath.row == 0
        {
            if let cell = UITableViewCell().loadXib(name: "TransactionHistoryDetailCellHeader") as? TransactionHistoryDetailCellHeader {
                
                if let t = transaction {
                    
                    do {
                        let coin = try BC.returnAsset(assetId: t.assetId!)
                        
                        let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
                        cell.cellImage.image = UIImage(named: coin.tokenSymbol)
                        
                        cell.cellTitle.text = coin.tokenName
                        cell.cellAmount.text = (Double(t.amount) / double).description
                        
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
                        cell.setView(image: UIImage(named: "send")!, title: "Gönderici", detail: t.sender!)
                        let tapped = CopyGesture.init(target: self, action: #selector(copyText))
                        tapped.cp = t.sender
                        tapped.btn = cell.cellDetailBtn
                        tapped.msg = "Adres Kopyalandı"
                        cell.addGestureRecognizer(tapped)
                    case 2:
                        cell.setView(image: UIImage(named: "receive")!, title: "Alıcı", detail: t.recipient!)
                        
                        let tapped = CopyGesture.init(target: self, action: #selector(copyText))
                        tapped.cp = t.recipient
                        tapped.btn = cell.cellDetailBtn
                        tapped.msg = "Adres Kopyalandı"
                        cell.addGestureRecognizer(tapped)
                    case 3:
                        cell.setView(image: UIImage(named: "time")!, title: "İşlem Zamanı", detail: t.timestamp!)
                    case 4:
                        cell.setView(image: UIImage(named: "verifying")!, title: "Detaylar", detail: t.attachment ?? "-" )
                        
                        let tapped = MyTapGesture.init(target: self, action: #selector(getOr))
                        tapped.qrAttachment = t.attachment ?? "-"
                        tapped.trxId = t.id!
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

//
//  TransactionDetailView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
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
    var kullanici: digilira.user?
    let digiliraPay = digiliraPayApi()

    
    weak var delegate: TransactionDetailCloseDelegate?
    override func awakeFromNib()
    {
        slideIndicator.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        slideIndicator.layer.cornerRadius = 3
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        

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
        self.addSubview(tableView)
    }
    
    
 
    
    @objc func handleTap (recognizer: MyTapGesture) {
        guard let QrDict:[String: String] = ["qr": recognizer.qrAttachment] else {
            return
        }
        
        NotificationCenter.default.post(name: .orderClick, object: nil, userInfo: QrDict )


        
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
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            let cell = UITableViewCell().loadXib(name: "TransactionHistoryDetailCellHeader") as! TransactionHistoryDetailCellHeader
            
            if (transaction!.recipient == kullanici?.wallet) {cell.cellImage.image = UIImage(named: "tReceive48")}
            if (transaction!.sender == kullanici?.wallet) {cell.cellImage.image = UIImage(named: "tSend48")}
            
            cell.cellTitle.text = transaction!.assetId!
            cell.cellAmount.text = (Double(transaction!.amount) / Double(100000000)).description
            
            return cell
        }
        else
        {
            let cell = UITableViewCell().loadXib(name: "TransactionHistoryDetailCellDeatils") as! TransactionHistoryDetailCellDeatils
            
            switch indexPath.row {
                
            case 1:
                cell.setView(image: UIImage(named: "sendericon")!, title: "Gönderici", detail: transaction!.sender!)
            case 2:
                cell.setView(image: UIImage(named: "receiveicon")!, title: "Alıcı", detail: transaction!.recipient!)
            case 3:
                cell.setView(image: UIImage(named: "transactionTime")!, title: "İşlem Zamanı", detail: transaction!.timestamp!)
            case 4:
                    cell.setView(image: UIImage(), title: "İşlem", detail: transaction!.attachment ?? "##" )
                let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
                    tapped.qrAttachment = transaction!.attachment ?? "##"
                cell.addGestureRecognizer(tapped)
                
                
            case 5:
                cell.setView(image: UIImage(), title: "Komisyon", detail: "0.00001325 BTC")
            default:
                break
            }
            
            return cell
        }
    }
    
    
}

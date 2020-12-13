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
    var kullanici: digilira.auth?
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()

    
    weak var delegate: TransactionDetailCloseDelegate?
    override func awakeFromNib()
    {

        slideIndicator.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        slideIndicator.layer.cornerRadius = 3
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        slideView.layer.cornerRadius = 10
        
        digiliraPay.onError = { res, sts in
            DispatchQueue.main.async {
                
                switch sts {
                default:
                    
                    let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu an işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                        exit(1)
                    }))
                    break
                    
                }
            }
        }
        do {
            kullanici = try secretKeys.userData()
        } catch {
            self.digiliraPay.onLogin2 = { user, status in
                self.kullanici = user
            }
            digiliraPay.login2()
        }

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
    
    
 
    
    @objc func handleTap (recognizer: MyTapGesture) {
        let QrDict:[String: String] = ["qr": recognizer.qrAttachment]
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
                    case 2:
                        cell.setView(image: UIImage(named: "receive")!, title: "Alıcı", detail: t.recipient!)
                    case 3:
                        cell.setView(image: UIImage(named: "time")!, title: "İşlem Zamanı", detail: t.timestamp!)
                    case 4:
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = t.recipient!
                            cell.setView(image: UIImage(named: "verifying")!, title: "İşlem", detail: t.attachment ?? "##" )
                        let tapped = MyTapGesture.init(target: self, action: #selector(handleTap))
                            tapped.qrAttachment = t.attachment ?? "##"
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

//
//  TransactionDetailCloseDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 31.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol TransactionDetailCloseDelegate: class
{
    func close()
    func alertO(order:PaymentModel)
    func alertTransfer(order:TransferModel)
    func alertT(message:String, title: String)
    func alertEr(error: Error)
}



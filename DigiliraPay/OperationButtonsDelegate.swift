//
//  OperationButtonsDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 1.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

   struct SendTrx {
    var merchant:String
       var recipient: String
       var assetId: String
       var amount: Int64
       var fee: Int64
    var fiat: Double
       var attachment:String
   }


protocol OperationButtonsDelegate: class
{
    func send(params: SendTrx)
    func load()
}


protocol PaymentCatViewsDelegate: class {
    func dismiss()
}

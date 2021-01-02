//
//  OperationButtonsDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 1.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

struct SendTrx: Codable {
        var merchant:String?
        var recipient: String?
        var assetId: String?
        var amount: Int64?
        var fee: Int64?
        var fiat: Double
        var attachment:String
        var network: String?
        var destination: String
        var externalAddress: String?
        var massWallet: String?
        var massNameSurname: String?
        var products: [Product]?
        var memberCheck: Bool = false
        var me: String
        var blockchainFee: Int64
        var merchantId: String?
   }

protocol OperationButtonsDelegate: class
{
    func send(params: SendTrx)
    func load()
}

protocol PaymentCatViewsDelegate: class {
    func dismiss()
    func passData(data: String)
}

protocol ColoredCardViewDelegate: class {
    func passData(data: String)
}

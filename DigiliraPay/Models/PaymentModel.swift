//
//  PaymentModel.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 22.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:

import Foundation

// MARK: - PaymentModel
struct PaymentModel: Codable {
    let whois: Whois?
    let refundPrice: Double?
    let currencyFiat, status: Double
    let called: Bool
    let id, merchant, orderRef: String
    let orderShipping: Double?
    let conversationID, ip: String
    let paidPrice, totalPrice: Double
    let callbackFailure, callbackSuccess, successURL, failureURL: String?
    let products: [Product]?
    let user, createdDate, orderDate: String
    let history: [History]?
    let refund: [Product]?
    let v: Int
    var currency: String?
    var rate: Int64?
    var trx: String?
    let paymentModelID: String

    enum CodingKeys: String, CodingKey {
        case whois, refundPrice, currencyFiat, status, called
        case id = "_id"
        case merchant
        case orderRef = "order_ref"
        case orderShipping = "order_shipping"
        case conversationID = "conversationId"
        case ip, paidPrice, totalPrice, callbackFailure, callbackSuccess
        case successURL = "successUrl"
        case failureURL = "failureUrl"
        case products, user, createdDate
        case orderDate = "order_date"
        case history, refund
        case v = "__v"
        case currency, rate, trx
        case paymentModelID = "id"
    }
}

// MARK: - Product
struct Product: Codable {
    let orderStatus: Int?
    let id, order_pname, order_pcode: String?
    let order_price: Double?
    let order_qty: Int?

    enum CodingKeys: String, CodingKey {
        case orderStatus = "order_status"
        case id = "_id"
        case order_pname = "order_pname"
        case order_pcode = "order_pcode"
        case order_price = "order_price"
        case order_qty = "order_qty"
    }
}

// MARK: - Whois
struct Whois: Codable {
    let name, surname, wallet, id: String?

    enum CodingKeys: String, CodingKey {
        case name, surname, wallet
        case id = "_id"
    }
}
 

// MARK: - History
struct History: Codable {
    let remarks: [Product]?
    let id, action, date: String?

    enum CodingKeys: String, CodingKey {
        case remarks
        case id = "_id"
        case action, date
    }
}
 
 

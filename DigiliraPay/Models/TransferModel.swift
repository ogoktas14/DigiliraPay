//
//  TransferModel.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 24.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:

import Foundation

// MARK: - TransferDestination
struct TransferDestination: Codable {
    let wallet: String
    let owner: String
    let destination: String
}

// MARK: - TransferOnWay
struct TransferOnWay: Codable {
    let recipientName: String
    let recipient: String
    let myName: String
    let wallet: String
    let amount: Int64
    let assetId: String
    let tickerTl: String
    let tickerUsd: Double
    let fee:Int64
    let feeAssetId: String
    let blockchainFee: Int64
    let transactionID: String
    let destination: String
    let externalAddress: String
    let attachment: String
    let merchantId: String
    let publicKey: String
    let signed: String
    let timestamp: Int64
}
 
// MARK: - TransferModel
struct TransferModel: Codable {
    let id: String?
    let myName: String
    let amount: Int64
    let feeAssetID: String
    let blockchainFee, tickerUsd, fee: Int64
    let externalAddress, wallet, merchantID, recipientName: String
    let recipient: String
    let tickerTl: String
    let assetID, destination, attachment: String
    let v: Int
    let createdDate, transferModelID: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case myName, amount
        case feeAssetID = "feeAssetId"
        case blockchainFee, tickerUsd, fee, externalAddress, wallet
        case merchantID = "merchantId"
        case recipientName, recipient, tickerTl
        case assetID = "assetId"
        case destination, attachment
        case v = "__v"
        case createdDate
        case transferModelID = "id"
    }
}

struct ConfirmationModelElement: Codable {
    let status: String
    let height, confirmations: Int?
    let applicationStatus, id: String?
}

typealias ConfirmationModel = [ConfirmationModelElement]

// MARK: - TransferTransactionModel
struct TransactionType: Codable {
    let type: Int
    enum CodingKeys: String, CodingKey {
        case type
    }
}

struct TransferTransactionModel: Codable {
    let type: Int
    let id, sender, senderPublicKey: String
    let fee: Int64
    let feeAssetID: String?
    let timestamp: Int
    let proofs: [String]
    let version: Int
    let assetID: String?
    let recipient: String
    let feeAsset: String?
    let amount: Int64
    let attachment: String?
    let height: Int?
    let applicationStatus: String?

    enum CodingKeys: String, CodingKey {
        case type, id, sender, senderPublicKey, fee
        case feeAssetID = "feeAssetId"
        case timestamp, proofs, version, recipient
        case assetID = "assetId"
        case feeAsset, amount, attachment, height, applicationStatus
    }
}

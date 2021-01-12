//
//  WavesModels.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.01.2021.
//  Copyright © 2021 DigiliraPay. All rights reserved.
//

import Foundation

// MARK: - WavesTokenError
struct WavesTokenError: Codable {
    let errors: [Error1]
}

// MARK: - Error
struct Error1: Codable {
    let code: Int
    let message: String
}


// MARK: - FeeCalculate
struct FeeCalculate: Codable {
    let type: Int
    let senderPublicKey, feeAssetID, assetID, recipient: String
    let amount: Int64

    enum CodingKeys: String, CodingKey {
        case type, senderPublicKey
        case feeAssetID = "feeAssetId"
        case assetID = "assetId"
        case recipient, amount
    }
}

// MARK: - FeeCalculateResponse
struct FeeCalculateResponse: Codable {
    let feeAssetID: String?
    let feeAmount: Int64

    enum CodingKeys: String, CodingKey {
        case feeAssetID = "feeAssetId"
        case feeAmount
    }
}

// MARK: - WavesAPIError
struct WavesAPIError: Codable {
    let errors: [Error2]
}

// MARK: - Error
struct Error2: Codable {
    let message: String
}

// MARK: - WavesDataTransaction
struct WavesDataTransaction: Codable {
    let key, type, value: String
}

// MARK: - WavesListedToken
struct WavesListedToken: Codable {
    let token, tokenName, network, tokenSymbol: String
    let decimal: Int?
    let gatewayFee: Double
}

typealias WavesListedTokens = [WavesListedToken]

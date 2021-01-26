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
    let key, type: String
    let value: Value
}

enum Value: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - WavesListedToken
struct WavesListedToken: Codable {
    let token, tokenName, network, tokenSymbol: String
    let symbol: String
    let decimal: Int
    let gatewayFee: Double
    let wavesFee: Double
    let role: Int
}

typealias WavesListedTokens = [WavesListedToken]



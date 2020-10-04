//
//  constants.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 11.11.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

 
struct digilira {
    
  
    struct requestMethod {
        static let put = "PUT"
        static let post = "POST"
        static let get = "GET"
    }
    struct api {
        static let url = "https://api.digilirapay.com/v4"
        static let payment = "/payment/"
        static let paymentStatus = "/payment/status"
        static let userUpdate =  "/users/update/me"
        static let auth =  "/users/authenticate"
    }
    struct node {
        static let url = "https://nodes-testnet.wavesnodes.com"
    }
    struct messages {
        static let profileUpdateHeader = "Profilinizi Güncelleyin"
        static let profileUpdateMessage = "Ödeme yapmadan önce profilinizi tamamlamanız gerekmektedir."
    }
    
    struct smartAccount {
        static let script = "base64:AwQAAAALZGlnaWxpcmFQYXkBAAAAIIGltNmBhtc4XZH/2xg8adPSYHrptRihKnbat0wWPcgRBAAAAAckbWF0Y2gwBQAAAAJ0eAMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAATVHJhbnNmZXJUcmFuc2FjdGlvbgQAAAABdwUAAAAHJG1hdGNoMAMJAQAAAAlpc0RlZmluZWQAAAABCAUAAAABdwAAAAdhc3NldElkBgMJAAAAAAAAAggFAAAAAXcAAAAJcmVjaXBpZW50CQEAAAAUYWRkcmVzc0Zyb21QdWJsaWNLZXkAAAABBQAAAAtkaWdpbGlyYVBheQYJAAACAAAAAQIAAAAPY2FudCBzZW5kIHdhdmVzAwMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAXTWFzc1RyYW5zZmVyVHJhbnNhY3Rpb24GAwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAAAVPcmRlcgYDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAEExlYXNlVHJhbnNhY3Rpb24GCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAD0J1cm5UcmFuc2FjdGlvbgQAAAABeAUAAAAHJG1hdGNoMAcDAwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAAA9EYXRhVHJhbnNhY3Rpb24GAwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABNFeGNoYW5nZVRyYW5zYWN0aW9uBgkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABRTZXRTY3JpcHRUcmFuc2FjdGlvbgQAAAABdAUAAAAHJG1hdGNoMAkAAfQAAAADCAUAAAABdAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAXQAAAAGcHJvb2ZzAAAAAAAAAAAABQAAAAtkaWdpbGlyYVBheQavvrd9"

    }
    
    struct transfer: Encodable {
        var type: Int64?
        var id: String?
        var sender: String?
        var senderPublicKey: String?
        var fee: Int64
        var timestamp: String?
        var version: Int?
        var height:Int64?
        var recipient: String?
        var amount: Int64
        var assetId: String?
        var attachment: String?
    }
    
    struct user: Encodable {
        var username: String?
        var password: String?
        var firstName: String?
        var lastName: String?
        var tcno: String?
        var tel: String?
        var mail: String?
        var btcAddress: String?
        var ethAddress: String?
        var ltcAddress: String?
        var wallet: String?
        var token: String?
        var status: Int64?
        var pincode: Int32?
        var imported: Bool?
    }
    
    struct pin: Encodable {
        var pincode: Int32?
    }
    
    struct odemeStatus: Encodable {
        var id: String
        var txid: String?
        var status: String
        var name: String?
        var surname: String?
    }
    
    struct login: Encodable {
        var username: String
        var password: String
    }

    struct auth: Encodable {
        var name: String?
        var surname: String?
        var token: String?
        var status: Int64?
        var pincode: Int32?
    }
    struct wallet: Encodable {
        var seed: String?
    }
    
    struct order:  Encodable {
        var _id:String
        var merchant: String
        var user: String?
        var language: String?
        var order_ref: String?
        var createdDate: String?
        var order_date: String?
        var order_shipping: Double?
        var conversationId: String?
        var rate: Int64
        var totalPrice: Double?
        var paidPrice: Double?
        var refundPrice: Double?
        var currency: String?
        var currencyFiat: Double?
        var userId: String?
        var paymentChannel: String?
        var ip: String?
        var registrationDate: String?
        var wallet: String
        var asset: String?
        var successUrl: String?
        var failureUrl: String?
        var callbackSuccess: String?
        var callbackFailure: String?
        var mobile: Int64?
        var status: Int64?
        
    }
}




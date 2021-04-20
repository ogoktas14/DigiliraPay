//
//  constants.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 11.11.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

enum DeviceLockState {
    case locked
    case unlocked
}
 
struct Constants {
    static let dummyName = "Satoshi Nakamoto"
    
    struct requestMethod {
        static let put = "PUT"
        static let post = "POST"
        static let get = "GET"
    }
    
    struct api {
        static let sslpin = "https://pay.digilirapay.com/"
        static let url = "https://server1.digilirapay.com/v4"
        static let urlMainnet = "https://server1.digilirapay.com/v7"
                
        static let transferGet = "/transfer/get"
        static let isOurMember = "/transfer/recipient"
        static let transferNew = "/transfer/create/new"
        
        static let userRegister =  "/users/register"
        static let userUpdate =  "/users/update/me"
    }
    
    struct node {
        static let url = "https://nodes.wavesnodes.com"
        static let apiUrl = "https://api.waves.exchange"
        static let apiTestnetUrl = "https://api-testnet.waves.exchange"
    }
    
    struct wavesApiEndpoints {
        static let getToken = "/v1/oauth2/token"
        static let getDeposit = "/v1/deposit/addresses/"
        static let getCurrencies = "/v1/deposit/currencies"
        static let getWithdraw = "/v1/withdraw/addresses/"
        
        static let client_id = "waves.exchange"
        static let BTC = "BTC"
        static let ETH = "ETH"
        static let LTC = "LTC"
        static let USDT = "USDT"
        static let scope = "general"
        static let grant_type_password = "password"
        static let grant_type_refresh = "refresh_token"
    }
    
    struct nodeTestNet {
        static let url = "https://nodes-testnet.wavesnodes.com"
        static let apiUrl = "https://api-testnet.waves.exchange"
    }
    
    struct authTokenWaves: Codable {
        var grant_type: String = "password"
        var scope: String = "scope"
        var username: String
        var password: String
        var client_id: String = "waves.exchange"
    }
    
    struct sslPinning {
        static let cert = "cloudflaressl"
        static let binance = "binance.com"
        static let bexCert = "bitexen.com"
        static let bexTestCert = "testBitexen"
        static let wavesCert = "wavesnodes.com"
        static let fileType = "cer"
    }
    
    struct cardData {
        var org: String
        var bgColor: UIColor
        var logoName: String
        var cardHolder: String
        var cardNumber: String
        var line1: String?
        var line2: String?
        var line3: String?
        var apiSet: Bool = false
        var bg: String?
    }
    
    struct transferGetModel: Codable {
        var mode: String
        var user: String
        var transactionId: String
        var signed: String
        var publicKey: String
        var timestamp: Int64
        var wallet: String
    }
    
    static let tcDoguralma = "https://tckimlik.nvi.gov.tr/Service/KPSPublic.asmx?op=TCKimlikNoDogrula&wsdl"
    static let soapAction = "http://tckimlik.nvi.gov.tr/WS/TCKimlikNoDogrula"
    
    struct bexURL {
        static let baseUrl = "https://www.bitexen.com"
        static let baseTestUrl = "https://test.bitexen.com"
        static let balances = "/api/v1/balance/"
        static let ticker = "/api/v1/ticker/"
        static let marketInfo = "/api/v1/market_info/"
        static let makePayment = "/b2b/v1/user/make_payment/"
        static let withdraw = "/api/v1/withdrawal/request/"
        static let commit = "/b2b/v1/app/commit_payment/"
        static let cancel = "/b2b/v1/app/cancel_payment/"
    }
    
    struct binanceURL {
        static let baseUrl = "https://www.binance.com"
        static let ticker = "/api/v3/ticker/price"
    }

    struct coin {
         var token: String
         var symbol: String
         var tokenName: String
         var decimal: Int
         var network: String
         var tokenSymbol: String
         var gatewayFee: Double
    }
    
    struct keychainData {
        var authenticateData: String
        var sensitiveData: String
        var wavesToken: String
    }
    
    static var demo = ["Bitcoin", "Ethereum", "Waves"]
    static var demoIcon = ["Bitcoin", "Ethereum", "Waves"]
 
    
    static var bitcoinNetwork = "bitcoin"
    static var ethereumNetwork = "ethereum"
    static var wavesNetwork = "waves"

    static var sponsorToken = "7GnHzTaDe3YbDiCD9rueHiSfPB7hdanPpN4Ab79fJGtD"
    static var paymentToken = "FLsa9hfu1jvXC6jhDP2x6DHHQHK2qiKPtS7D74ZFNsE1"
    
    static var mainnetSponsorToken = "HLfv6YiY1ZpDktcKL9R79FTcez9WdMjaeMWxhREGcAqr"
    static var mainnetPaymentToken = "HDBmVe4MFyVdh1Jy48m9XqXiHAVuNbwFB8dPskVMHS6B"
    
    static var sponsorTokenFee:Int64 = 9
    static var sponsorTokenFeeMass:Int64 = 9
    
    static var usdt = coin.init(
        token: "BITEXEN_USDT",
        symbol: "USDT",
        tokenName: "USDT",
        decimal: 1,
        network: "",
        tokenSymbol: "",
        gatewayFee: 0
    )
    
    static var demoCoin = coin.init(
        token: "DigiliraPay",
        symbol: "D-Pay",
        tokenName: "DigiliraPay",
        decimal: 2,
        network: "",
        tokenSymbol: "D-Pay",
        gatewayFee: 0
    )
 
    static var waves = coin.init(token: "",
                            symbol: "WAVES",
                            tokenName: "Waves",
                            decimal: 8,
                            network: "waves",
                            tokenSymbol: "Waves",
                            gatewayFee: 0)
 
    struct transactionDestination {
        static let domestic = "domestic"
        static let foreign = "foreign"
        static let interwallets = "interwallets"
        static let unregistered = "unregistered"
    }
    
    struct regExp {
        static let seedRegex = "^(?:[a-z]+ ){14}[a-z]*$"
    }
    
    struct shoppingCart {
        var label: String
        var price: Double
        var mode: Int
    }
    
    struct line {
        var mode:String
        var text: String
        var icon: UIImage?
        var l1: String?
        var l2: String?
        var minSend: String?
        var minReceive: String?
    }
 
    struct smartAccountMainnet {
        static let script = "base64:BAQAAAALRElHSUxJUkFQQVkBAAAAIDmVR3u/lZNrOpSSFxXLNtmTNVImj2b1GDQDKuAGDRolBAAAAAdHQVRFV0FZAQAAACCO6r+3LgkpuiH8C5rOMI2/PNFUO7GqL1vKuVFNZDBuXgQAAAAMU1BPTlNPUlRPS0VOAQAAACDyxQcsnqlaXS/AKeKbGhUub9BxFmel2Oftrg3Rz2gc3QQAAAAMUEFZTUVOVFRPS0VOAQAAACDw2iKNQDJjGfbIVQ1tkK3gOKtCC1S+TyWTMj/j2m2ysAQAAAANUkVDT1ZFUllUT0tFTgEAAAAg8pmg2pc9aaHJXVMcEXqzU0vW0id96e5Cg7Kfl9nQDSIEAAAAClBST1hZV0FWRVMBAAAABBOr2TMEAAAACVJFQ09WRVJZMQEAAAAgHAEkDe7uiGjbOGGSdQ7vBkQnhGLJXR1vQLnO3ZUCul0EAAAACVJFQ09WRVJZMgEAAAAggBQhwRfcRDq5VKb9VzDN/Nj7h+zYqf5VU6HBwznBFW4EAAAACVJFQ09WRVJZMwEAAAAgl3EWKyJtoVUHwaD2oFWXbVNAr10G2Yfss7W/hHClHGsEAAAABkJBTk5FRAAAAAAAAAYmOAQAAAAPRElHSUxJUkFQQVlPTkxZAAAAAAAAAABjBAAAAA1UUkFOU0ZFUkJMT0NLAAAAAAAAAABkBAAAAAxQQVlNRU5UQkxPQ0sAAAAAAAAAAMgEAAAAEFBBWU1FTlRGVU5EQkxPQ0sAAAAAAAAAASwEAAAACUZVTkRCTE9DSwAAAAAAAAABkAoBAAAACHJlY292ZXJ5AAAAAAQAAAACczEDCQAB9AAAAAMIBQAAAAJ0eAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAnR4AAAABnByb29mcwAAAAAAAAAAAAUAAAAJUkVDT1ZFUlkxAAAAAAAAAAABAAAAAAAAAAAABAAAAAJzMgMJAAH0AAAAAwgFAAAAAnR4AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAACdHgAAAAGcHJvb2ZzAAAAAAAAAAABBQAAAAlSRUNPVkVSWTIAAAAAAAAAAAEAAAAAAAAAAAAEAAAAAnMzAwkAAfQAAAADCAUAAAACdHgAAAAJYm9keUJ5dGVzCQABkQAAAAIIBQAAAAJ0eAAAAAZwcm9vZnMAAAAAAAAAAAIFAAAACVJFQ09WRVJZMwAAAAAAAAAAAQAAAAAAAAAAAAMJAABnAAAAAgkAAGQAAAACCQAAZAAAAAIFAAAAAnMxBQAAAAJzMgUAAAACczMAAAAAAAAAAAIGCQAAAgAAAAECAAAADFVuYXV0aG9yaXplZAoBAAAACGNoZWNrRmVlAAAAAQAAAAF3BAAAAANmZWUIBQAAAAF3AAAAA2ZlZQQAAAARaXNGZWVQYXltZW50VG9rZW4JAAAAAAAAAggFAAAAAXcAAAAKZmVlQXNzZXRJZAUAAAAMUEFZTUVOVFRPS0VOBAAAABFpc0ZlZVNwb25zb3JUb2tlbgkAAAAAAAACCAUAAAABdwAAAApmZWVBc3NldElkBQAAAAxTUE9OU09SVE9LRU4EAAAADXVuU2NyaXB0ZWRGZWUAAAAAAAAAAAUEAAAAC3NjcmlwdGVkRmVlAAAAAAAAAAAJBAAAAAppc1NjcmlwdGVkBAAAAAckbWF0Y2gwCQAD7AAAAAEJAQAAAAt2YWx1ZU9yRWxzZQAAAAIIBQAAAAF3AAAAB2Fzc2V0SWQFAAAAClBST1hZV0FWRVMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAABUFzc2V0BAAAAAVhc3NldAUAAAAHJG1hdGNoMAMIBQAAAAVhc3NldAAAAAhzY3JpcHRlZAYHBwMDCQEAAAABIQAAAAEFAAAAEWlzRmVlUGF5bWVudFRva2VuCQEAAAABIQAAAAEFAAAAEWlzRmVlU3BvbnNvclRva2VuBwkAAfQAAAADCAUAAAACdHgAAAAJYm9keUJ5dGVzCQABkQAAAAIIBQAAAAJ0eAAAAAZwcm9vZnMAAAAAAAAAAAAIBQAAAAJ0eAAAAA9zZW5kZXJQdWJsaWNLZXkDAwMFAAAACmlzU2NyaXB0ZWQJAAAAAAAAAgUAAAADZmVlBQAAAAtzY3JpcHRlZEZlZQcGAwkBAAAAASEAAAABBQAAAAppc1NjcmlwdGVkCQAAAAAAAAIFAAAAA2ZlZQUAAAANdW5TY3JpcHRlZEZlZQcJAAH0AAAAAwgFAAAAAnR4AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAACdHgAAAAGcHJvb2ZzAAAAAAAAAAAACAUAAAACdHgAAAAPc2VuZGVyUHVibGljS2V5CQAAAgAAAAEJAAEsAAAAAgkAAaQAAAABBQAAAANmZWUCAAAAEyBmZWVBbW91bnQgaXMgd3JvbmcKAQAAAAlnZXRTdGF0dXMAAAABAAAAA2tleQkBAAAAC3ZhbHVlT3JFbHNlAAAAAgkABBoAAAACCQEAAAAUYWRkcmVzc0Zyb21QdWJsaWNLZXkAAAABBQAAAAtESUdJTElSQVBBWQkAAlgAAAABBQAAAANrZXkAAAAAAAAAAAAEAAAAByRtYXRjaDAFAAAAAnR4AwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABNUcmFuc2ZlclRyYW5zYWN0aW9uBAAAAAF3BQAAAAckbWF0Y2gwBAAAAAhteVN0YXR1cwkBAAAACWdldFN0YXR1cwAAAAEICAUAAAABdwAAAAZzZW5kZXIAAAAFYnl0ZXMEAAAAD3JlY2lwaWVudFN0YXR1cwkBAAAACWdldFN0YXR1cwAAAAEICQAEJAAAAAEIBQAAAAF3AAAACXJlY2lwaWVudAAAAAVieXRlcwQAAAALYXNzZXRTdGF0dXMJAQAAAAlnZXRTdGF0dXMAAAABCQEAAAALdmFsdWVPckVsc2UAAAACCAUAAAABdwAAAAdhc3NldElkBQAAAApQUk9YWVdBVkVTBAAAABFkaWdpbGlyYVJlY2lwaWVudAkAAGYAAAACBQAAAA9yZWNpcGllbnRTdGF0dXMAAAAAAAAAAAAEAAAADm15U3RhdHVzQmFubmVkCQAAAAAAAAIFAAAACG15U3RhdHVzBQAAAAZCQU5ORUQEAAAAFXJlY2lwaWVudFN0YXR1c0Jhbm5lZAkAAAAAAAACBQAAAA9yZWNpcGllbnRTdGF0dXMFAAAABkJBTk5FRAQAAAARYXNzZXRTdGF0dXNCYW5uZWQJAAAAAAAAAgUAAAALYXNzZXRTdGF0dXMFAAAABkJBTk5FRAQAAAASaXNGZWVSZWNvdmVyeVRva2VuCQAAAAAAAAIIBQAAAAF3AAAACmZlZUFzc2V0SWQFAAAADVJFQ09WRVJZVE9LRU4EAAAAEmlzUmVjaXBpZW50R2F0ZXdheQkAAAAAAAACCAUAAAABdwAAAAlyZWNpcGllbnQJAQAAABRhZGRyZXNzRnJvbVB1YmxpY0tleQAAAAEFAAAAB0dBVEVXQVkEAAAAEWlzRmVlUGF5bWVudFRva2VuCQAAAAAAAAIIBQAAAAF3AAAACmZlZUFzc2V0SWQFAAAADFBBWU1FTlRUT0tFTgQAAAARaXNGZWVTcG9uc29yVG9rZW4JAAAAAAAAAggFAAAAAXcAAAAKZmVlQXNzZXRJZAUAAAAMU1BPTlNPUlRPS0VOBAAAABBpc0V4Y2x1c2l2ZVRva2VuCQAAAAAAAAIFAAAAD0RJR0lMSVJBUEFZT05MWQkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAEAAAAFmlzRGlnaWxpcmFQYXlFeGNsdXNpdmUJAABmAAAAAgUAAAAPRElHSUxJUkFQQVlPTkxZCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwAAAAAAAAAAAAQAAAAWcGVybWlzc2lvblRyYW5zZmVyVG9EUAMJAABmAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMFAAAABkJBTk5FRAkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAPcmVjaXBpZW50U3RhdHVzAAAAAAAAAAAABgkAAGYAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwUAAAAGQkFOTkVECQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAhteVN0YXR1cwAAAAAAAAAAAAQAAAARcGVybWlzc2lvblBheW1lbnQDCQAAZgAAAAIFAAAACUZVTkRCTE9DSwkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAFAAAADFBBWU1FTlRCTE9DSwcEAAAAF3Blcm1pc3Npb25UcmFuc2Zlck5vdERQAwkAAGYAAAACBQAAAA1UUkFOU0ZFUkJMT0NLCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwAAAAAAAAAAAAYJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAFAAAAEFBBWU1FTlRGVU5EQkxPQ0sEAAAACmlzUmVjb3ZlcnkDAwMFAAAAEWRpZ2lsaXJhUmVjaXBpZW50BQAAABJpc0ZlZVJlY292ZXJ5VG9rZW4HBQAAABJpc1JlY2lwaWVudEdhdGV3YXkHBQAAAA5teVN0YXR1c0Jhbm5lZAcDAwUAAAAKaXNSZWNvdmVyeQkBAAAACHJlY292ZXJ5AAAAAAcGAwUAAAARZGlnaWxpcmFSZWNpcGllbnQEAAAABnByb2xvZwIAAAAjVHJhbnNmZXIgdG8gRGlnaWxpcmFQYXkgcmVjaXBpZW50OiADBQAAAA5teVN0YXR1c0Jhbm5lZAkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAgVGhpcyBhY2NvdW50IGhhcyBiZWVuIHN1c3BlbmRlZC4DBQAAABVyZWNpcGllbnRTdGF0dXNCYW5uZWQJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAJ1JlY2lwaWVudCdzIGFjY291bnQgaGFzIGJlZW4gc3VzcGVuZGVkLgMFAAAAEWFzc2V0U3RhdHVzQmFubmVkCQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAABtBc3NldCBjYW5ub3QgYmUgdHJhbnNmZXJlZC4DBQAAABZwZXJtaXNzaW9uVHJhbnNmZXJUb0RQCQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAAD1Bc3NldCBjYW5ub3QgYmUgdHJhbnNmZXJlZC4gUmVjaXBpZW50L1NlbmRlciBpcyBub3QgZWxpZ2libGUuAwUAAAAWaXNEaWdpbGlyYVBheUV4Y2x1c2l2ZQkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAXTm9uLVRyYW5zZmVyYWJsZSBUb2tlbi4DBQAAABJpc1JlY2lwaWVudEdhdGV3YXkDAwUAAAARcGVybWlzc2lvblBheW1lbnQGBQAAABBpc0V4Y2x1c2l2ZVRva2VuCQEAAAAIY2hlY2tGZWUAAAABBQAAAAF3CQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAACFBc3NldCBjYW5ub3QgYmUgdXNlZCBvbiBwYXltZW50cy4DBQAAABFpc0ZlZVBheW1lbnRUb2tlbgkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAdUGF5bWVudCBUb2tlbiBjYW5ub3QgYmUgdXNlZC4JAQAAAAhjaGVja0ZlZQAAAAEFAAAAAXcEAAAABnByb2xvZwIAAAAnVHJhbnNmZXIgdG8gbm90IERpZ2lsaXJhUGF5IHJlY2lwaWVudDogAwUAAAARaXNGZWVQYXltZW50VG9rZW4JAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAHVBheW1lbnQgVG9rZW4gY2Fubm90IGJlIHVzZWQuAwUAAAAObXlTdGF0dXNCYW5uZWQJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAIFRoaXMgYWNjb3VudCBoYXMgYmVlbiBzdXNwZW5kZWQuAwUAAAAXcGVybWlzc2lvblRyYW5zZmVyTm90RFAJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAIFRoaXMgYXNzZXQgY2Fubm90IGJlIHRyYW5zZmVyZWQuCQAB9AAAAAMIBQAAAAJ0eAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAnR4AAAABnByb29mcwAAAAAAAAAAAAgFAAAAAnR4AAAAD3NlbmRlclB1YmxpY0tleQMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAD0RhdGFUcmFuc2FjdGlvbgYJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAUU2V0U2NyaXB0VHJhbnNhY3Rpb24EAAAAAXQFAAAAByRtYXRjaDAEAAAAAnMxAwkAAfQAAAADCAUAAAABdAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAXQAAAAGcHJvb2ZzAAAAAAAAAAAACAUAAAABdAAAAA9zZW5kZXJQdWJsaWNLZXkAAAAAAAAAAAEAAAAAAAAAAAAEAAAAAnMyAwkAAfQAAAADCAUAAAABdAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAXQAAAAGcHJvb2ZzAAAAAAAAAAABBQAAAAtESUdJTElSQVBBWQAAAAAAAAAAAQAAAAAAAAAAAAMJAAAAAAAAAgkAAGQAAAACBQAAAAJzMQUAAAACczIAAAAAAAAAAAIGCQAAAgAAAAECAAAAF0ludGVncml0eSBDaGVjayBGYWlsZWQhAwMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAXSW52b2tlU2NyaXB0VHJhbnNhY3Rpb24GAwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABZMZWFzZUNhbmNlbFRyYW5zYWN0aW9uBgkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABBMZWFzZVRyYW5zYWN0aW9uBAAAAAF4BQAAAAckbWF0Y2gwCQAB9AAAAAMIBQAAAAJ0eAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAnR4AAAABnByb29mcwAAAAAAAAAAAAgFAAAAAnR4AAAAD3NlbmRlclB1YmxpY0tleQkBAAAACHJlY292ZXJ5AAAAADO3Etw="
        static let complexity =  1363
        static let extraFee = 400000
    }
    
    struct smartAccount {
        static let script = "base64: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BQAAAANmZWUCAAAAEyBmZWVBbW91bnQgaXMgd3JvbmcKAQAAAAlnZXRTdGF0dXMAAAABAAAAA2tleQkBAAAAC3ZhbHVlT3JFbHNlAAAAAgkABBoAAAACCQEAAAAUYWRkcmVzc0Zyb21QdWJsaWNLZXkAAAABBQAAAAtkaWdpbGlyYVBheQkAAlgAAAABBQAAAANrZXkAAAAAAAAAAAAEAAAAByRtYXRjaDAFAAAAAnR4AwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABNUcmFuc2ZlclRyYW5zYWN0aW9uBAAAAAF3BQAAAAckbWF0Y2gwBAAAAAhteVN0YXR1cwkBAAAACWdldFN0YXR1cwAAAAEICAUAAAABdwAAAAZzZW5kZXIAAAAFYnl0ZXMEAAAAD3JlY2lwaWVudFN0YXR1cwkBAAAACWdldFN0YXR1cwAAAAEICQAEJAAAAAEIBQAAAAF3AAAACXJlY2lwaWVudAAAAAVieXRlcwQAAAALYXNzZXRTdGF0dXMJAQAAAAlnZXRTdGF0dXMAAAABCQEAAAALdmFsdWVPckVsc2UAAAACCAUAAAABdwAAAAdhc3NldElkBQAAAApwcm94eVdhdmVzBAAAABFkaWdpbGlyYVJlY2lwaWVudAkAAGYAAAACBQAAAA9yZWNpcGllbnRTdGF0dXMAAAAAAAAAAAAEAAAADm15U3RhdHVzQmFubmVkCQAAAAAAAAIFAAAACG15U3RhdHVzBQAAAAZiYW5uZWQEAAAAFXJlY2lwaWVudFN0YXR1c0Jhbm5lZAkAAAAAAAACBQAAAA9yZWNpcGllbnRTdGF0dXMFAAAABmJhbm5lZAQAAAARYXNzZXRTdGF0dXNCYW5uZWQJAAAAAAAAAgUAAAALYXNzZXRTdGF0dXMFAAAABmJhbm5lZAQAAAASaXNGZWVSZWNvdmVyeVRva2VuCQAAAAAAAAIIBQAAAAF3AAAACmZlZUFzc2V0SWQFAAAADXJlY292ZXJ5VG9rZW4EAAAAEmlzUmVjaXBpZW50R2F0ZXdheQkAAAAAAAACCAUAAAABdwAAAAlyZWNpcGllbnQJAQAAABRhZGRyZXNzRnJvbVB1YmxpY0tleQAAAAEFAAAAB2dhdGV3YXkEAAAAEWlzRmVlUGF5bWVudFRva2VuCQAAAAAAAAIIBQAAAAF3AAAACmZlZUFzc2V0SWQFAAAADHBheW1lbnRUb2tlbgQAAAARaXNGZWVTcG9uc29yVG9rZW4JAAAAAAAAAggFAAAAAXcAAAAKZmVlQXNzZXRJZAUAAAAMc3BvbnNvclRva2VuBAAAABBpc0V4Y2x1c2l2ZVRva2VuCQAAAAAAAAIFAAAAD2RpZ2lsaXJhUGF5T25seQkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAEAAAAFmlzRGlnaWxpcmFQYXlFeGNsdXNpdmUJAABmAAAAAgUAAAAPZGlnaWxpcmFQYXlPbmx5CQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwAAAAAAAAAAAAQAAAAWcGVybWlzc2lvblRyYW5zZmVyVG9EUAMJAABmAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMFAAAABmJhbm5lZAkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAPcmVjaXBpZW50U3RhdHVzAAAAAAAAAAAABgkAAGYAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwUAAAAGYmFubmVkCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAhteVN0YXR1cwAAAAAAAAAAAAQAAAARcGVybWlzc2lvblBheW1lbnQDCQAAZgAAAAIFAAAACWZ1bmRCbG9jawkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAFAAAADHBheW1lbnRCbG9jawcEAAAAF3Blcm1pc3Npb25UcmFuc2Zlck5vdERQAwkAAGYAAAACBQAAAA10cmFuc2ZlckJsb2NrCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAthc3NldFN0YXR1cwAAAAAAAAAAAAYJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAALYXNzZXRTdGF0dXMAAAAAAAAAAAAFAAAAEHBheW1lbnRGdW5kQmxvY2sEAAAACmlzUmVjb3ZlcnkDAwMFAAAAEWRpZ2lsaXJhUmVjaXBpZW50BQAAABJpc0ZlZVJlY292ZXJ5VG9rZW4HBQAAABJpc1JlY2lwaWVudEdhdGV3YXkHBQAAAA5teVN0YXR1c0Jhbm5lZAcDAwUAAAAKaXNSZWNvdmVyeQkBAAAACHJlY292ZXJ5AAAAAAcGAwUAAAARZGlnaWxpcmFSZWNpcGllbnQEAAAABnByb2xvZwIAAAAjVHJhbnNmZXIgdG8gRGlnaWxpcmFQYXkgcmVjaXBpZW50OiADBQAAAA5teVN0YXR1c0Jhbm5lZAkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAgVGhpcyBhY2NvdW50IGhhcyBiZWVuIHN1c3BlbmRlZC4DBQAAABVyZWNpcGllbnRTdGF0dXNCYW5uZWQJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAJ1JlY2lwaWVudCdzIGFjY291bnQgaGFzIGJlZW4gc3VzcGVuZGVkLgMFAAAAEWFzc2V0U3RhdHVzQmFubmVkCQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAABtBc3NldCBjYW5ub3QgYmUgdHJhbnNmZXJlZC4DBQAAABZwZXJtaXNzaW9uVHJhbnNmZXJUb0RQCQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAAD1Bc3NldCBjYW5ub3QgYmUgdHJhbnNmZXJlZC4gUmVjaXBpZW50L1NlbmRlciBpcyBub3QgZWxpZ2libGUuAwUAAAAWaXNEaWdpbGlyYVBheUV4Y2x1c2l2ZQkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAXTm9uLVRyYW5zZmVyYWJsZSBUb2tlbi4DBQAAABJpc1JlY2lwaWVudEdhdGV3YXkDAwUAAAARcGVybWlzc2lvblBheW1lbnQGBQAAABBpc0V4Y2x1c2l2ZVRva2VuCQEAAAAIY2hlY2tGZWUAAAABBQAAAAF3CQAAAgAAAAEJAAEsAAAAAgUAAAAGcHJvbG9nAgAAACFBc3NldCBjYW5ub3QgYmUgdXNlZCBvbiBwYXltZW50cy4DBQAAABFpc0ZlZVBheW1lbnRUb2tlbgkAAAIAAAABCQABLAAAAAIFAAAABnByb2xvZwIAAAAdUGF5bWVudCBUb2tlbiBjYW5ub3QgYmUgdXNlZC4JAQAAAAhjaGVja0ZlZQAAAAEFAAAAAXcEAAAABnByb2xvZwIAAAAnVHJhbnNmZXIgdG8gbm90IERpZ2lsaXJhUGF5IHJlY2lwaWVudDogAwUAAAARaXNGZWVQYXltZW50VG9rZW4JAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAHVBheW1lbnQgVG9rZW4gY2Fubm90IGJlIHVzZWQuAwUAAAAObXlTdGF0dXNCYW5uZWQJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAIFRoaXMgYWNjb3VudCBoYXMgYmVlbiBzdXNwZW5kZWQuAwUAAAAXcGVybWlzc2lvblRyYW5zZmVyTm90RFAJAAACAAAAAQkAASwAAAACBQAAAAZwcm9sb2cCAAAAIFRoaXMgYXNzZXQgY2Fubm90IGJlIHRyYW5zZmVyZWQuCQAB9AAAAAMIBQAAAAJ0eAAAAAlib2R5Qnl0ZXMJAAGRAAAAAggFAAAAAnR4AAAABnByb29mcwAAAAAAAAAAAAgFAAAAAnR4AAAAD3NlbmRlclB1YmxpY0tleQMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAF0ludm9rZVNjcmlwdFRyYW5zYWN0aW9uBgMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAPRGF0YVRyYW5zYWN0aW9uBgkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABRTZXRTY3JpcHRUcmFuc2FjdGlvbgQAAAABdAUAAAAHJG1hdGNoMAQAAAACczEDCQAB9AAAAAMIBQAAAAF0AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAABdAAAAAZwcm9vZnMAAAAAAAAAAAAIBQAAAAF0AAAAD3NlbmRlclB1YmxpY0tleQAAAAAAAAAAAQAAAAAAAAAAAAQAAAACczIDCQAB9AAAAAMIBQAAAAF0AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAABdAAAAAZwcm9vZnMAAAAAAAAAAAEFAAAAC2RpZ2lsaXJhUGF5AAAAAAAAAAABAAAAAAAAAAAAAwkAAAAAAAACCQAAZAAAAAIFAAAAAnMxBQAAAAJzMgAAAAAAAAAAAgYJAAACAAAAAQIAAAAXSW50ZWdyaXR5IENoZWNrIEZhaWxlZCEDAwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABdJbnZva2VTY3JpcHRUcmFuc2FjdGlvbgYDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAFkxlYXNlQ2FuY2VsVHJhbnNhY3Rpb24GCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAEExlYXNlVHJhbnNhY3Rpb24EAAAAAXgFAAAAByRtYXRjaDAJAAH0AAAAAwgFAAAAAnR4AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAACdHgAAAAGcHJvb2ZzAAAAAAAAAAAACAUAAAACdHgAAAAPc2VuZGVyUHVibGljS2V5CQEAAAAIcmVjb3ZlcnkAAAAANjiyjw=="
        static let complexity =  1363
        static let extraFee = 400000
        
    }
    
    struct legalView {
        static let text = """
        Üye olmanız halinde DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ  ('DigiliraPay'), ad soyad, elektronik posta, cep telefonu, cinsiyet (isteğe bağlı) ve doğum tarihine ait kişisel verilerinizi ve üyeliğiniz sırasında gerçekleştireceğiniz işlemler neticesinde paylaşacağınız Kişisel Verilerin İşlenmesi ve Korunması Politikası'nda ('Politika') belirtilen diğer verilerinizi (2.A. Maddesi); başta üyelik işlemlerinin gerçekleştirilmesi, sorun ve şikâyetlerinizin çözümlenmesi, ticari elektronik ileti onayınızı vermişseniz hizmetlerimize ilişkin haberlere, bilgilere ve güncellemelere, tekliflerimize ve özel etkinliklerle ilgili ve ilginizi çekebilecek diğer pazarlama iletişimlerini gönderme amaçları olmak üzere Politika'da yer alan diğer amaçlar (2.B. Maddesi) için işleyecektir. Kişisel verileriniz; iş geliştirme hizmetlerinin sağlanması, istatistiksel ve teknik hizmetlerin temini ve müşteri ilişkilerinin yürütülmesi, arşivleme ve depolama amacıyla yurt dışında bulunan bilişim teknolojileri desteği alınan sunucular, hosting şirketleri, bulut bilişim gibi elektronik ortamlara aktarılması için ve Politikada yer alan Kişisel Verilerin Yurt dışına Aktarılması (5.B. Maddesi) başlığı kapsamında diğer veri ve amaçlar uyarınca yurt dışındaki iş ortaklarımızla paylaşılacaktır. KVK Kanunu'nun 11.maddesi ve ilgili mevzuat uyarınca; Şirket’e başvurarak kendinizle ilgili; kişisel veri işlenip işlenmediğini öğrenme ve Politika’da yer alan Veri Sahibinin Haklarının Gözetilmesi (8. Madde) kapsamında diğer haklarınızı ve DigiliraPay’e başvuru yollarınızı öğrenebilirsiniz. Detaylı bilgiye Kişisel Verilerin İşlenmesi ve Korunması Politikası'ndan ulaşabilirsiniz.
        """
        static let version = 4
    }
    
    struct termsOfUse {

        static let text =
"""
1. BAŞLANGIÇ
DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ’ne ait www.digilirapay.com adresi veya Android işletim sistemi ile IOS işletim sistemi üzerinden hizmete sunulan mobil uygulamalar üzerinden kayıt yaptırmak ve üye olmakla işbu Kullanım Şartları Ve Üyelik Sözleşmesi’nin tüm hükümleri ile her maddesini ve eklerini okuyarak, her maddede ayrı ayrı mutabık kaldığınızı kabul, beyan ve taahhüt etmiş olursunuz. Bu nedenle tüm koşulları lütfen dikkatlice okuyunuz.
DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ’NİN SUNMAKTA OLDUĞU HİZMET, SERVİS VE ÜRÜNLERDEN HERHANGİ BİRİNİ VEYA BİRKAÇINI KULLANARAK;

•    KRİPTO PARA İŞLEMLERİ İLE İLGİLİ YETERLİ BİLGİ SAHİBİ VE İŞLEM RİSKLERİNİN FARKINDA OLDUĞUNUZU,
•    KRİPTO PARA İŞLEMLERİNİ GERÇEKLEŞTİRİRKEN VE DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ HİZMET, SERVİS VE ÜRÜNLERİNİ KULLANIRKEN TÜM RİSKLERİN SİZE AİT OLDUĞUNU,
•    DIGILIRAPAY TEKONOLOJİ ANONİM ŞİRKETİ’NİN KRİPTO PARALARLA GERÇEKLEŞTİRECEĞİNİZ İŞLEMLERDEKİ RİSKLERDEN VE İŞLEM NETİCESİNDE KARŞILAŞABİLECEĞİNİZ OLUMSUZ SONUÇLARDAN SORUMLU TUTULAMAYACAĞINI

KABUL ETMİŞ OLURSUNUZ.

Bu sözleşmede geçen terimler ve tanımlar Madde 3’te açıklanmış olup sözleşmede özellikle farklı bir şekilde belirtilmedikçe anlamları Madde 3’te belirtildiği şekildedir.


2.TARAFLAR
İşbu Kullanım Şartları ve Üyelik Sözleşmesi (bundan sonra "Sözleşme" olarak anılacaktır);
Bir tarafta;
Unvanı    : DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ (Bundan sonra
“DigiliraPay” olarak anılacaktır)
Mersis No    : 0295103678200001
Adres        : Yeşiltepe Mah. İsmet İnönü-2 Cad. 57 Apt. No:2 Anadolu Üniversitesi ATAP
Tepebaşı/ESKİŞEHİR
E-Posta    : destek@digilirapay.com
KEP        :

ile diğer taraftan DigiliraPay hizmet, ürün ve servislerini temin etmek üzere işbu sözleşmeyi onaylamış kullanıcı (bundan böyle “Kullanıcı” olarak anılacaktır) tarafından akdedilmiştir.
DigiliraPay ve Kullanıcı işbu Sözleşme’nin devamında ayrı ayrı “Taraf” ve birlikte “Taraflar” olarak anılmışlardır.

3. TANIMLAR
Sözleşme içerisinde kullanılan;
DigiliraPay: DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ’ni ifade eder. DigiliraPay, bir ödeme kuruluşu veya elektronik para kuruluşu değildir. DigiliraPay, Kullanıcılarının kripto paralarını güvenle saklayabileceği, transfer edebileceği ve DigiliraPay üyesi iş yerlerinden mal ve hizmet satın almakta kullanmak üzere itibari paraya dönüştüren teknolojik yazılım alt yapı hizmeti sunmaktadır.
Kullanıcı: www.digilirapay.com sayfasında ve mobil uygulamada yer alan Kullanım Şartları ve Üyelik Sözleşmesini, kullanım koşulları ve gizlilik bildirimlerini kabul ederek ve bunlara yasal olarak bağlı kalmayı taahhüt ederek “Kullanıcı” sıfatını kazanan kişileri ifade eder.
Platform: www.digilirapay.com alan adından ve bu alan adına bağlı alt alan adlarından oluşan internet sitesini ve yine DigiliraPay’e ait Android işletim sistemi ile IOS işletim sistemi üzerinden hizmete sunulan mobil uygulamaları ifade eder.
Blokzincir: Bloklar üzerinde verilerin değiştirilemez bir şekilde saklanmış olduğu, devamlı büyüyen merkeziyetsiz veri tabanını ifade eder. Verilerin ve işlemlerin yer aldığı şifrelenmiş veri kümesi olan “blok” ile bu blokların kendisinden hemen önceki bloklara şifrelenmiş imzalar yoluyla bir araya gelmesini ifade eden “zincir” ifadelerinin birleştirilmesi ile ortaya çıkmıştır.
Kripto Para: Merkezi otoritelerce kabul gören ödeme araçlarına eşler arası bir alternatif olarak ortaya çıkan ve bir değişim aracı olarak kullanılabilen, kriptografik mekanizması ile güvence altına alınmış dijital ortamdaki bir değerin temsilini ifade eder.
İtibari Para: İtibari para, hükûmet kararına dayalı çıkartılan, altın, gümüş vs. karşılığı olmayan, altında imzası olan yere ve düzenlediği kağıdın taklit edilemeyeceğine güven üzerine kurulmuş, mal ve hizmet alışverişi için kullanılan banka kağıdı veya kâğıt parayı ifade eder.
Jeton (Token): Blokzincir teknolojisinin kripto paralar haricinde bir diğer uygulama örneği olarak ortaya çıkmıştır. Mevcut bir blokzincir üzerinde bir proje ekosistemi içerisinde belli bir değer ve faydayı temsil eden dijital kripto varlıkları ifade eder.
Akıllı Jeton (Smart Token):  Blokzincir ağı üzerinde yer alan jetanların hareket kabiliyetleri ve kullanım koşullarının güvenli bir bilgisayar ağı tarafından doğrulandığı ve merkezi olmayan jetonları ifade eder.
Sponsorlu Jeton (Sponsored Token): DigiliraPay Kullanıcılarının sahip oldukları kripto para ve jetonları diğer DigiliraPay kullanıcılarına gönderebilmeleri ve alışverişlerinde kullanabilmeleri amacıyla DigiliraPay tarafından oluşturuşmuş, blokzincir işlem ücreti yerine geçen jetondur. Sponsorlu jetonlar DigiliraPay tarafından Kullanıcılarına ücretsiz olarak gönderilir. DigiliraPay, sponsorlu jetonların ücretlendirilmesi konusunda tek taraflı olarak değişiklik yapma hakkını saklı tutar.
Protokol: Bir ağdaki etkileşimleri tanımlayan genellikle fikir birliği, işlem doğrulaması ve ağa katılım şartlarını içeren kurallar bütünüdür.
Neutrino: Algoritmik Stabil Kripto Para Protokolüdür. Fiyatı çeşitli algoritmalarla sabit tutulan ve Waves Blokzinciri’nin kripto parası olan Waves ile teminatlandırılan kripto para prokolüdür.
Kripto Para Cüzdanı: Kripto paraları depolamak için kullanılan, gizli anahtarları saklayan cüzdan oluşumunu ifade eder. Masaüstü, yazılım, donanım ve kağıt gibi farklı çeşitleri vardır.
DigiliraPay Akıllı Cüzdan: DigiliraPay tarafından geliştirilmiş ve cüzdana ait gizli anahtarların ve buna ait tüm yetkilerin cüzdan sahibi Kullanıcı’da olduğu ancak çeşitli güvenlik ve yasal düzenlemelerle uyumlu olacak şekilde Kullanıcı’nın gizli anahtarlarına erişimini kaybetmesi, başka birinin eline geçtiğinden şüphelenmesi gibi cüzdanına ulaşamadığı durumlarda işbu sözleşme ile belirlenmiş koşullar altında uzaktan müdahale edilerek kripto paraların ve jetonların kaybını önlemek amacıyla üretilmiş kripto para cüzdanını ifade eder.
Anahtar Kelime (Seed): Kripto para cüzdanlarının kripto para adreslerini üretirken kullandığı 2048 kelime arasından rastgele seçilen 15 kelimeden oluşturulan özel anahtarı ve cüzdanın başlangıç noktasını ifade eder. Anahtar kelimeleri güvenli bir şekilde muhafaza etmek tamamen Kullanıcı’nın sorumluluğundadır.
Adres (Address): Cüzdana kripto para göndermek ve almak üzere herkese açık bir şekilde kullanılan, alfa numerik karakterlerden oluşa, paylaşımında herhangi bir güvenlik riski bulunmayan, Kullanıcı’nın blokzincir adresini tanımlayıcı nitelikteki kod kümesidir.
Özel Anahtar (Private Key): Kripto para cüzdanında yer alan kripto paraların ve jetonların kullanılabilmesi için ihtiyaç duyulan ve aynı zamanda kripto para adreslerinin sahipliğini garanti altına alan gizli, kişiye özel anahtarları ifade eder. Blokzincir işlemleri bu özel anahtar ile imzalanır ve şifrelenerek blokzincir ağına gönderilir.
PİN Kodu: DigiliraPay akıllı cüzdanına giriş yapmak, kripto para veya jeton transferi yapmak ve ödeme yapmak için sadece Kullanıcı’nın bilebildiği dört basamaklı rakamları ifade eder. Kullanıcı PİN Kodu yerine parmak izi okuyucu veya yüz tanıma sistemlerini kullanabilir. PİN Kodu yerine kullanılan bu sistemler de PİN Kodu ile eşdeğerdir. Pin Kodu’nun beş (5) defa hatalı girilmesi halinde akıllı cüzdan erişime kapatılır ve akıllı cüzdanın tekrar erişime açılması koşulları işbu Sözleşme’nin devamında düzenlenmiştir.
Akıllı Sözleşme: Blokzincir ağı üzerinde yer alan veriler üzerinde sınırları önceden belirlenen bir akış içersinde işlem yapılmasını sağlayan ve güvenli bir bilgisayar ağı tarafından doğrulanan, merkeziyetsiz yazılım platformunu ifade eder.
Ağ Geçidi (Gateway): Blokzincirin bağlı olduğu veri transfer ağı ile işlem yapılmak istenen blokzincir ağının farklı olması durumunda işleyen, farklı blokzincirleri arasında işlem yapılmasına imkan sağlayan merkezi veya merkezi olmayan yapıları ifade eder. DigiliraPay’in kullanmakta olduğu blokzinciri üzerindeki ağ geçitleri üçüncü taraf hizmet sağlayıcı Waves (WX Developmen Ltd) tarafından işletilmektedir.
İşlem (Transaction): Bir blokzinciri üzerinde kripto paralar veya jetonlar kullanılarak gerçekleştirilen herhangi bir hareketi ifade eder.
Ödeme: Bir mal ve/veya hizmeti satın almak için DigiliraPay akıllı cüzdanlarındaki kripto para ve jetonların kullanılması işlemini ifade eder. DigiliraPay, kendisince geliştirilen ve kendisine ait olan teknolojik alt yapı hizmeti sağlayarak kripto paralar veya jetonlarla yapılan ödemeyi itibari paraya çevirmektedir.
Kullanıcı: DigiliraPay ile işbu sözleşmeyi akdetmiş olan gerçek kişi Platform kullanıcısını ifade eder.
Üye İş Yeri/Satıcı: DigiliraPay ile akdetmiş olduğu sözleşmeler uyarınca DigiliraPay’in sağladığı hizmet ve teknolojik imkanları kullanarak DigiliraPay Kullanıcılar’ına mal ve/veya hizmet satan gerçek veya tüzel kişileri ifade eder.
Merkeziyetsiz Finans: Blokzincir ağları üzerinde kurulu, herhangi bir merkezi otorite tarafından kontrol edilmeyen finansal uygulamalar bütünüdür.
Hesap Bilgileri Sayfası: Kullanıcı’nın Platform’da yer alan çeşitli uygulamalardan ve Hizmetler’den yararlanabilmesi için gerekli işlemleri gerçekleştirebildiği, kişisel verilerini ve uygulama bazında kendisinden talep edilen bilgilerini girdiği, sadece ilgili Kullanıcı’ya ait mobil uygulama PİN kodu, parmak izi veya yüz tanıma sistemleri ile erişilebilen Kullanıcı’ya özel sayfayı ifade eder.
Hizmetler: Kullanıcılar’ın işbu Kullanım Şartları Sözleşmesi içerisinde tanımlı olan iş ve işlemleri gerçekleştirmelerini sağlamak amacıyla DigiliraPay tarafından ortaya konulan uygulamaları ifade eder.
KVKK: 6698 Sayılı Kişisel Verilerin Korunması Kanunu’nu ifade eder.
Kişisel Verilerin İşlenmesi ve Korunması Politikası: Kullanıcılar’ın Platform üzerinden ilettikleri kişisel verilerin, DigiliraPay tarafından hangi amaçlarla ve ne şekilde kullanılacağı gibi konular da dahil olmak üzere DigiliraPay’in kişisel verilere ve çerez kullanımına ilişkin genel gizlilik politikasını düzenleyen ve DigiliraPay’e ait platform üzerinden erişilebilecek olan metni ifade eder.
Ziyaretçi: www.digilirapay.com sayfasını ve mobil uygulamaları Kullanıcı olmaksızın ziyaret eden kişileri ifade eder.

4. KONU
İşbu sözleşme, Kullanıcı'nın DigiliraPay’in sunduğu ürün, servis ve hizmetlerden yararlanmasına ilişkin DigiliraPay ve Kullanıcı arasındaki karşılıklı hak ve yükümlülüklerin düzenlenmesi amacıyla akdedilmiştir.

5. DigiliraPay HİZMETLERİNE İLİŞKİN ESASLAR VE SÜREÇLER
5.1. Kullanıcı, DigiliraPay ürün, servis ve hizmetlerinden, aşağıda belirtilen süreçleri tamamlayarak DigiliraPay nezdinde oluşturulacak kullanıcı hesabı ve kendisine tahsis edilecek akıllı cüzdan vasıtasıyla yararlanabilecektir.
5.2. Kullanıcı, Platform üzerinden üyelik ve hesap başvurusunu DigiliraPay’e iletir. DigiliraPay tarafından talep edilen bilgi ve belgelerin Kullanıcı tarafından DigiliraPay ile paylaşılması zorunludur. DigiliraPay, Kullanıcı’nın üyelik kaydı oluşturulması ve hesap açılışı sırasında müşteriyi tanıma ilkesi çerçevesinde Kullanıcı’dan T.C. Kimlik Numarası, ad-soyad, adres, banka hesap numarası bilgileri ve IBAN, fotoğraf ve/veya kimlik doğrulamaya yarar selfie fotoğrafını talep etme hakkına sahiptir. DigiliraPay, sunmakta olduğu ürün, servis ve hizmetin niteliği ve gereklerine bağlı olarak Kullanıcı’dan ilgili yasal düzenlemelere göre bu maddede sayılanlar dışında bilgi ve belge talep etme ve bunların ulaştırılacağı kanalları münhasıran belirleme hakkına sahiptir.
5.3. Kullanıcı statüsünün kazanılması için, Kullanıcı olmak isteyen kişinin, Platform’da bulunan işbu Üyelik Sözleşmesi ve Kullanım Şartları’nı okuyarak ve onaylayarak, burada talep edilen bilgileri doğru ve güncel bilgilerle doldurması, üyelik başvurusunun DigiliraPay tarafından değerlendirilerek onaylanması gerekmektedir. DigiliraPay, tamamen kendi takdirine bağlı olarak Kullanıcı olmak isteyen kişinin talebini reddedebilir. Üyelik başvurusunun onaylanma işleminin tamamlanması ve Kullanıcı'ya bildirilmesi ile Kullanıcı statüsü başlamakta, işbu Sözleşme Taraflar için bağlayıcı olmakta ve böylece Taraflar işbu Sözleşme’de ve Platform’un ilgili yerlerinde belirtilen karşılıklı hak ve yükümlülüklere kavuşmaktadır.
Kullanıcı, Platform’da yer alan herhangi bir hizmet, servis veya ürüne erişmekle veya kullanmakla kabul etmiş olduğu işbu Sözleşme ile birlikte işbu Sözleşme’nin eklerini de Sözleşme’nin ayrılmaz birer parçası olarak kabul etmiş olmaktadır.
5.4. DigiliraPay’e ait Platform’da yer alan ve işbu Sözleşme ile kullanıma sunulan her türlü hizmetten faydalanmak isteyen gerçek kişi olan Kullanıcı, Platform’u kullanabilmesi için 12 yaşından büyük ve işbu Sözleşme’yi kabul etmeye ehil olduğunu kabul, beyan ve taahhüt eder. Kullanıcı’nın bu bilgileri hatalı vermesi nedeniyle doğacak tüm zararlardan mesuliyet Kullanıcı’ya aittir. Kullanıcı, üyelik statüsünü her zaman sonlandırabilme hakkına sahiptir. Üyelik iptalinin gerçekleştirilmesi, ticari elektronik ileti gönderimi için verilen onayın da iptali anlamına gelmemektedir. Kullanıcı’nın, ayrıca ve özellikle elektronik ileti gönderim onayını da geri alması gerekmektedir.
DigiliraPay, kullanıcının hatalı ve/veya yanlış bilgi verdiğini tespit ettiği takdirde, Sözleşmeyi tek taraflı feshederek kullanıcıya ait hesabı, hiçbir bildirimde bulunmaksızın iptal etme, durdurma veya askıya alma ve bu kişiye bundan sonra hesap açmama keyfiyetine haizdir. Bu nedenlerden dolayı doğacak hiçbir zarardan DigiliraPay sorumlu olmayacaktır.
5.5. Kullanıcı statüsünün kazanılması ile DigiliraPay tarafından Kullanıcı’ya bir akıllı cüzdan tanımlanır. Kullanıcı, aynı anda sadece tek bir hesaba ve tek bir akıllı cüzdana sahip olabilir.
Bu cüzdana erişim için gerekli olan anahtar kelimeler DigiliraPay tarafından kullanılmakta olan yazılım tarafından otomatik olarak 2048 kelime arasından rastgele bir biçimde Kullanıcı’nın mobil aygıtında oluşturulmakta ve Kullanıcı’ya gösterilmektedir. Anahtar kelimeler DigiliraPay tarafından bilinmediği gibi kaydı da tutulmamaktadır. İki farklı akıllı cüzdanın anahtar kelimelerinin aynı kelimelerle aynı sıralamada olması ihtimali 44425310812058346861010566579703617613415841792000’da birdir. KULLANICI, AKILLI CÜZDANINA ERİŞİM İÇİN GEREKLİ OLAN ANAHTAR KELİMELERİ MUHAFAZA ETMEK VE ÜÇÜNCÜ KİŞİLERLE PAYLAŞMAMAKLA YÜKÜMLÜDÜR.
Anahtar kelimelerin kaybedilmesi veya anahtar kelimelerinin başka birisinin eline geçtiğinden şüphelenmesi halinde Kullanıcı, akıllı cüzdanına erişimin engellenmesini için destek@digilirapay.com adresine DigiliraPay’de kayıtlı e-posta adresinden yapacağı bildirim ile talepte bulunur. DigiliraPay, bu talebi 72 saati aşmayacak şekilde değerlendirmeye alarak akıllı cüzdana erişimi engeller. Bu süreç zarfında doğabilecek her türlü zarar ve kayıptan DigiliraPay’in sorumluluğu bulunmamaktadır. Kullanıcı böyle bir zarara uğraması ihtimaline binaen DigiliraPay’i peşinen gayri kabili rücu İBRA ETMİŞTİR.
Kullanıcı, bildirimi üzerine erişime kapatılan akıllı cüzdandaki kripto paralarının Kullanıcı’nın kendisi adına yeni oluşturulacak bir akıllı cüzdana aktarılmasını talep edebilir. Bu talep bildirimi mutlak suretle Kullanıcı’nın bizzat kendisi veya yasal temsilcisi tarafından Noter kanalı ile gönderilmiş bir bildirim olmak zorundadır. Kullanıcı, bu bildirimi yapmanın yanı sıra kimliğinin ön yüzü fotoğrafını, sisteme kayıtlı telefon numarasını, e-devlet üzerinden alınmış güncel ikamet belgesini, dilekçeli selfie fotoğrafını Destek kanalları üzerinden DigiliraPay’e ulaştırmalı ve işbu sözleşmenin ayrılmaz eki niteliğindeki Ücret ve Komisyonlar Tablosu’na göre ödemesi gereken ücreti “Destek” sayfasında ilan edilen kanaldan ödediğine dair tevsik edici dekontu destek@digilirapay.com e-posta adresine göndermelidir. Kullanıcı’nın Noter kanalı ile yaptığı bildirimin DigiliraPay’e ulaşması sonrasında talep edilen belgeleri göndermiş olduğu ve Ücret ve Komisyonlar Tablosu’na göre yapmış olduğu ödeme teyit edilir ve Kullanıcı kendisine yeni bir akıllı cüzdan tanımlar ve erişilemeyen önceki akıllı cüzdanda bulunan bakiyesinin tamamı yeni akıllı cüzdanının oluşturulmasını takip eden 60 gün içerisinde yeni akıllı cüzdanına aktarılır. Bu süreçte meydana gelebilecek herhangi bir kripto para kur farkı, kripto para ve/veya itibari para kaybından  DigiliraPay sorumlu değildir. Kullanıcı, bu süreçte meydana gelebilecek her türlü zararından DigiliraPay’i gayri kabili rücu İBRA EDER.
5.6. Kullanıcı, kendisine tanımlanan akıllı cüzdanında muhafaza ettiği kripto paraları ile DigiliraPay üyesi olan iş yeri ve satıcılardan alışveriş yapabilir, DigiliraPay üyesi diğer Kullanıcılar ile arasında kripto para gönderimi ve alımı yapabilir, DigiliraPay üyesi olmayan kişilere kripto para gönderebilir ve bu kişilerden kripto para alabilir, kripto para borsalarına para gönderebilir ve kripto para borsalarından kripto para çekebilir. Tüm bu işlemler için belirlenmiş olan komisyon ve ücretler işbu sözleşmenin ayrılmaz eki niteliğindeki Ücret ve Komsiyonlar Tablosu’nda ilan edilmektedir.  DigiliraPay önceden duyurmak kaydı ile her zaman ücret ve komisyonlarda tek taraflı değişiklik yapma hakkına sahiptir. Ücret ve Komisyonlar Tablosu’nda yapılan ve duyurulan değişiklik sonrasında Kullanıcı, akıllı cüzdanından yapmış olduğu ilk işlem ile Ücret ve Komisyonlar Tablosu’nda yapılan değişikliği kabul etmiş sayılacağını peşinen kabul, beyan taahhüt eder. DigiliraPay, Kullanıcı tarafından blokzincir işlemi onaylanmadan önce Kullanıcı’ya işlem ücret ve/veya komisyonunu hesaplamakta ve uygulama üzerinde göstermektedir. Kullanıcı, blokzincir işlemini onaylamakla bu komisyon ve/veya ücreti de kabul ettiğini onaylamaktadır.
Profil onayını tamamlayan Kullanıcılar, birbirleri arasında kripto para transferi yapabilir, DigiliraPay üyesi olan işyerlerinde 750,00 Türk Lirası’na kadar alışveriş yapabilirler. DigiliraPay üyesi işyerlerinde bu limit üzerinde alışveriş yapabilmek için Kullanıcı’nın “Destek” sayfasında veya mobil uygulama içerisindeki “ayarlar” sayfasında belirtilen 2. Seviye Kimlik Doğrulama Prosedürlerini tamamlamış olması gerekmektedir.
5.7. Kullanıcı, kendisine tanımlanan akıllı cüzdanından DigiliraPay üyesi olmayan ve Waves Blokzinciri üzerinde olmayan bir adrese kripto para gönderirken veya böyle bir adresten kripto para alırken WX Development Ltd. tarafından işletilen üçüncü taraf ağ geçidini kullanarak hizmet almakta ve işlem yapmakta olduğunu, üçüncü taraf bu ağ geçidi hizmet sağlayıcıları tarafından verilen hizmetin DigiliraPay’in sorumluluğunda ve denetiminde olmadığını, üçüncü taraf bu ağ geçitleri tarafından verilen hizmetler karşılığı alınan ücret ve komisyonların DigiliraPay tarafından belirlenmediğini ve tahsil edilmediğini ve doğrudan üçüncü taraf ağ geçitleri tarafından belirlenerek tahsil edildiğini, DigiliraPay’in buradan herhangi bir gelir, kazanç ve fayda elde etmediğini, üçüncü taraf bu ağ geçitleri tarafından verilen hizmetler sırasında ortaya çıkabilecek her türlü zararın DigiliraPay’in sorumluluğu dışında Kullanıcı’nın kendisinin ve üçüncü taraf ağ geçidi hizmet sağlayıcısının sorumluluğunda olduğunu peşinen kabul eder.
DigiliraPay, üçüncü taraf ağ geçitlerinin kullanılması sırasında ortaya çıkabilecek sorunların çözülmesi ile ilgili olarak Kullanıcı’ya sadece Kullanıcı’nın üçüncü taraf ağ geçidi kullanarak gerçekleştirdiği işleme ilişkin olarak DigiliraPay’in takip edebildiği ve ulaşabildiği kadarıyla işlem kayıtlarını üçüncü taraf ağ geçidi hizmet sağlayıcısına ulaştırma desteği vereceğini taahhüt etmektedir. DigiliraPay tarafından üçüncü taraf ağ geçidi hizmet sağlayıcısına ulaştırılan işlem bilgilerinin üçüncü taraf ağ geçidi işlem sağlayıcısı tarafından kabul edilmemesi veya dikkate alınmaması herhangi bir şekilde DigiliraPay’in üçüncü taraf ağ geçidinden kaynaklı zararı tazmin sorumluluğunu doğurmamaktadır.
Kullanıcı, işbu sözleşmeyi akdetmekle üçüncü taraf ağ geçidi hizmet sağlayıcısı tarafından kendisine sunulan hizmet esnasında hizmetin geç gerçekleştirilmesi, eksik gerçekleştirilmesi veya hiç gerçekleştirilmemesi halinde ortaya çıkabilecek her türlü zarardan ve üçüncü taraf ağ geçidi hizmet sağlayıcısı tarafından bu zararların  giderilmemesinden dolayı DigiliraPay’i sorumlu tutmayacağını ve ortaya çıkabilecek bu zararlardan DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul ve beyan eder.
5.8. Kullanıcı, akıllı cüzdanında bulunan bir kripto para birimini kullanarak sadece DigiliraPay üyesi bir iş yerinden alışveriş yapabilir. Bu alışveriş esnasında üye iş yerinin itibari para olarak bedelini belirlediği ve Kullanıcı’ya satmakta olduğu mal ve/veya hizmetin kripto para karşılığı o anki güncel kur üzerinden hesap edilmekte ve Kullanıcı’nın akıllı cüzdanındaki ödeme sayfasında hesaplama baremleri gösterilmektedir. Kullanıcı, akıllı cüzdanında bulunan kripto para varlıklarını kullanarak DigiliraPay üyesi bir iş yerinden alışveriş yapmakla DigiliraPay’in o anki güncel kur üzerinden kripto para-itibari para çevirme işlemini yapmasına gayri kabili rücu onay vermiş olmaktadır. DigiliraPay, Kullanıcı’ya volatiliteden (oynaklıktan) en az etkileneceği şekilde hizmet vermeyi amaçlamaktadır. Kullanıcı’nın DigiliraPay üyesi bir iş yerinde yapacağı bir harcama esnasında ve sonrasında kripto para kurunda gerçekleşen aşağı ya da yukarı yönlü değişiklikler nedeniyle Kullanıcı’nın DigiliraPay’den herhangi bir iade veya fark ödenmesi talebinde bulunma hakkı yoktur. Kullanıcı’nın akıllı cüzdanında bulunan kripto para ile DigiliraPay üyesi bir iş yerinde yapacağı bir harcamayı kripto paralardaki volatiliteyi peşinen kabul ederek yapmış olduğu esastır. Kullanıcı, kripto para kurundaki volatiliteden kaynaklı olarak ortaya çıkması muhtemel tüm zararlarından DigiliraPay’i gayri kabili rücu olarak İBRA ETMEKTEDİR.
5.9. Kullanıcı’nın DigiliraPay üyesi bir iş yerinden satın almış olduğu mal ve/veya hizmeti Tüketici Hukuku mevzuatı kapsamında iade etmesi halinde Kullanıcı’ya yapılacak bedel iadesi, Kullanıcı’nın harcamayı yaptığı kur üzerinden Türk Lirası jeton olarak akıllı cüzdanına gönderilecektir. Kullanıcı, DigiliraPay üyesi iş yerinde yaptığı harcama iadesinin kripto para olarak yapılmayacağını ve harcama tarihindeki kur üzerinden Türk Lirası cinsinden yapılacağını peşinen kabul eder. Kullanıcı harcama iadesi talep ettiğinde DigiliraPay üyesi iş yerinde yapmış olduğu harcama sonrasında kripto para kurunda yaşanacak kur artışından kaynaklı olarak DigiliraPay’den herhangi bir kur farkı, kripto para ve/veya itibari para kaybı tazmini talep etmeyeceğini peşinen kabul ve taahhüt ederek bu hususlarda DigiliraPay’i gayri kabili rücu olarak İBRA EDER. Kullanıcı’ya yapılacak bedel iadesi süreci, Kullanıcı’nın alışveriş yaptığı DigiliraPay üyesi işyeri tarafından iade sürecinin başlatıldığının ve onaylandığının DigiliraPay’e iletilmesiyle başlar.
DigiliraPay, üyesi olarak sözleşme akdettiği işyerlerini kendisinden beklenen azami dikkat ve özeni göstererek belirlemektedir. Ancak DigiliraPay üyesi bir işyerinin kendisinden ve dışsal bir etkenden kaynaklanan nedenlerle Kullanıcı’ya satın almış olduğu mal ve/veya hizmeti ulaştırmakta gecikmesi veya ulaştırmaması halinde Kullanıcı, doğan hukuki ihtilafın tarafının sadece alışveriş yaptığı DigiliraPay üyesi işyeri olduğunu, ihtilaftan kaynaklı her türlü zararının tazminini sadece alışveriş yaptığı DigiliraPay üyesi işyerinden talep edebileceğini, bu konularda DigiliraPay’in herhangi bir hukuki ve mali sorumluluğu bulunmadığını ve bu şekilde doğacak zararlarından DigiliraPay’i peşinen İBRA ETMİŞ olduğunu gayri kabili rücu kabul, beyan ve taahhüt eder.

6. TARAFLARIN HAK VE YÜKÜMLÜLÜKLERİ
6.1 Platform’da sunulan hizmete bağlı tüm servislerin, alan adlarının, yazılım kodlarının, ara yüzlerinin, içeriklerinin, ürünlerin, videolarının, algoritmalarının, çizimlerinin, modellerinin, tasarımlarının, telif haklarının ve bunlarla sınırlı olmamak üzere diğer tüm fikri ve sınai hakların sahibi münhasıran DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ’dir  (üçüncü kişilerden sağlanan içerik ve uygulamalar hariçtir). DigiliraPay, anılan bu servislerin, ürünlerin ve hizmetlerin, bununla bağlantılı sayfaların kopyalanmasına, çoğaltılmasına ve yayılmasına, ters mühendislik işlemlerine tabi tutulmasına izin verMEmektedir. Kullanıcı, bu hükümlere aykırı hareket etmeyeceğini kabul, beyan ve taahhüt eder. Kullanıcı’nın veya Kullanıcı ile doğrudan ya da dolaylı olarak ilişkilendirilen kişi ya da kişilerin bu hükümlere aykırı davranması, sözleşmenin tek taraflı ve haklı feshi nedeni olup tüm hukuki ve cezai sorumluluk Kullanıcı’ya aittir. DigiliraPay, bu kişiye ya da kişilere bundan sonra hesap açmama keyfiyetine haizdir.
6.2. Üye olurken verilen bilgilerin doğruluğundan ve gizliliğinden, üye olurken kullanılan şifre ve kullanıcı adının, akıllı cüzdana erişim için verilen anahtar kelimelerin ve akıllı cüzdana giriş için kendisince oluşturulan PİN kodunun üyelik süresince korunmasından, üçüncü kişiler ile paylaşılmamasından ya da üçüncü kişiler tarafından her ne suretle olursa olsun ele geçirilmesinden Kullanıcı sorumludur. Diğer taraftan, DigiliraPay’e ait ya da internet yer sağlayıcısı şirketin sistemlerinden kaynaklı olarak ya da herhangi bir sebeple Kullanıcı’nın hesaplarında veya DigiliraPay sistemlerinde meydana gelecek siber saldırı ve her türlü hırsızlık suçlarından dolayı da DigiliraPay’in sorumluluğuna gidilemez. Kullanıcı bu hususlarda doğacak zararlar için DigiliraPay’den hiçbir ad altında talepte bulunmayacağını, bu doğrultuda DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.3. Kullanıcı, hesabını ve haklarını üçüncü şahıslara devredemez, satamaz, bağışlayamaz ve her ne ad altında olursa olsun kullandıramaz. Ancak kullanıcının ya da tayin ettiği vekilin, usulüne uygun olarak Noterlik makamı tarafından düzenlenen ve DigiliraPay’de bulunan hesabını kullandırtmaya dair yetkileri açıkça içeren özel yetkili bir vekaletnameyi DigiliraPay’e ibraz etmeleri şartıyla vekaletname ile kendisini temsil eden kişinin, kullanıcının hesabını tüm hukuki ve cezai sorumluluklar kendisine ve Kullanıcı’ya ait olmak üzere kullanmasına DigiliraPay tarafından izin verilebilir. Burada Kullanıcı’nın bu maddeye aykırı hareketlerinin tespiti halinde DigiliraPay, Kullanıcı’nın hesabını önceden hiçbir bildirime gerek kalmaksızın iptal etme, durdurma veya askıya alma haklarına sahiptir. Bu madde kapsamında meydana gelen tüm zararlardan Kullanıcı veya vekaletname ile kullanımına izin verilen kişi sorumlu olup tüm cezai müeyyideler de bu kişilere aittir. DigiliraPay’in bu haklarını kısmen veya tamamen kullanması nedeniyle Kullanıcı DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul eder.
Türk Medeni Kanunu’nun mirasın geçmesi ve vasiyetnameye ilişkin hükümleri uyarınca Kullanıcı’nın, yasal ve atanmış mirasçılarının hakları saklıdır. Vasiyetname ile yapılan tasarruflarda DigiliraPay’in olası bir vasiyetnamenin iptali davası açılıp açılmadığını araştırma süresince ve eğer böyle bir dava açılmış ise kesin şekilde sonuçlanıncaya dek dava süresince işlem yapmama hakkı saklıdır.
6.4. Kullanıcı, sadece tek bir hesaba ve akıllı cüzdana sahip olabilir. Kullanıcı, Platform’u sadece işbu sözleşmede tanımlanan hizmetlerden faydalanmak amacıyla kullanabilir. Kullanıcı, DigiliraPay’in aynı Kullanıcı’ya ait birden fazla hesabın varlığını tespit etmesi halinde Kullanıcı’ya ait tüm hesapları önceden bildirimde bulunmaksızın iptal etme, durdurma veya askıya alma haklarına sahip olduğunu, bu işlemler nedeniyle DigiliraPay’in herhangi bir sorumluluğunun olmadığını ve DigiliraPay’i bu sebeple gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder. Bu madde kapsamında sayılan hallerde doğan ve doğacak tüm hukuki ve cezai sorumluluk Kullanıcı’ya aittir.
6.5. Kullanıcı, Platform üzerinde gerçekleştirdiği işlemlerde ve yazışmalarda, işbu Sözleşme'nin hükümlerine, Platform’da belirtilen tüm koşullara, yürürlükteki mevzuata ve ahlak kurallarına uygun olarak hareket edeceğini kabul ettiğini beyan eder. Kullanıcı'nın Platform dâhilinde yaptığı işlem ve eylemlere ilişkin hukuki ve cezai sorumluluk kendisine aittir.
6.6. Kullanıcı, başta Suç Gelirlerinin Aklanmasının Önlenmesi Hakkında Kanun olmak üzere Türkiye Cumhuriyeti’nde yürürlükte olan tüm mevzuata ve genel hukuk kurallarına aykırı amaçlarla Platform’u kullanmayacağını ve başka kişilere kullandırmayacağını, hukuka ve mevzuata aykırı amaçlarla Platform’u kullanması ya da başkalarına hesabını kullandırması halinde doğacak tüm hukuki ve cezai sorumluluktan kendisinin sorumlu olacağını peşinen kabul eder. Kullanıcı’nın Türk Kanunlarına aykırı olarak hesabı kullanması nedeniyle yetkili makamlar tarafından hesap, kripto para varlıkları ve itibari para varlıkları üzerinde yapılacak tasarruflardan DigiliraPay sorumlu tutulamaz.
6.7. DigiliraPay, yürürlükteki mevzuat uyarınca yetkili makamların talebi halinde, Kullanıcı'nın kendisinde bulunan bilgilerini taleple sınırlı olarak söz konusu makamlarla paylaşabilecektir.
Ayrıca işbu Sözleşme’nin devam etmekte olduğu herhangi bir zaman dilimi içerisinde DigiliraPay tarafından Kullanıcı’dan bilgi güvenliği ve/veya hesap-işlem teyidi için bazı bilgi/belgeler talep edilebilecektir. Platform’a üyelik sırasında ve/veya Platform üzerinden gerçekleştirilen işlemler ve kimlik doğrulama işlemleri sırasında Kullanıcılardan alınan kişisel veriler, Kullanıcılar arasında sahtecilik, dolandırıcılık, Platform’un kötüye kullanımı, Türk Ceza Kanunu anlamında suç oluşturabilecek konularda çıkan uyuşmazlıklarda, yalnızca talep edilen konu ile sınırlı olmak üzere tarafların yasal haklarını kullanabilmeleri amacıyla ve sadece bu kapsam ile sınırlı olmak üzere uyuşmazlığa taraf olabilecek diğer Kullanıcılara iletebilecektir.
6.8. Kullanıcı, herhangi bir işlem limitine bağlı olmaksızın DigiliraPay tarafından ve/veya resmi bir merci tarafından DigiliraPay’den talep edilmesi halinde her türlü yatırma, çekme, alma, gönderme ve alışveriş işlemleri için kimlik ve adres bilgilerini belgelemek zorundadır. Kullanıcı tarafından kimlik ve adres bilgilerinin talep edilmesine rağmen belgelenmemesi halinde, DigiliraPay kullanıcıya ait hesap üzerinden hiçbir işlem yapılmasına izin vermeme hakkına haizdir.
6.9. Kullanıcı, akıllı cüzdanına ve akıllı cüzdanından yaptığı her türlü aktarımlardan kendisi mesuldür. Bir kripto paranın başka bir Kullanıcı’ya veya üçüncü bir kişiye ait ancak DigiliraPay’in akıllı cüzdanından farklı bir kripto para cüzdanına hatalı aktarımı halinde bu transfer nedeniyle DigiliraPay sorumlu tutulamaz ve tüm sorumluluk hatalı gönderimi yapan Kullanıcı’ya aittir. Yine, kripto paraların teknik özelliklerine göre, aktarım yapılırken girilmesi gereken bilgilerin (örneğin TAG, MEMO adresi vb.) hatalı girilmesi sebebiyle yaşanacak hatalı gönderimlerin mesuliyeti de Kullanıcı’ya aittir. Kullanıcı tüm bu durumlar için DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.10. Kullanıcı’nın, Platform’u kullanması sebebiyle doğacak tüm vergi mükellefiyetlerinden Kullanıcı sorumludur. Kullanıcı’nın Platform’u kullanması ve yaptığı transferler nedeniyle Kullanıcı’dan herhangi bir komisyon ve/veya ücret alınmaması halinde Kullanıcı’ya fatura gönderilmeyecektir.
Kullanıcı’nın akıllı cüzdanını kullanarak DigiliraPay üyesi bir iş yerinde yapmış olduğu harcamaya ilişkin faturanın Kullanıcı’ya gönderilmesi harcamanın yapıldığı iş yerinin sorumluluğundadır. Kullanıcı’nın, DigiliraPay üyesi bir iş yerinde yapmış olduğu harcamaya ilişkin faturanın Kullanıcı’ya ulaştırılmamasından DigiliraPay sorumlu değildir.
6.11. Kullanıcı'nın Hesap Bilgileri Sayfası'na erişmek ve Platform üzerinden işlem gerçekleştirebilmek için ihtiyaç duyduğu, akıllı cüzdana giriş yapmak için oluşturduğu PİN kodu Kullanıcı tarafından oluşturulmakta olup anahtar kelimeler de Kullanıcı’nın cihazında sadece Kullanıcı’ya gösterilecek şekilde oluşturulmaktadır. Söz konusu bilgilerin güvenliği ve gizliliği tamamen Kullanıcı'nın sorumluluğundadır. Aynı şekilde akıllı cüzdan girişi için kendisince oluşturulan PİN kodunun güvenliği ve gizliliği de tamamen Kullanıcı'nın sorumluluğundadır. Kullanıcı, akıllı cüzdanında kolay tahmin edilmeyecek bir PİN kodu kullanmalı ve PİN kodunu yalnızca DigiliraPay akıllı cüzdanı için kullanmalıdır. Kullanıcı, Platform’a üye olurken verilen bilgilerin doğruluğundan ve gizliliğinden sorumlu olup, kendisine ait anahtar kelime ve PİN kodu ile gerçekleştirilen işlemlerin kendisi tarafından gerçekleştirilmiş olduğunu, bu işlemlerden kaynaklanan sorumluluğun peşinen kendisine ait olduğunu, bu şekilde gerçekleştirilen iş ve işlemleri kendisinin gerçekleştirmediği yolunda herhangi bir def'i ve/veya itiraz ileri süremeyeceğini ve/veya bu def'i veya itiraza dayanarak yükümlülüklerini yerine getirmekten kaçınamayacağını kabul, beyan ve taahhüt eder.
6.12. DigiliraPay’e ait ya da internet yer sağlayıcısı şirketin sistemlerinden kaynaklı olarak ya da herhangi bir sebeple meydana gelen kullanıcının hesaplarında veya DigiliraPay’in sistemlerindeki siber saldırı ve her türlü hırsızlık suçlarından dolayı da DigiliraPay’in sorumluluğuna gidilemez. Kullanıcı bu hususlarda doğacak zararlar için DigiliraPay’den hiçbir ad altında talepte bulunmayacağını, bu doğrultuda DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.13. DigiliraPay, internet Platform’unda oluşabilecek teknik arızalardan dolayı hiçbir şekilde sorumlu tutulamaz. Ayrıca, kısa süreli ya da uzun süreli teknik arızalardan dolayı doğrudan veya dolaylı olarak doğan ve doğabilecek hiçbir zarardan sorumlu tutulamaz. İşlemlerin teknik hatalar sebebi ile ve/veya gerçekçi olmayan fiyatlardan gerçekleşmesi gibi hallerde DigiliraPay, Platform’u ve kullanılan sistemleri düzeltmek ve doğru çalışmasını sağlamak adına, bu işlemleri kısa veya uzun süreli olarak durdurabilir, üye iş yerinde yapılan işlemleri iptal edebilir. DigiliraPay, Kullanıcının üye iş yerine yapmış olduğu ödemeyi iade edebilir.
6.14. İşbu sözleşmenin ilgili hükümleri gereğince Kullanıcı tarafından DigiliraPay ile paylaşılmayan veya geç paylaşılan kimlik ve adres bilgilerinin paylaşılmaması veya geç paylaşılması nedeniyle doğacak zararlardan DigiliraPay sorumlu değildir.
6.15. Kullanıcı, Platform’u aşağıda sayılan haller başta olmak üzere hukuka ve ahlaka aykırı bir şekilde kullanmayacaktır.
i.    Platform’un herhangi bir kişi adına veri tabanı, kayıt veya rehber yaratmak, kontrol etmek, güncellemek veya değiştirmek amacıyla kullanılması;
ii.    Platform’un bütününün veya bir bölümünün bozma, değiştirme veya tersine mühendislik yapma amacıyla kullanılması;
iii.    Yanlış bilgiler veya başka bir kişinin bilgileri kullanılarak işlem yapılması, yanlış veya yanıltıcı ikametgâh adresi, elektronik posta adresi, iletişim, ödeme veya hesap bilgileri de dahil yanlış veya yanıltıcı kişisel veriler kullanılmak suretiyle sahte üyelik hesapları oluşturulması ve bu hesapların işbu Sözleşme’ye veya yürürlükteki mevzuata aykırı şekilde kullanılması, başka bir Kullanıcı'nın hesabının izinsiz kullanılması, başka birinin yerine geçilerek ya da yanlış bir isimle işlemlere taraf ya da katılımcı olunması;
iv.    Platform’da kullanılan sistemleri manipüle edecek şekilde kullanılma amaçları dışında kullanılması;
v.    Virüs veya Platform’a, Platform’un veri tabanına, Platform üzerinde yer alan herhangi bir içeriğe zarar verici herhangi başka bir zararlı yazılım yayılması;
vi.    Platform tarafından belirlenmiş olan iletişimler ve teknik sistemler üzerinde makul olmayan veya orantısız derecede büyük yüklemeler yaratacak ya da teknik işleyişe zarar verecek faaliyetlerde bulunulması, DigiliraPay’in önceden yazılı iznini alınmaksızın Platform üzerinde otomatik program, robot, web crawler, örümcek, veri madenciliği (data mining) ve veri taraması (data crawling) gibi "screen scraping" yazılımları veya sistemlerin kullanılması ve bu şekilde Platform’da yer alan herhangi bir içeriğin tamamının veya bir kısmının izinsiz kopyalanarak, yayınlanması veya kullanılması.
6.16. Kullanıcı, Platform’da yaptığı işlemleri DigiliraPay’e maddi ve Platform’a teknik olarak hiçbir surette zarar vermeyecek şekilde yürütmekle yükümlüdür. Kullanıcı, Platform kullanımının Platform’a zarar verecek her türlü program, virüs, yazılım, lisanssız ürün, truva atı vb. içermemesi için gerekli koruyucu yazılımları ve lisanslı ürünleri kullanmak da dâhil olmak üzere gerekli her türlü tedbiri aldığını kabul ve taahhüt eder.
6.17. Platform’un veya üzerindeki içeriğin işbu Sözleşme ile belirlenen kullanım şartlarına veya yürürlükteki mevzuat hükümlerine aykırı olarak kullanılması hukuka aykırı olup; DigiliraPay ilgili talep, dava ve takip hakları saklı tutar.
6.18. DigiliraPay, Kullanıcı’nın güvenliğini azami ölçüde sağlayacaktır. Bu kapsamda DigiliraPay, Kullanıcı’nın güvenliği adına üyelik oluşturulurken kimlik doğrulaması ile üyelik kaydı yapmaktadır. DigiliraPay, basiretli bir tacir gibi davranarak gerekli tüm özeni gösterecektir. DigiliraPay tarafından bu taahhüt yerine getirilmesine karşın kullanıcıya ait hesabın yetkisiz kişiler tarafından herhangi bir şekilde ele geçirilmesi ve DigiliraPay servislerinin kullanılması halinde işbu sözleşmenin ilgili hükümleri geçerli olacaktır. Kullanıcı bu hususlarda DigiliraPay’i ve tüm yetkililerini gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.19. Platform üzerinden yapılan kripto para transferleri blokzincir yapılarının özelliklerinden dolayı geri alınamaz. Kripto para transferleri geri alınamadığından dolayı varsa DigiliraPay tarafından kullanıcıdan alınan hizmet bedeli, komisyon ve işlem ücreti de iade edilemez. Kullanıcı bu madde hükümlerini işbu sözleşmenin imzalanması ile peşinen kabul ettiğini beyan ve taahhüt eder. Kullanıcı, hatalı yaptığını düşünsün düşünmesin bu işlemlerden dolayı DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ beyan ve taahhüt eder.
6.20. DigiliraPay, Kullanıcı tarafından yapılan kripto para alma/gönderme ve ödeme işlemlerini süratle yerine getirecektir.  İşlemlerinin yasalarda sayılan “mücbir sebep” halleri ile hiç gerçekleştirilememesi veya yine mücbir sebeplerden kaynaklı ya da iş yoğunluğundan kaynaklı olarak geç gerçekleştirilmesi halinde doğacak zararlardan DigiliraPay sorumlu olmayacaktır.
6.21. DigiliraPay, Platform üzerinden sunduğu hizmetlerde ve işlemlerde her türlü değişiklik yapma hakkına haizdir. Bu değişiklikler nedeniyle doğacak zararlardan DigiliraPay mesul olmayacaktır. Ancak DigiliraPay yaptığı değişiklikleri www.digilirapay.com internet Platform’unda bulunan Destek sayfalarında veya diğer sayfalarda ilan edeceğini taahhüt eder.
6.22. DigiliraPay, destek hizmetlerini yalnızca destek@digilirapay.com elektronik posta adresi ve destek sayfası üzerinden sağlayacaktır. Bu elektronik posta adresi ve destek sayfası dışında hiçbir yöntem ile kullanıcılara destek hizmeti verilmemektedir. Bu adres üzerinden yapacağı destek hizmetlerinde de Kullanıcılardan kripto para göndermeleri için Kullanıcılara kripto para adresi bildirilmez. Kullanıcıların anahtar kelimeleri istenmez. Kullanıcı bu madde hükümlerini kabul ederek DigiliraPay’den destek alacağını kabul eder. Bu sebeple doğan zararlardan DigiliraPay sorumlu değildir. DigiliraPay adı kullanılarak veya bu intiba yaratılarak oluşturulan “korsan” siteler nedeniyle bu sahte sitelere üye olan kişilerin yaşadığı mağduriyetlerden DigiliraPay sorumlu tutulamaz. DigiliraPay sitelerine erişim sağlarken “https” bağlantısını ve site adresinin doğruluğunu kontrol ederek siteye erişim sağlaması Kullanıcı’nın kendi sorumluluğundadır. Kullanıcı bu hususlarda DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.23. Ödeme geçidi pozisyonunda olan DigiliraPay’in kripto para kurlarının arz talep ilişkisine göre belirlenen değişimlerinden dolayı hiçbir sorumluluğu yoktur. Bu sebeplerle doğacak tüm zarar ve kayıpların mesuliyeti kullanıcıya aittir. Platform kullanıcılarının iş ve işlemlerinin Sözleşme hükümleri çerçevesinde yerine getirilememesi/geç yerine getirilmesi nedeniyle oluşacak zararlardan DigiliraPay sorumlu tutulamaz. Kullanıcı bu hususlarda DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder.
6.24. DigiliraPay, benzer kripto para ödeme geçidi platformlarından tamamen bağımsız bir şirket olup, hiçbir şirketin, internet sitesinin veya kurumun temsilcisi değildir. Bu nedenle Kullanıcılar, diğer benzer platformlar üzerinden yaşadıkları mağduriyetlerden dolayı DigiliraPay’i sorumlu tutamazlar.
6.25. DigiliraPay, Platform’un kullanımının kesintisiz ve hatasız olduğunu taahhüt etmemektedir. DigiliraPay, Platform’un 7/24 erişilebilir ve kullanılabilir olmasını hedeflemekle birlikte Platform’a erişimi sağlayan sistemlerin işlerliği ve erişilebilirliğine ilişkin bir garanti vermemektedir.
6.26. DigiliraPay, Kullanıcıların günlük, haftalık ve aylık itibari para ve kripto para yatırma ve çekme limitlerini tek taraflı olarak belirleyebilir. DigiliraPay bu değerlendirmeyi durumsal olarak belirlemekte olup yine tek taraflı olarak, bu limitleri dilediği zaman ve önceden haber vermeksizin azaltma ve artırma yetkisine sahiptir. DigiliraPay’in bu yetkilerini kullanması nedeniyle Kullanıcı tarafından DigiliraPay’e karşı her hangi bir ad altında sorumluluk yüklenemez. Kullanıcı peşinen bu haklarından gayri kabili rücu olarak feragat ettiğini kabul ve beyan eder.
6.27. DigiliraPay tarafından işbu sözleşmede belirtilen hak ve yetkilerin doğumu anında kullanılmaması bu hak ve yetkilerden ve bunların kullanımından zımnen de olsa feragat edildiği anlamına gelmemektedir. DigiliraPay, mevzuata uygun olarak bu hak ve yetkileri dilediği zaman kullanmaya ehildir.
6.28. DigiliraPay’e ait internet sitesi bir bilgilendirme platformudur. Kullanıcılar akıllı cüzdanlarındaki kripto paralarla işlem yapmak istediklerinde DigiliraPay’e ait olan mobil uygulamalar üzerinden işlem yaparlar. Mobil uygulamalar, bu işlemlere aracılık eder. Bu nedenle kirpto paraların piyasada oluşan değerleri DigiliraPay tarafından belirlenmez. Kripto para kurları piyasa koşullarına göre belirlenir.
6.29. DigiliraPay, ürün, servis ve hizmetlerle ilgili ücretlerini ve komisyonları Platform’un Destek bölümünde ilan etmektedir.İlgili bölüme http://www.digilirapay.com/destek adresinden ulaşılmaktadır. Bu bölümde bulunan ücretler işbu sözleşmenin ayrılmaz parçası olup destek bölümünde ilan edildiği andan itibaren geçerlilik kazanacaktır. Ayrıca DigiliraPay, Kullanıcı tarafından blokzincir işlemi onaylanmadan önce Kullanıcı’ya işlem ücret ve/veya komisyonunu hesaplamakta ve uygulama üzerinde göstermektedir. Kullanıcı, blokzincir işlemini onaylamakla bu komisyon ve/veya ücreti de kabul ettiğini de onaylamaktadır.
6.30. DigiliraPay, Kullanıcı tarafından gerçekleştirilecek işlemlerde Kullanıcı’dan kendi belirlediği bir oran üzerinden hizmet bedeli, ücret ve/veya komisyon alma hakkına sahiptir. İtibari para ve kripto para çekme işleminde Kullanıcı’dan kendi belirlediği bir işlem ücreti alma hakkına sahiptir. DigiliraPay, bu ücret ve oranlar üzerinde dilediği zaman önceden bildirmeksizin değişiklik yapma hakkına sahiptir. Ancak yapılan değişiklikler Platform’da ilan edilecektir.

7. GİZLİLİK VE KİŞİSEL VERİLERİN KORUNMASI
7.1. Kişisel Verilerin İşlenmesi:
DigiliraPay, Kullanıcılarından elde edilen kişisel verilerin işlenmesiyle ilgili olarak KVKK'ya tabidir. DigiliraPay, www.digilirapay.com Platform’undan erişilebilecek Kişisel Verilerin İşlenmesi ve Korunması Politikası uyarınca Kullanıcılarından kişisel verileri toplar, kullanır, yurtiçine ve yurtdışına iletir ve işler. Kişisel Verilerin İşlenmesi ve Korunması Politikası işbu Kullanım Şartları Sözleşmesi’nin ayrılmaz bir parçasıdır.
Kişisel verileri kullanımımızla ve bu konularda sahip olduğunuz haklarla ilgili daha fazla bilgi için ve KVKK kapsamında kişisel verilerinizi koruma ve işlememizle ilgili bilgi edinmek için, Platform’dan Kişisel Verilerin İşlenmesi ve Korunması Politikası’na erişebilir ve kisiselveri@digilirapay.com adresine e-posta göndererek söz konusu haklarınızı icra edebilirsiniz.
Bizimle iletişime geçtiğiniz e-posta adresi, DigiliraPay üyelik süreciniz sırasında ibraz ettiğiniz e-posta adresi olmalıdır. Bir Kullanıcı olduğunuzla ilgili makul çerçevede bir ispat sağlanmadıkça, diğer e-posta adreslerinden alınan taleplere cevap verilmeyecektir.
7.2. Gizlilik:
7.2.1. DigiliraPay, kendisine verilen gizli bilgileri kesinlikle özel ve gizli tutmayı, bunu bir sır olarak saklamayı yükümlülük olarak kabul ettiğini ve gizliliğin sağlanıp sürdürülmesi, gizli bilginin tamamının veya herhangi bir parçasının kamu alanına girmesini veya yetkisiz kullanıcıyı veya üçüncü bir kişiye açıklanmasını önleme gereği olan gerekli tüm tedbirleri almayı ve üzerine düşen tüm özeni göstermeyi işbu bildirimle taahhüt etmektedir. DigiliraPay, kullanıcıya ait kişisel bilgileri, yasal mercilerle paylaşabilecektir ancak kullanıcının açık rızası ve yasal zorunluluklar haricinde üçüncü şahıslar ile paylaşmayacaktır. Ancak yürütülen faaliyet ile ilgili anonim bilgileri Kişisel Verileri Koruma Kanunu ve bu kanunun tüm mevzuatına uygun bir şekilde işleme ve paylaşma yetkisine sahiptir
7.2.2. DigiliraPay;
1.    Gizli Bilgi’yi uygun şekilde almayı ve büyük bir gizlilik içinde korumayı,
2.    Gizli Bilgi’yi Taraflar arasındaki ilişkinin amacının gerçekleştirilmesi dışında, her ne surette olursa olsun doğrudan veya dolaylı olarak başkaca hiçbir amaç için kullanmayacağını,
3.    Gizli Bilgi’yi yasal yükümlülükler hali hariç olmak üzere, Kullanıcı’nın onayı olmaksızın, üçüncü şahıs ya da kurumlara açıklamayacağını ve üçüncü şahıslarca kullanımına ve/veya kopya edilmesine izin vermeyeceğini
4.    Gizli Bilgi’nin istihdam ettiği personel, vekiller, Taraflar adına hareket eden gerçek veya tüzel kişiler tarafından da korunacağını, taahhüt etmektedir.
7.2.3. DigiliraPay,
1.    Mahkeme kararı, kanun, tüzük, yönetmelik gibi yetkili hukuki makamlar tarafından çıkarılan ve yürürlükte bulunan yazılı hukuk kurallarının getirdiği zorunluluklara uyulmasının gerektiği ve yetkili idari ve/veya adli makamlar tarafından usuli yöntemine uygun olarak yürütülen bir araştırma, soruşturma veya kovuşturma doğrultusunda Kullanıcılarla ilgili bilgi talep edilmesi hallerinde,
2.    Kullanıcıların haklarını veya güvenliklerini koruma amacıyla bilgi verilmesinin gerekli olduğu hallerde,
3.    Kullanıcılarıyla arasındaki sözleşmelerin gereklerinin yerine getirilmesi ve bunların uygulamaya konulmalarıyla ilgili hallerde gizlilik bildirimi hükümleri dışına çıkarak kullanıcılara ait bilgileri üçüncü kişilere açıklayabilecektir.

8. FİKRİ MÜLKİYET HAKLARI
“DigiliraPay” markası ve logosu, “DigiliraPay” mobil uygulamasının ve Platform’un tasarımı, yazılımı, alan adı ve bunlara ilişkin olarak DigiliraPay tarafından oluşturulan her türlü marka, tasarım, logo, ticari takdim şekli, slogan ve diğer tüm içeriğin her türlü fikri mülkiyet hakkı DigiliraPay mülkiyetindedir. Kullanıcı, DigiliraPay’in veya bağlı şirketlerinin mülkiyetine tabi fikri mülkiyet haklarını yazılı izni olmaksızın kullanamaz, paylaşamaz, dağıtamaz, sergileyemez, çoğaltamaz ve bunlardan türemiş çalışmalar yapamaz. Kullanıcı, mobil uygulamasının veya Platform’un bütünü ya da bir kısmını başka bir ortamda DigiliraPay’in yazılı izni olmaksızın kullanamaz. Kullanıcı'nın, üçüncü kişilerin veya DigiliraPay’in fikri mülkiyet haklarını ihlal edecek şekilde davranması halinde, Kullanıcı, DigiliraPay’in ve/veya söz konusu üçüncü kişinin tüm doğrudan ve dolaylı zararları ile masraflarını tazmin etmekle yükümlüdür.

9. HUKUKİ ve CEZAİ YAPTIRIMLAR
9.1. Kullanıcı, blokzincir ve tüm kripto paralar ile ilgili yetkili kurumlar tarafından yapılan ve bundan sonra yapılacak tüm açıklamaları okumuş ve kabul etmiş sayılır.
9.2. Kullanıcı tarafından Platform’un hukuka aykırı amaçlarla kullanılması ya da başka bir kişiye kullandırtılması durumunda kullanıcı işbu sözleşme uyarınca doğacak tüm hukuki ve cezai müeyyidelerden sorumludur. Bu hususta DigiliraPay’i gayri kabili rücu olarak İBRA ETTİĞİNİ kabul, beyan ve taahhüt eder. DigiliraPay tarafından kullanıcının hesabının dondurulması, kalıcı ya da geçici olarak silinmesi, askıya alınması vs. hususları nedeniyle DigiliraPay, bu kişinin yeniden hesap açmasını süresiz olarak kabul etmeme hakkına haizdir.
9.3. Kullanıcı, siteyi Türkiye Cumhuriyeti yasaları ve tüm mevzuatı kapsamında kullanacağını taahhüt eder. Yasalara aykırı kullanım halinde DigiliraPay, kullanıcıya ait tüm bilgileri yetkili merciler ile paylaşma hakkına ve yetkisine sahiptir. Bu husus gizliliğin ihlali kapsamında değerlendirilemez ve DigiliraPay’e herhangi bir sorumluluk atfedilemez.
9.4. İşbu sözleşme hükümlerinin uygulanması nedeniyle, Kullanıcı, DigiliraPay adı ve/veya logosunu kullanarak DigiliraPay adını lekeleyen, ticari itibarını zedeleyen ya da haksız rekabet yaratan yorum ve paylaşımlarda bulunmayacağını taahhüt eder. Bu taahhüt her türlü yazılı ve görsel medya ile tüm sosyal medya mercilerini kapsamaktadır. Bu maddenin ihlalinin tespiti halinde, DigiliraPay, önceden bildirimde bulunmaksızın sözleşmeyi tek taraflı feshetme, Kullanıcı’nın hesabını engelleme, askıya alma ya da tamamen silme haklarına haizdir. Aynı şekilde DigiliraPay, Kullanıcı’ya karşı bu maddenin ihlali nedeniyle her türlü tazmin hakkını kullanacaktır. Kullanıcı, bu maddenin uygulanması nedeniyle tüm itiraz ve talep haklarından peşinen gayri kabili rücu olarak feragat ettiğini kabul, beyan ve taahhüt eder.
9.5. DigiliraPay, işleyiş ve yazılım güvenliği açısından şüpheli işlem girişimi tespit ettiği Kullanıcı’ya ait hesap veya hesapları geçici olarak ya da kalıcı olarak işlemlere kapatmak, şüpheli işlem gerçekleştiren Kullanıcı hesaplarını askıya almak, dondurmak ya da kapatmak haklarına haizdir. DigiliraPay tarafından dürüstlük ve iyi niyet kuralları çerçevesinde bu maddenin uygulanması nedeniyle, DigiliraPay’in hukuki ve cezai sorumluluğuna gidilemez.
9.6. DigiliraPay, e-posta destek hattı ile yazışmalarında genel ahlak ve dürüstlük kurallarına aykırı ifadeler kullanan Kullanıcılara ait hesapları askıya almak, dondurmak, geçici ya da sürekli olarak kapatmak haklarına haizdir. DigiliraPay tarafından bu maddenin dürüstlük ve iyi niyet kuralları çerçevesinde uygulanması nedeniyle, DigiliraPay’in hukuki ve cezai sorumluluğuna gidilemez.
9.7. DigiliraPay tarafından Kullanıcı’ya sehven sebepsiz zenginleşmeye neden olacak şekilde kripto para ve/veya jeton gönderilmesi halinde bu husus Kullanıcı’ya derhal her türlü yolla      (e-posta, arama, sms vs.) bildirilir. Bildirime rağmen 1 iş günü içerisinde kullanıcı tarafından iade edilmemesi halinde DigiliraPay tarafından başkaca ihtar ya da bildirime gerek olmaksızın kullanıcının hesabı kapatılabilir, askıya alınabilir ya da süresiz erişimi durdurulabilir. Yine bu halde, DigiliraPay tarafından kullanıcının hesabı sehven yapılan aktarım kadar eksi bakiyeye düşürülebilir ve yasal yollara başvurulabilir. Kullanıcı bu hususta DigiliraPay’i gayri kabili rücu olarak İBRA ettiğini peşinen kabul ve taahhüt eder. DigiliraPay, bu işlem nedeniyle uğradığı doğrudan ya da dolaylı zararları tazmin hakkını saklı tutar.
9.8. Kullanıcı tarafından işbu sözleşmedeki her hangi bir maddenin ya da maddelerin ihlal edildiğinin DigiliraPay tarafından tespit edilmesine karşın, DigiliraPay tarafından sözleşmenin feshedilmemesi, kullanıcı hakkında yasal yollara başvurulmaması, bu haklardan DigiliraPay tarafından feragat edildiği anlamında yorumlanamaz. Tespit edilen bu ihlallere karşı DigiliraPay’in tüm hakları saklıdır.
9.9. İşbu sözleşmede yer alan herhangi bir maddenin ya da maddelerin Kullanıcı tarafından ihlal edilmesi halinde, DigiliraPay, Kullanıcı’nın hesabını önceden hiçbir bildirimde bulunmaksızın iptal etme, silme, durdurma, askıya alma ve kısıtlama haklarına sahiptir. Ancak bu hakların DigiliraPay tarafından kullanılması halinde dahi kullanıcının DigiliraPay nezdindeki kripto varlıkları bu durumdan etkilenmez ve Kullanıcı’nın DigiliraPay nezdindeki varlıkları üzerinde yasalardan doğan bir kısıtlama olmaması şartıyla ve talep halinde Kullanıcı’nın resmi yoldan bildireceği başka bir kripto para cüzdanına işlem masrafları Kullanıcı’ya ait olmak ve Kullnıcı’nın cüzdanındaki bakiyesinden karşılanmak üzere iade edilir. DigiliraPay’in Kullanıcı’ya herhangi bir amaçla bedelsiz olarak göndermiş olduğu kripto para ve jetonlar iade edilecek kripto varlıklar arasında yer almamaktadır. Kullanıcı’nın sözleşmeye aykırı davranmasından dolayı DigiliraPay’in uğramış olduğu her türlü zararı tazmin etmek için Kullanıcı’nın akıllı cüzdanı üzerinde hapis, rehin, haciz ve rüçhan hakları saklıdır.

10. SÖZLEŞME DEĞİŞİKLİKLERİ
DigiliraPay, işbu Sözleşme’yi ve Platform’da yer alan Kişisel Verilerin İşlenmesi ve Korunması Politikası da dahil her türlü politikayı, hüküm ve şartı uygun göreceği herhangi bir zamanda, yürürlükteki mevzuat hükümlerine aykırı olmamak kaydıyla Platform’da ilan ederek tek taraflı olarak değiştirebilir. İşbu Sözleşmenin değişen hükümleri, Platform’da ilan edildikleri tarihte geçerlilik kazanacak, geri kalan hükümler aynen yürürlükte kalarak hüküm ve sonuçlarını doğurmaya devam edecektir.
11. MÜCBİR SEBEP
Ayaklanma, ambargo, devlet müdahalesi, isyan, işgal, savaş, seferberlik, grev, lokavt, iş eylemleri veya boykotlar dahil olmak üzere siber saldırı, iletişim sorunları, altyapı ve internet arızaları, sisteme ilişkin iyileştirme veya yenileştirme çalışmaları ve bu sebeple meydana gelebilecek arızalar, elektrik kesintisi, yangın, patlama, fırtına, sel, deprem, göç, salgın veya diğer bir doğal felaket veya DigiliraPay’in kontrolü dışında gerçekleşen, kusurundan kaynaklanmayan ve makul olarak öngörülemeyecek diğer olaylar ("Mücbir Sebep") DigiliraPay’in işbu Sözleşmeden doğan yükümlülüklerini ifa etmesini engeller veya geciktirirse, DigiliraPay ifası mücbir sebep sonucunda engellenen veya geciken yükümlülüklerinden dolayı sorumlu tutulamaz ve bu durum işbu Sözleşmenin bir ihlali olarak değerlendirilemez.

12. GENEL HÜKÜMLER
12.1. Kullanıcı, işbu Sözleşme’den doğabilecek ihtilaflarda DigiliraPay’in resmi defter ve ticari kayıtları ile DigiliraPay’in veri tabanında, sunucularında tutulan e-arşiv kayıtlarının, elektronik bilgilerin ve bilgisayar kayıtlarının, bağlayıcı, kesin ve münhasır delil teşkil edeceğini ve bu maddenin 6100 sayılı Hukuk Muhakemeleri Kanunu’nun 193. maddesi anlamında delil sözleşmesi niteliğinde olduğunu kabul eder.
12.2. İşbu Sözleşme münhasıran Türkiye Cumhuriyeti kanunlarına tabi olacaktır. İşbu Sözleşmeden kaynaklanan veya işbu Sözleşme ile bağlantılı olan her türlü ihtilaf, Eskişehir Mahkemeleri ve İcra Müdürlükleri'nin münhasır yargı yetkisinde olacaktır.
12.3. DigiliraPay, Kullanıcı ile Kullanıcı'nın kayıt olurken bildirmiş olduğu elektronik posta adresi vasıtasıyla veya telefon numarasına arama yapmak ve SMS göndermek suretiyle iletişim kuracaktır. Kullanıcı, elektronik posta adresini ve telefon numarasını güncel tutmakla yükümlüdür. İşbu Sözleşme’nin akdi sırasında sağlanan bilgilerde herhangi bir değişiklik olması halinde, söz konusu bilgiler derhal güncellenecektir. Bu bilgilerin eksik veya gerçeğe aykırı olarak verilmesi ya da güncel olmaması nedeniyle Platform’a erişim sağlanamamasından veya Platform’dan faydalanılamamasından DigiliraPay sorumlu olmayacaktır.
12.4. İşbu Sözleşme, konuya ilişkin olarak Taraflar arasındaki anlaşmanın tamamını oluşturmaktadır. İşbu Sözleşmenin herhangi bir hükmünün yetkili herhangi bir mahkeme, tahkim heyeti veya idari makam tarafından tümüyle veya kısmen geçersiz veya uygulanamaz olduğu veya makul olmadığına karar verilmesi halinde, söz konusu geçersizlik, uygulanamazlık veya makul olmama ölçüsünde işbu Sözleşme bölünebilir olarak kabul edilecek ve diğer hükümler tümüyle yürürlükte kalmaya devam edecektir.
12.5. Kullanıcı, DigiliraPay’in önceden yazılı onayını almaksızın işbu Sözleşmedeki haklarını veya yükümlülüklerini tümüyle veya kısmen temlik edemeyecektir. DigiliraPay ise, işbu Sözleşme’den doğan hak, yükümlülük, borç ve/veya alacaklarını herhangi bir izne tabi olmaksızın devir ve nakil edebilir.
12.6. DigiliraPay, işbu sözleşmede yer alan tüm koşul ve hükümleri önceden bildirmeksizin değiştirebilir. Değişiklikler sitede ilan edilecektir. Aynı şekilde DigiliraPay, bu değişiklikleri Kullanıcıların kaydolurken beyan ettikleri cep telefonu numarasına SMS olarak ve elektronik posta adresine elektronik posta olarak da gönderebilir. Kullanıcı, sözleşmeyi imzalamakla bu bilgilendirme yöntemlerini kabul etmiştir. Kullanıcı, işbu sözleşmeyi kabul ile DigiliraPay tarafından yapılacak bu değişlikleri de geçmişe etkili olmak üzere önceden kabul ettiğini beyan ve taahhüt eder.
12.7. Taraflar'dan birinin işbu Sözleşmede kendisine verilen herhangi bir hakkı kullanmaması ya da icra etmemesi, söz konusu haktan feragat ettiği anlamına gelmeyecek veya söz konusu hakkın daha sonra kullanılmasını ya da icra edilmesini engellemeyecektir.
12.8. İşbu sözleşme DigiliraPay tarafından sitede ilan edildiğinde geçmişe yönelik olarak ve mevcut tüm kullanıcıları da kapsar şekilde geçerlilik kazanır.
12.9. Kullanıcı, Platform’a kaydolduğunda işbu sözleşmenin tüm maddelerini ayrı ayrı okuyup anladığını, sözleşmenin bütün içeriğini ve bütün hükümlerini onayladığını kabul, beyan ve taahhüt eder. İşbu sözleşmeyi kabul etmeyen Kullanıcının kaydolmaması ve DigiliraPay’in ürün, servis ve hizmetlerinden faydalanmaması gerekmektedir.
Onsekiz (17) sayfa ve on iki (12) ana maddeden ibaret işbu Sözleşme, Kullanıcı tarafından her bir hükmü okunarak ve bütünüyle anlaşılarak elektronik ortamda onaylanmak suretiyle, onaylandığı an itibarıyla yürürlüğe girmiştir.
"""
        static let version = 10
    }
    
    struct terms: Encodable {
        var title: String
        var text: String
        var mode: Int
    }
    
    // MARK: - NodeError
    struct NodeError: Codable {
        let message: String
    }

    struct QR: Codable {
       var network: String?
       var address: String?
       var amount: Int64?
       var assetId: String?
    }
   
    struct setScript: Encodable {
        var id: String?
        var senderPublicKey: String?
        var fee: Int64
        var timestamp: Int64?
        var recipient: String?
        var proofs: Array<String>?
        var script: String?
        var chainId: Int64?
    }
    
    struct transfer: Encodable {
        var type: Int?
        var id: String?
        var sender: String?
        var senderPublicKey: String?
        var fee: Int64
        var timestamp: String?
        var version: Int?
        var recipient: String?
        var amount: Int64
        var assetId: String?
        var attachment: String?
    }
    
    struct externalTransaction: Encodable {
        var network: String?
        var address: String?
        var amount: Int64?
        var message: String = "DIGILIRAPAY TRANSFER"
        var owner: String?
        var wallet: String?
        var assetId: String?
        var destination: String?
        var signed: String?
        var publicKey: String?
        var timestamp: Int64?
        var isTether: Bool?
    }
     
    struct ticker {
        var ethUSDPrice: Double?
        var btcUSDPrice: Double?
        var wavesUSDPrice: Double?
        var usdTLPrice: Double? 
    }
    
    struct exUser: Encodable {
        var id: String?
        var firstName: String?
        var lastName: String?
        var tcno: String?
        var dogum: String?
        var tel: String?
        var mail: String?
        var btcAddress: String?
        var ethAddress: String?
        var ltcAddress: String?
        var tetherAddress: String?
        var wallet: String?
        var token: String?
        var status: Int?
        var pincode: String?
        var imported: Bool?
        var id1: String?
        var apnToken: String?
        var zmark: String?
        var signed: String?
        var publicKey: String?
        var timestamp: Int64?
    }

    struct login: Codable {
        let seed: String
        
        enum CodingKeys: String, CodingKey {
            case seed = "seed"
        }
    }

    struct auth: Codable {
        var userRole, status: Int
        let pincode: String
        let imported: Bool
        let apnToken, id, wallet: String
        let firstName, lastName, ltcAddress, btcAddress, tetherAddress, ethAddress, tcno, tel, mail: String?
        let createdDate: String
        let profil1: String?
        let profil2: String?
        let profil3: String?
        let dogum: String?
        let v: Int?
        let appV: Double?
        var isAuthorized: Int?
        let zmark: String?

        enum CodingKeys: String, CodingKey {
            case userRole, status, pincode, imported, apnToken
            case id = "_id"
            case lastName, firstName, wallet, btcAddress, ethAddress, profil1, profil2, profil3, tetherAddress, ltcAddress, createdDate, appV, dogum, tcno, tel, mail, isAuthorized, zmark
            case v = "__v"
        }
    }
    
    struct wallet: Encodable {
        var seed: String
        var wavesToken: String
    }

    struct txConfMsg: Encodable {
        let title: String
        let message: String
        let l1:String
        let sender:String
        let l2:String
        let l3:String
        let l4:String
        let t2:String
        let c2: String?
        let yes:String?
        let remark: String?
        let no:String?
        let icon:String
    }
    
    struct DigiliraPayBalance: Encodable {
        let tokenName:String
        let tokenSymbol: String
        let availableBalance: Int64
        let decimal: Int
        let balance: Int64
        let tlExchange: Double
        let network: String
        let wallet: String
    }

    enum NAError: Error {
        case emptyAuth
        case emptyPassword
        case sponsorToken
        case notListedToken
        case E_500
        case E_501
        case E_502
        case E_503
        case E_400
        case E_401
        case E_402
        case E_403
        case E_404
        case user404
        case seed404
        case tokenNotFound
        case parsingError
        case keychainSaveError
        case wrongPin
        case biometricMismatch
        case userCanceled
        case updateAPP
        case noBalance
        case minBalance
        case anErrorOccured
        case missingParameters
        case noEmail
        case noPhone
        case noName
        case noSurname
        case noTC
        case noAmount
    }
   
    // MARK: - MarketInfoElement
    struct MarketInfoElement: Codable {
        let type: Int
        let id, sender, senderPublicKey: String
        let fee: Int
        let feeAssetID: JSONNull?
        let timestamp: Int
        let proofs: [String]
        let version: Int
        let assetID, attachment: String
        let transferCount, totalAmount: Int?
        let transfers: [Transfer]?
        let applicationStatus: String
        let height: Int
        let recipient: String?
        let feeAsset: JSONNull?
        let amount: Int?

        enum CodingKeys: String, CodingKey {
            case type, id, sender, senderPublicKey, fee
            case feeAssetID = "feeAssetId"
            case timestamp, proofs, version
            case assetID = "assetId"
            case attachment, transferCount, totalAmount, transfers, applicationStatus, height, recipient, feeAsset, amount
        }
    }
    
    // MARK: - Deposit Remarks
    struct DepositLine: Codable {
        let remark: String
    }
     

    // MARK: - Transfer
    struct Transfer: Codable {
        let recipient: String
        let amount: Int
    }

    typealias MarketInfo = [[MarketInfoElement]]

    // MARK: - Encode/decode helpers

    class JSONNull: Codable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

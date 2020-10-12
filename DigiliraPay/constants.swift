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
        static let updateScript =  "/users/signscript/update"
    }
    struct node {
        static let url = "https://nodes-testnet.wavesnodes.com"
    }
    struct messages {
        static let profileUpdateHeader = "Profilinizi Güncelleyin"
        static let profileUpdateMessage = "Ödeme yapmadan önce profilinizi tamamlamanız gerekmektedir."
        static let qrErrorHeader = "QR Kod Hatası"
        static let qrErrorMessage = "Ödeme bilgileri bulunamadı"
    }
    
    
    struct smartAccount {
        static let script = "base64:AwQAAAALZGlnaWxpcmFQYXkBAAAAID0HOFHYXYpCB2C8RjDY8m3ndBlb8WihoYLw1tvHVwgrBAAAAAckbWF0Y2gwBQAAAAJ0eAMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAATVHJhbnNmZXJUcmFuc2FjdGlvbgQAAAABdwUAAAAHJG1hdGNoMAMJAQAAAAlpc0RlZmluZWQAAAABCAUAAAABdwAAAAdhc3NldElkBgMJAAAAAAAAAggFAAAAAXcAAAAJcmVjaXBpZW50CQEAAAAUYWRkcmVzc0Zyb21QdWJsaWNLZXkAAAABBQAAAAtkaWdpbGlyYVBheQYJAAACAAAAAQIAAAAxVW5mb3J0dW5hdGVseSB5b3UgY2FuIG9ubHkgc2VuZCB3YXZlcyB0byBpc3N1ZXIuLgMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAABU9yZGVyBgMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAQTGVhc2VUcmFuc2FjdGlvbgYJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAPQnVyblRyYW5zYWN0aW9uBAAAAAF4BQAAAAckbWF0Y2gwBwMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAD0RhdGFUcmFuc2FjdGlvbgYDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAE0V4Y2hhbmdlVHJhbnNhY3Rpb24GCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAFFNldFNjcmlwdFRyYW5zYWN0aW9uBAAAAAF0BQAAAAckbWF0Y2gwCQAB9AAAAAMIBQAAAAF0AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAABdAAAAAZwcm9vZnMAAAAAAAAAAAEFAAAAC2RpZ2lsaXJhUGF5BjJoWnQ="
        static let complexity =  139
        static let extraFee = 400000
        
    }
    
    
    
    struct legalView {
        static let title = "Aydınlatma Metni"
        static let text = "Yaygın inancın tersine, Lorem Ipsum rastgele sözcüklerden oluşmaz. Kökleri M.Ö. 45 tarihinden bu yana klasik Latin edebiyatına kadar uzanan 2000 yıllık bir geçmişi vardır. Virginia'daki Hampden-Sydney College'dan Latince profesörü Richard McClintock, bir Lorem Ipsum pasajında geçen ve anlaşılması en güç sözcüklerden biri olan 'consectetur' sözcüğünün klasik edebiyattaki örneklerini incelediğinde kesin bir kaynağa ulaşmıştır. Lorm Ipsum, Çiçero tarafından M.Ö. 45 tarihinde kaleme alınan 'de Finibus Bonorum et Malorum' (İyi ve Kötünün Uç Sınırları) eserinin 1.10.32 ve 1.10.33 sayılı bölümlerinden gelmektedir. Bu kitap, ahlak kuramı üzerine bir tezdir ve Rönesans döneminde çok popüler olmuştur. Lorem Ipsum pasajının ilk satırı olan 'Lorem ipsum dolor sit amet' 1.10.32 sayılı bölümdeki bir satırdan gelmektedir. 1500'lerden beri kullanılmakta olan standard Lorem Ipsum metinleri ilgilenenler için yeniden üretilmiştir. Çiçero tarafından yazılan 1.10.32 ve 1.10.33 bölümleri de 1914 H. Rackham çevirisinden alınan İngilizce sürümleri eşliğinde özgün biçiminden yeniden üretilmiştir.-"
        static let version = 1
    }
    
    struct termsOfUse {
        static let title = "Kullanım Sözleşmesi"
        static let text = "Yaygın inancın tersine, Lorem Ipsum rastgele sözcüklerden oluşmaz. Kökleri M.Ö. 45 tarihinden bu yana klasik Latin edebiyatına kadar uzanan 2000 yıllık bir geçmişi vardır. Virginia'daki Hampden-Sydney College'dan Latince profesörü Richard McClintock, bir Lorem Ipsum pasajında geçen ve anlaşılması en güç sözcüklerden biri olan 'consectetur' sözcüğünün klasik edebiyattaki örneklerini incelediğinde kesin bir kaynağa ulaşmıştır. Lorm Ipsum, Çiçero tarafından M.Ö. 45 tarihinde kaleme alınan 'de Finibus Bonorum et Malorum' (İyi ve Kötünün Uç Sınırları) eserinin 1.10.32 ve 1.10.33 sayılı bölümlerinden gelmektedir. Bu kitap, ahlak kuramı üzerine bir tezdir ve Rönesans döneminde çok popüler olmuştur. Lorem Ipsum pasajının ilk satırı olan 'Lorem ipsum dolor sit amet' 1.10.32 sayılı bölümdeki bir satırdan gelmektedir. 1500'lerden beri kullanılmakta olan standard Lorem Ipsum metinleri ilgilenenler için yeniden üretilmiştir. Çiçero tarafından yazılan 1.10.32 ve 1.10.33 bölümleri de 1914 H. Rackham çevirisinden alınan İngilizce sürümleri eşliğinde özgün biçiminden yeniden üretilmiştir.-"
        static let version = 4
    }
    
    struct terms: Encodable {
        var title: String
        var text: String
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
    
    struct externalTransaction {
        var address: String?
        var amount: Int64?
        var message: String?
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
        var id1: String?
    }
    
    struct idImage: Encodable {
        var id1: String?
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




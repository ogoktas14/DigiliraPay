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
 
struct digilira {
    
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
    struct messages {
        static let profileUpdateHeader = "Profilinizi Güncelleyin"
        static let profileUpdateMessage = "Müşteri tanıma politikası kapsamında önce profil bilgilerinizi tamamlamanız gerekmektedir."
        static let qrErrorHeader = "QR Kod Hatası"
        static let qrErrorMessage = "Ödeme bilgileri bulunamadı"
        static let newTermsOfUseMessage = "Kullanım sözleşmemiz güncellendi."
        static let newTermsOfUseTitle = "Kullanım Sözleşmesi"
        static let newLegalViewMessage = "Aydınlatma metni güncellendi."
        static let newLegalViewTitle = "Aydınlatma Metni"
    }
    
    struct prompt {
        static let ok = "Tamam" 
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

    static var gatewayAddress = "3NCpyPuNzUaB7LFS4KBzwzWVnXmjur582oy"
    static var mainnetDataAddress = "3PPJ3ZDTWeyLoDWs6TsXWSuYZV3nqSR1xJm"
    static var mainnetGatewayAddress = "3P8UrCejM61VhTAHYJ5QmJ8PZquYp7otKNb"

    static var waves = coin.init(token: "",
                            symbol: "WAVES",
                            tokenName: "Waves",
                            decimal: 8,
                            network: "waves",
                            tokenSymbol: "Waves",
                            gatewayFee: 0)
//
 
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
    
    struct smartAccountMainnet {
        static let script = "base64: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"
        static let complexity =  793
        static let extraFee = 400000
    }
    
    struct smartAccount {
        static let script = "base64:BAQAAAALZGlnaWxpcmFQYXkBAAAAID0HOFHYXYpCB2C8RjDY8m3ndBlb8WihoYLw1tvHVwgrBAAAAAxzcG9uc29yVG9rZW4BAAAAIF0xC+0nwtqd1CxX9Y/+nUsawhMMb0TR82Wj5My6EPg+BAAAAAxwYXltZW50VG9rZW4BAAAAINUa1XJy5UC96rHuuRV8oDs9miGKfVUIoeiwBqYZd/niBAAAAApwcm94eVdhdmVzAQAAACALvZdwHed5WebRs21jKDRN9242fzutjnj6yaz93a9NdwQAAAAGYmFubmVkAAAAAAAABiY4BAAAAApLWUNQZW5kaW5nAAAAAAAAAAAABAAAABBub25GdW5naWJsZUJsb2NrAAAAAAAAAABkBAAAAA10cmFuc2ZlckJsb2NrAAAAAAAAAABkBAAAAAxwYXltZW50QmxvY2sAAAAAAAAAAMgEAAAACWZ1bmRCbG9jawAAAAAAAAABLAQAAAAQcGF5bWVudEZ1bmRCbG9jawAAAAAAAAABkAQAAAAKdXBwZXJCbG9jawAAAAAAAAAB9AQAAAAHJG1hdGNoMAUAAAACdHgDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAE1RyYW5zZmVyVHJhbnNhY3Rpb24EAAAAAXcFAAAAByRtYXRjaDAEAAAACG15U3RhdHVzCQAEGgAAAAIJAQAAABRhZGRyZXNzRnJvbVB1YmxpY0tleQAAAAEFAAAAC2RpZ2lsaXJhUGF5CQACWAAAAAEICAUAAAABdwAAAAZzZW5kZXIAAAAFYnl0ZXMEAAAABmlzVXNlcgkABBoAAAACCQEAAAAUYWRkcmVzc0Zyb21QdWJsaWNLZXkAAAABBQAAAAtkaWdpbGlyYVBheQkAAlgAAAABCAkABCQAAAABCAUAAAABdwAAAAlyZWNpcGllbnQAAAAFYnl0ZXMEAAAACGZlZVRva2VuCAUAAAABdwAAAApmZWVBc3NldElkBAAAAAlmZWVBbW91bnQIBQAAAAF3AAAAA2ZlZQQAAAAFYXNzZXQJAQAAAAt2YWx1ZU9yRWxzZQAAAAIIBQAAAAF3AAAAB2Fzc2V0SWQFAAAACnByb3h5V2F2ZXMEAAAAB2lzQXNzZXQJAAQaAAAAAgkBAAAAFGFkZHJlc3NGcm9tUHVibGljS2V5AAAAAQUAAAALZGlnaWxpcmFQYXkJAAJYAAAAAQUAAAAFYXNzZXQDCQEAAAAJaXNEZWZpbmVkAAAAAQUAAAAGaXNVc2VyAwkBAAAACWlzRGVmaW5lZAAAAAEFAAAACGZlZVRva2VuAwkAAAAAAAACBQAAAAhmZWVUb2tlbgUAAAAMc3BvbnNvclRva2VuAwkBAAAACWlzRGVmaW5lZAAAAAEFAAAAB2lzQXNzZXQDCQAAAAAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAkAAAIAAAABAgAAACBUaGlzIGFzc2V0IGNhbm5vdCBiZSB0cmFuc2ZlcmVkLgMDCQAAZwAAAAIJAQAAAAt2YWx1ZU9yRWxzZQAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAUAAAANdHJhbnNmZXJCbG9jawkAAGcAAAACBQAAAAp1cHBlckJsb2NrCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQHAwkAAGcAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAZpc1VzZXIAAAAAAAAAAAAJAQAAAAt2YWx1ZU9yRWxzZQAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAYJAAACAAAAAQIAAAA9VG8gdHJhbnNmZXIgdGhpcyBhc3NldCB1c2VyIHBlcm1pc3Npb24gbXVzdCBiZSBzZXQgY29ycmVjdGx5LgkAAAIAAAABAgAAACRUcmFuc2ZlciBpcyBub3QgYXZhaWxhYmxlIHJpZ2h0IG5vdy4GAwkAAAAAAAACBQAAAAhmZWVUb2tlbgUAAAAMcGF5bWVudFRva2VuAwkAAAAAAAACCAUAAAABdwAAAAlyZWNpcGllbnQJAQAAABRhZGRyZXNzRnJvbVB1YmxpY0tleQAAAAEFAAAAC2RpZ2lsaXJhUGF5AwkAAAAAAAACBQAAAAhteVN0YXR1cwUAAAAKS1lDUGVuZGluZwkAAAIAAAABAgAAAAtLWUMgUGVuZGluZwMJAAAAAAAAAgUAAAAIbXlTdGF0dXMFAAAABmJhbm5lZAkAAAIAAAABAgAAABxBY2NvdW50IEJhbm5lZCBDYW4ndCBPcGVyYXRlAwkAAGYAAAACBQAAAAlmZWVBbW91bnQAAAAAAAAAAAoJAAACAAAAAQIAAAALTm90IEFsbG93ZWQDCQAAAAAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAkAAAIAAAABAgAAAB1DYW4gbm90IHRyYW5zZmVyIHRoaXMgYXNzZXQgMwMDAwkAAGcAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQFAAAADHBheW1lbnRCbG9jawkAAGcAAAACBQAAAAlmdW5kQmxvY2sJAQAAAAt2YWx1ZU9yRWxzZQAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAcGAwkAAGcAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQFAAAAEHBheW1lbnRGdW5kQmxvY2sJAABnAAAAAgUAAAAKdXBwZXJCbG9jawkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAHaXNBc3NldAUAAAAGYmFubmVkBwMJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAIbXlTdGF0dXMAAAAAAAAAAAAJAQAAAAt2YWx1ZU9yRWxzZQAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAYJAAACAAAAAQIAAAAlVGhpcyBhc3NldCBoYXMgc3BlY2lhbCByZXF1aXJlbWVudHMgMgkAAAIAAAABAgAAAB1DYW4gbm90IHRyYW5zZmVyIHRoaXMgYXNzZXQgNAkAAAIAAAABAgAAADZVbmZvcnR1bmF0ZWx5IHlvdSBjYW4gb25seSB1c2UgdGhpcyB0b2tlbiBmb3IgcGF5bWVudHMDCQEAAAAJaXNEZWZpbmVkAAAAAQUAAAAHaXNBc3NldAMJAAAAAAAAAgUAAAAHaXNBc3NldAUAAAAGYmFubmVkCQAAAgAAAAECAAAAHUNhbiBub3QgdHJhbnNmZXIgdGhpcyBhc3NldCA1AwkAAGcAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAZpc1VzZXIAAAAAAAAAAAAJAQAAAAt2YWx1ZU9yRWxzZQAAAAIFAAAAB2lzQXNzZXQFAAAABmJhbm5lZAYJAAACAAAAAQIAAAAlVGhpcyBhc3NldCBoYXMgc3BlY2lhbCByZXF1aXJlbWVudHMgNQYDCQEAAAAJaXNEZWZpbmVkAAAAAQUAAAAHaXNBc3NldAMJAAAAAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAHaXNBc3NldAAAAAAAAAAAAAUAAAAGYmFubmVkCQAAAgAAAAECAAAAG0NhbiBub3QgdHJhbnNmZXIgdGhpcyBhc3NldAMJAABnAAAAAgkBAAAAC3ZhbHVlT3JFbHNlAAAAAgUAAAAGaXNVc2VyAAAAAAAAAAAACQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQGCQAAAgAAAAECAAAAJVRoaXMgYXNzZXQgaGFzIHNwZWNpYWwgcmVxdWlyZW1lbnRzIDEGAwkBAAAACWlzRGVmaW5lZAAAAAEFAAAAB2lzQXNzZXQDAwkAAGcAAAACCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQFAAAADXRyYW5zZmVyQmxvY2sJAABnAAAAAgUAAAAJZnVuZEJsb2NrCQEAAAALdmFsdWVPckVsc2UAAAACBQAAAAdpc0Fzc2V0BQAAAAZiYW5uZWQHBgkAAAIAAAABAgAAADVDYW5ub3QgdHJhbnNmZXIgdGhpcyB0b2tlbiB0byBub25lIERpZ2lsaXJhUGF5IHVzZXJzLgMJAQAAAAlpc0RlZmluZWQAAAABBQAAAAhmZWVUb2tlbgMJAAAAAAAAAgUAAAAIZmVlVG9rZW4FAAAADHNwb25zb3JUb2tlbgkAAAIAAAABAgAAADtDYW5ub3QgdXNlIHRoaXMgdG9rZW4gZm9yIG5vbmUgRGlnaWxpcmFQYXkgdXNlcnMgdHJhbnNmZXJzLgMJAAAAAAAAAgUAAAAIZmVlVG9rZW4FAAAADHBheW1lbnRUb2tlbgkAAAIAAAABAgAAADZVbmZvcnR1bmF0ZWx5IHlvdSBjYW4gb25seSB1c2UgdGhpcyB0b2tlbiBmb3IgcGF5bWVudHMGBgMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAABU9yZGVyBgMJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAQTGVhc2VUcmFuc2FjdGlvbgYJAAABAAAAAgUAAAAHJG1hdGNoMAIAAAAPQnVyblRyYW5zYWN0aW9uBAAAAAF4BQAAAAckbWF0Y2gwBwMDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAD0RhdGFUcmFuc2FjdGlvbgYDCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAE0V4Y2hhbmdlVHJhbnNhY3Rpb24GCQAAAQAAAAIFAAAAByRtYXRjaDACAAAAFFNldFNjcmlwdFRyYW5zYWN0aW9uBAAAAAF0BQAAAAckbWF0Y2gwCQAB9AAAAAMIBQAAAAF0AAAACWJvZHlCeXRlcwkAAZEAAAACCAUAAAABdAAAAAZwcm9vZnMAAAAAAAAAAAEFAAAAC2RpZ2lsaXJhUGF5AwkAAAEAAAACBQAAAAckbWF0Y2gwAgAAABdNYXNzVHJhbnNmZXJUcmFuc2FjdGlvbgQAAAADbXR0BQAAAAckbWF0Y2gwBwbt/UuB"
        static let complexity =  407
        static let extraFee = 400000
        
    }
    
    struct legalView {
        static let title = "Aydınlatma Metni"
        static let text = """
        Üye olmanız halinde DIGILIRAPAY TEKNOLOJİ ANONİM ŞİRKETİ  ('DigiliraPay'), ad soyad, elektronik posta, cep telefonu, cinsiyet (isteğe bağlı) ve doğum tarihine ait kişisel verilerinizi ve üyeliğiniz sırasında gerçekleştireceğiniz işlemler neticesinde paylaşacağınız Kişisel Verilerin İşlenmesi ve Korunması Politikası'nda ('Politika') belirtilen diğer verilerinizi (2.A. Maddesi); başta üyelik işlemlerinin gerçekleştirilmesi, sorun ve şikâyetlerinizin çözümlenmesi, ticari elektronik ileti onayınızı vermişseniz hizmetlerimize ilişkin haberlere, bilgilere ve güncellemelere, tekliflerimize ve özel etkinliklerle ilgili ve ilginizi çekebilecek diğer pazarlama iletişimlerini gönderme amaçları olmak üzere Politika'da yer alan diğer amaçlar (2.B. Maddesi) için işleyecektir. Kişisel verileriniz; iş geliştirme hizmetlerinin sağlanması, istatistiksel ve teknik hizmetlerin temini ve müşteri ilişkilerinin yürütülmesi, arşivleme ve depolama amacıyla yurt dışında bulunan bilişim teknolojileri desteği alınan sunucular, hosting şirketleri, bulut bilişim gibi elektronik ortamlara aktarılması için ve Politikada yer alan Kişisel Verilerin Yurt dışına Aktarılması (5.B. Maddesi) başlığı kapsamında diğer veri ve amaçlar uyarınca yurt dışındaki iş ortaklarımızla paylaşılacaktır. KVK Kanunu'nun 11.maddesi ve ilgili mevzuat uyarınca; Şirket’e başvurarak kendinizle ilgili; kişisel veri işlenip işlenmediğini öğrenme ve Politika’da yer alan Veri Sahibinin Haklarının Gözetilmesi (8. Madde) kapsamında diğer haklarınızı ve DigiliraPay’e başvuru yollarınızı öğrenebilirsiniz. Detaylı bilgiye Kişisel Verilerin İşlenmesi ve Korunması Politikası'ndan ulaşabilirsiniz.
        """
        static let version = 4
    }
    
    struct termsOfUse {
        static let title = "Kullanım Sözleşmesi"
        static let text = "Yaygın inancın tersine, Lorem Ipsum rastgele sözcüklerden oluşmaz. Kökleri M.Ö. 45 tarihinden bu yana klasik Latin edebiyatına kadar uzanan 2000 yıllık bir geçmişi vardır. Virginia'daki Hampden-Sydney College'dan Latince profesörü Richard McClintock, bir Lorem Ipsum pasajında geçen ve anlaşılması en güç sözcüklerden biri olan 'consectetur' sözcüğünün klasik edebiyattaki örneklerini incelediğinde kesin bir kaynağa ulaşmıştır. Lorm Ipsum, Çiçero tarafından M.Ö. 45 tarihinde kaleme alınan 'de Finibus Bonorum et Malorum' (İyi ve Kötünün Uç Sınırları) eserinin 1.10.32 ve 1.10.33 sayılı bölümlerinden gelmektedir. Bu kitap, ahlak kuramı üzerine bir tezdir ve Rönesans döneminde çok popüler olmuştur. Lorem Ipsum pasajının ilk satırı olan 'Lorem ipsum dolor sit amet' 1.10.32 sayılı bölümdeki bir satırdan gelmektedir. 1500'lerden beri kullanılmakta olan standard Lorem Ipsum metinleri ilgilenenler için yeniden üretilmiştir. Çiçero tarafından yazılan 1.10.32 ve 1.10.33 bölümleri de 1914 H. Rackham çevirisinden alınan İngilizce sürümleri eşliğinde özgün biçiminden yeniden üretilmiştir.-"
        static let version = 10
    }
    
    struct terms: Encodable {
        var title: String
        var text: String
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
        let dogum: String?
        let v: Int?
        let appV: Double?
        let id1: String?
        var isAuthorized: Int?

        enum CodingKeys: String, CodingKey {
            case userRole, status, pincode, imported, apnToken
            case id = "_id"
            case lastName, firstName, wallet, btcAddress, ethAddress, tetherAddress, ltcAddress, createdDate, appV, id1, dogum, tcno, tel, mail, isAuthorized
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
        let l2:String
        let l3:String
        let l4:String
        let l5:String
        let l6:String
        let yes:String?
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
        case anErrorOccured
        case missingParameters
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




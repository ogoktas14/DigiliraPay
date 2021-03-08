//
//  bitexenSignature.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 28.10.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import CommonCrypto

class bex: NSObject {
    
    private var isCertificatePinning: Bool = true
    private var cert: String = digilira.sslPinning.bexCert

    var onBitexenBalance: ((_ result: bexBalance, _ statusCode: Int?)->())?
    var onBitexenTicker: ((_ result: bexAllTicker, _ statusCode: Int?)->())?
    var onBitexenTickerCoin: ((_ result: bexTicker, _ statusCode: Int?)->())?
    var onBitexenMarketInfo: ((_ result: bexMarketInfo, _ statusCode: Int?)->())?
    var onBitexenError: ((_ result: String, _ statusCode: Int?)->())?
    
    struct bexApiDefaultKey {
        static let key = "bitexenAPI2"
        static let testKey = "bitexenAPI3"
    }
    
    struct bitexenAPICred: Codable {
        var apiKey: String
        var apiSecret: String
        var passphrase: String
        var username: String
        var valid: Bool = false
    }
    
    // MARK: - bexTicker
    struct bexTicker: Codable {
        let status: String
        let data: DataClass
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let ticker: Ticker
    }
    
    // MARK: - bexAllTicker
    struct bexAllTicker: Codable {
        let status: String
        let data: AllDataClass
    }
    
    // MARK: - AllDataClass
    struct AllDataClass: Codable {
        let ticker: [String: Ticker]
    }
    
    
    // MARK: - Ticker
    struct Ticker: Codable {
        let market: Market
        let bid, ask, lastPrice, lastSize: String
        let volume24H, change24H, low24H, high24H: String
        let avg24H, timestamp: String
        
        enum CodingKeys: String, CodingKey {
            case market, bid, ask
            case lastPrice = "last_price"
            case lastSize = "last_size"
            case volume24H = "volume_24h"
            case change24H = "change_24h"
            case low24H = "low_24h"
            case high24H = "high_24h"
            case avg24H = "avg_24h"
            case timestamp
        }
    }
    
    // MARK: - Market
    struct Market: Codable {
        let marketCode, baseCurrencyCode, counterCurrencyCode: String
        
        enum CodingKeys: String, CodingKey {
            case marketCode = "market_code"
            case baseCurrencyCode = "base_currency_code"
            case counterCurrencyCode = "counter_currency_code"
        }
    }
    
    // MARK: - bexBalance
    struct bexBalance: Codable {
        let status: String
        let data: DataClassBalance
    }
    
    // MARK: - DataClass
    struct DataClassBalance: Codable {
        let balances: [String: BalanceValue]
    }
    
    // MARK: - BalanceValue
    struct BalanceValue: Codable {
        let currencyCode, balance, availableBalance: String
        
        enum CodingKeys: String, CodingKey {
            case currencyCode = "currency_code"
            case balance
            case availableBalance = "available_balance"
        }
    }
    
    enum CounterCurrencyCode: String, Codable {
        case btc = "BTC"
        case counterCurrencyCodeTRY = "TRY"
        case usdt = "USDT"
    }
    
    
    // MARK: - bexMarketInfo
    struct bexMarketInfo: Codable {
        let status: String
        let data: MarketDataClass
    }
    
    // MARK: - DataClass
    struct MarketDataClass: Codable {
        let markets: [Markets]
    }
    
    // MARK: - Market
    struct Markets: Codable {
        let marketCode, urlSymbol, baseCurrency: String
        let counterCurrency: CounterCurrency
        let minimumOrderAmount, maximumOrderAmount: String
        let baseCurrencyDecimal, counterCurrencyDecimal, presentationDecimal: Int
        let resellMarket: Bool
        
        enum CodingKeys: String, CodingKey {
            case marketCode = "market_code"
            case urlSymbol = "url_symbol"
            case baseCurrency = "base_currency"
            case counterCurrency = "counter_currency"
            case minimumOrderAmount = "minimum_order_amount"
            case maximumOrderAmount = "maximum_order_amount"
            case baseCurrencyDecimal = "base_currency_decimal"
            case counterCurrencyDecimal = "counter_currency_decimal"
            case presentationDecimal = "presentation_decimal"
            case resellMarket = "resell_market"
        }
    }
    
    enum CounterCurrency: String, Codable {
        case btc = "BTC"
        case counterCurrencyTRY = "TRY"
        case usdt = "USDT"
    }
    
 

    // MARK: - Properties
    struct MakePayment: Codable {
        let paymentID, amount, currencyCode, counterAmount: String
        let counterCurrencyCode, merchantCode, merchantMcc, merchantName: String

        enum CodingKeys: String, CodingKey {
            case paymentID = "payment_id"
            case amount
            case currencyCode = "currency_code"
            case counterAmount = "counter_amount"
            case counterCurrencyCode = "counter_currency_code"
            case merchantCode = "merchant_code"
            case merchantMcc = "merchant_mcc"
            case merchantName = "merchant_name"
        }
    }

    // MARK: - MakePaymentResponse
    struct MakePaymentResponse: Codable {
        let status: String
        let data: MakePaymentDataClass
    }

    // MARK: - DataClass
    struct MakePaymentDataClass: Codable {
        let paymentID: String

        enum CodingKeys: String, CodingKey {
            case paymentID = "payment_id"
        }
    }
    
 
    // MARK: - CommitPayment
    struct CommitPayment: Codable {
        let paymentID: String

        enum CodingKeys: String, CodingKey {
            case paymentID = "payment_id"
        }
    }


    var apiLogin: bitexenAPICred?
    
    func loginInit(params: bitexenAPICred) -> bitexenAPICred{
        apiLogin?.apiKey = params.apiKey
        apiLogin?.apiSecret = params.apiSecret
        apiLogin?.passphrase = params.passphrase
        apiLogin?.username = params.username
        
        return apiLogin!
    }
    
    public func signHmac (keys: bitexenAPICred, params:String) ->  (String, String) {
        let timestamp = String(Int64(Date().timeIntervalSince1970) * 1000)
        let text = (keys.apiKey) + (keys.username) + (keys.passphrase) + String(timestamp) + params
        let hmac = text.hmac(algorithm: .SHA256, key: (keys.apiSecret)).uppercased()
        return (hmac, timestamp)
    }
    
    private func getUrl() -> String {
        let chain = try! digiliraPayApi().getChain()
        switch chain {
        case "T":
            cert = digilira.sslPinning.bexTestCert
            return digilira.bexURL.baseTestUrl
        default:
            cert = digilira.sslPinning.bexCert
            return digilira.bexURL.baseUrl
        }
    }
    
    public func getTicker(coin: String = "") {
        var apiURL = getUrl() + digilira.bexURL.ticker + coin
        if coin != "" {
            apiURL = apiURL + "/"
        }

        request(rURL: apiURL,
                METHOD: req.method.get, returnCompletion: { (json, statusCode) in
                    DispatchQueue.main.async {
                        
                        switch coin {
                        case "":
                            if let marketInfo = self.decodeDefaults(forKey: json!, conformance: bexAllTicker.self) {
                                self.onBitexenTicker!(marketInfo, statusCode)
                                return
                            }
                            break
                        default:
                            
                            if let marketInfo = self.decodeDefaults(forKey: json!, conformance: bexTicker.self) {
                                self.onBitexenTickerCoin!(marketInfo, statusCode)
                                return
                            }
                            break
                        }
                        self.onBitexenError!("parsingError", statusCode)
                    }
                })
    }
 
    
    public func makePayment(payment: MakePayment, keys: bitexenAPICred) {
        let encodedData = try? JSONEncoder().encode(payment)
        let jsonString = String(data: encodedData!,
                                encoding: .utf8)
        let (hmac, timestamp) = signHmac(keys: keys, params: jsonString!)

        request(rURL: getUrl() + digilira.bexURL.makePayment,
                JSON: payment.data, METHOD: req.method.post,
                AUTH: keys,
                TIMESTAMP: timestamp,
                HMAC: hmac,
                PAYMENT: true,
                returnCompletion: { (json, statusCode) in
//                    let jsonResponse = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(json)) as! Dictionary<String, AnyObject>

                    DispatchQueue.main.async {
                        if let ticker = self.decodeDefaults(forKey: json!, conformance: MakePaymentResponse.self) {
                             print(ticker)
                            //.onBitexenBalance!(ticker, statusCode)
                            return
                        }
                        //self.onBitexenError!("parsingError", statusCode)
                    }
                })
    }
    
    public func getMarketInfo() {
        let apiURL = getUrl() + digilira.bexURL.marketInfo
        
        request(rURL: apiURL,
                METHOD: req.method.get, returnCompletion: { (json, statusCode) in
                    DispatchQueue.main.async {
                        if let marketInfo = self.decodeDefaults(forKey: json!, conformance: bexMarketInfo.self) {
                            self.onBitexenMarketInfo!(marketInfo, statusCode)
                            return
                        }
                        self.onBitexenError!("parsingError", statusCode)
                    }
                })
    }
    
    public func getBalances(keys: bitexenAPICred) {
        
        let (hmac, timestamp) = signHmac(keys: keys, params: "{}")
        
        request(rURL: getUrl() + digilira.bexURL.balances,
                METHOD: req.method.get,
                AUTH: keys,
                TIMESTAMP: timestamp,
                HMAC: hmac,
                returnCompletion: { (json, statusCode) in
                    
                    DispatchQueue.main.async {
                        if let ticker = self.decodeDefaults(forKey: json!, conformance: bexBalance.self) {
                            self.onBitexenBalance!(ticker, statusCode)
                            return
                        }
                        self.onBitexenError!("parsingError", statusCode)
                    }
                })
    }
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) -> T? where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch let parsingError {
            print("Error", parsingError)
            return nil
        }
    }
    
    func request(rURL: String,
                 JSON: Data? = nil,
                 PARAMS: String = "",
                 METHOD: String,
                 AUTH: bitexenAPICred? = nil,
                 TIMESTAMP: String? = nil,
                 HMAC: String? = nil,
                 PAYMENT: Bool? = false,
                 returnCompletion: @escaping (Data?, Int?) -> ()) {
        
        var request = URLRequest(url: URL(string: rURL)!)
        
        request.httpMethod = METHOD
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if AUTH != nil {
            request.addValue(AUTH!.username, forHTTPHeaderField: "ACCESS-USER")
            request.addValue(AUTH!.passphrase, forHTTPHeaderField: "ACCESS-PASSPHRASE")
            request.addValue(TIMESTAMP!, forHTTPHeaderField: "ACCESS-TIMESTAMP")
            request.addValue(HMAC!, forHTTPHeaderField: "ACCESS-SIGN")

            if PAYMENT! {
                request.addValue(AUTH!.apiKey, forHTTPHeaderField: "ACCESS-APIKEY")
                request.addValue("DIGILIRAPAY", forHTTPHeaderField: "ACCESS-B2B-CHANNEL-NAME")
                request.addValue("DIGILIRAPAY", forHTTPHeaderField: "ACCESS-B2B-APP-NAME")
                request.addValue(AUTH!.apiKey, forHTTPHeaderField: "ACCESS-KEY")


            }else {
                request.addValue(AUTH!.apiKey, forHTTPHeaderField: "ACCESS-KEY")
            }
            
        }
        
        if JSON != nil {
            request.httpBody = JSON
        }
        
        if PARAMS != "" {
            request.url?.appendPathComponent(PARAMS, isDirectory: true)
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
                self.onBitexenError!("SSL PINNING MISMATCH", httpResponse?.statusCode)
            } else if data != nil {
                
                guard let dataResponse = data,
                      error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
                
                returnCompletion(dataResponse, httpResponse?.statusCode)
            }
        }
        task.resume()
    }
}

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate()
        
        return digest
    }
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash).lowercased()
    }
}

extension bex: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        if self.isCertificatePinning {
            
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            
            let policy = NSMutableArray()
            policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            let remoteCertificateData:NSData =  SecCertificateCopyData(certificate!)
            let pathToCertificate = Bundle.main.path(forResource: cert, ofType: digilira.sslPinning.fileType)
            let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
            
            //Compare certificates
            if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
                let credential:URLCredential =  URLCredential(trust:serverTrust)
                
                completionHandler(.useCredential,credential)
            }
            else{
                completionHandler(.cancelAuthenticationChallenge,nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge,nil)
        }
    }
    
}

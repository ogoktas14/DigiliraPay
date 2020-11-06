//
//  bitexenSignature.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 28.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import CommonCrypto


class bitexenSignature {
    var onBitexenBalance: ((_ result: [String : Any], _ statusCode: Int?)->())?
    
    var apiLogin: digilira.bitexenAPICred?
    
    func loginInit(params: digilira.bitexenAPICred) -> digilira.bitexenAPICred{
        apiLogin?.apiKey = params.apiKey
        apiLogin?.apiSecret = params.apiSecret
        apiLogin?.passphrase = params.passphrase
        apiLogin?.username = params.username
        
        return apiLogin!
    }
    
    public func signHmac (keys: digilira.bitexenAPICred) {
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let text = (keys.apiKey)! + (keys.username)! + (keys.passphrase)! + String(timestamp) + "{}"
        var hmac = text.hmac(algorithm: .SHA256, key: (keys.apiSecret)!)
        print(hmac)

    }
    
    public func getBalances(keys: digilira.bitexenAPICred) {
        let timestamp = Int64(Date().timeIntervalSince1970) * 1000
        
        let text = (keys.apiKey)! + (keys.username)! + (keys.passphrase)! + String(timestamp) + "{}"
        let hmac = text.hmac(algorithm: .SHA256, key: (keys.apiSecret)!).uppercased()
        
        let balance = "/api/v1/balance/"
        let baseURL = "https://www.bitexen.com"
        
        request(rURL: baseURL + balance, METHOD: "GET", AUTH: keys, TIMESTAMP: String(timestamp), HMAC: hmac, returnCompletion: { (json, statusCode) in
            
            DispatchQueue.main.async {
                self.onBitexenBalance!(json, statusCode)
            }
        }
        )
    }
    
    func request(rURL: String, JSON: Data? = nil,
                 PARAMS: String = "", METHOD: String, AUTH: digilira.bitexenAPICred, TIMESTAMP: String, HMAC: String,
                 returnCompletion: @escaping ([String:Any], Int?) -> ()) {
        
        var request = URLRequest(url: URL(string: rURL)!)
        
        request.httpMethod = METHOD
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(AUTH.username!, forHTTPHeaderField: "ACCESS-USER")
        request.addValue(AUTH.passphrase!, forHTTPHeaderField: "ACCESS-PASSPHRASE")
        request.addValue(TIMESTAMP, forHTTPHeaderField: "ACCESS-TIMESTAMP")
        request.addValue(HMAC, forHTTPHeaderField: "ACCESS-SIGN")
        request.addValue(AUTH.apiKey!, forHTTPHeaderField: "ACCESS-KEY")
        
        if JSON != nil {
            request.httpBody = JSON
        }
        
        if PARAMS != "" {
            request.url?.appendPathComponent(PARAMS, isDirectory: true)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            guard let dataResponse = data,
                  error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse) as! Dictionary<String, AnyObject>
                
                returnCompletion(jsonResponse, httpResponse?.statusCode)
                
            } catch let parsingError {
                print("Error", parsingError)
                returnCompletion([:], httpResponse?.statusCode)
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
        //result.deallocate(capacity: digestLen)

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

//const crypto = require('crypto');
//const baseurl = "https://www.bitexen.com/api/v1/balance/";
//const axios = require("axios");
//var https = require('https');
//
//
//var apiKey = "aBEn6jMErPH7en0fDj5L4g"
//var apiSecret = "rj1Yy-X4cIY1kydfcYXb5A"
//var apiPassphrase = "WHATISTHISFIELD"
//var apiUsername = "serkan@digilirapay.com"
//
//var time = Date.now();
//var message = apiKey + apiUsername + apiPassphrase + time + "{}";
//var hmac = crypto.createHmac('sha256', apiSecret).update(message).digest('hex').toUpperCase()
//
//var header = {
//    "ACCESS-USER": apiUsername,
//    "ACCESS-PASSPHRASE": apiPassphrase,
//    "ACCESS-TIMESTAMP": time.toString(),
//    "ACCESS-SIGN": hmac,
//    "ACCESS-KEY": apiKey,
//    "Content-Type": "application/json"
//}
//
//function getBalance() {
//
//    try {
//        const url = baseurl;
//        const getData = async url => {
//            try {
//                const response = await axios.get(url, { headers: header });
//                const data = response.data;
//                console.log(data)
//            } catch (error) {
//                console.log(error.response.data);
//            }
//        };
//        getData(url);
//    } catch (error) {
//        console.log('HATA');
//        resolve("hata");
//    }
//
//}
//
//getBalance()



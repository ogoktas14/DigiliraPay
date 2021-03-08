//
//  binance.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 16.11.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation


class binance: NSObject {
    private var isCertificatePinning: Bool = true
    var onBinanceError: ((_ result: String, _ statusCode: Int?)->())?
    var onBinanceTicker: ((_ result: BinanceMarketInfo, _ statusCode: Int?)->())?

    // MARK: - MarketInfoElement
    struct BinanceMarketInfoElement: Codable {
        let symbol, price: String
    }

    typealias BinanceMarketInfo = [BinanceMarketInfoElement]
    
    func request(rURL: String,
                 METHOD: String,
                 returnCompletion: @escaping (Data?, Int?) -> ()) {
        
        var request = URLRequest(url: URL(string: rURL)!)
        
        request.httpMethod = METHOD
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
//                print("error: \(error!.localizedDescription): \(error!)")
                self.onBinanceError!("SSL PINNING MISMATCH", 0)
                
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
        
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) -> T? where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch let parsingError {
            print("Error", parsingError)
            return nil
        }
    }
        
    
    public func getTicker() {
        let apiURL = digilira.binanceURL.baseUrl + digilira.binanceURL.ticker
        
        request(rURL: apiURL,
                METHOD: req.method.get, returnCompletion: { (json, statusCode) in
            DispatchQueue.main.async {
                
                if let marketInfo = self.decodeDefaults(forKey: json!, conformance: BinanceMarketInfo.self) {
                    self.onBinanceTicker!(marketInfo, statusCode)
                    return
                }  else {
                    self.onBinanceError!("parsingError", statusCode)
                    return
                }
                 
            }
        })
    }

}

extension binance: URLSessionDelegate {
   
   func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       
       guard let serverTrust = challenge.protectionSpace.serverTrust else {
           completionHandler(.cancelAuthenticationChallenge, nil);
           return
       }
       
       if self.isCertificatePinning {
            
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
           // SSL Policies for domain name check
           let policy = NSMutableArray()
           policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
           
           //evaluate server certifiacte
           let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
           
           //Local and Remote certificate Data
           let remoteCertificateData:NSData =  SecCertificateCopyData(certificate!)
           //let LocalCertificate = Bundle.main.path(forResource: "github.com", ofType: "cer")
            let pathToCertificate = Bundle.main.path(forResource: digilira.sslPinning.binance, ofType: digilira.sslPinning.fileType)
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

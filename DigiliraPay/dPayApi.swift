//
//  digiliraPayApi.swift
//  com.pilldigital.test
//
//  Created by Hayrettin İletmiş on 18.08.2019.
//  Copyright © 2019 hiletmis. All rights reserved.
//

import Foundation
import WavesSDK
import WavesSDKCrypto
import RxSwift
import Locksmith
import QRCoder
import LocalAuthentication

class digiliraPayApi: NSObject {
    private var isCertificatePinning: Bool = true
    
    var token:String?
    
    var onTouchID: ((_ result: Bool, _ status: String)->())?
    var onResponse: ((_ result: [String:Any], _ statusCode: Int?)->())?
    var onUpdate: ((_ result: Bool)->())?
    var onTicker: ((_ result: String)->())?
    
    var crud = centralRequest()
    var throwEngine = ErrorHandling()
    
    func touchID(reason: String) {
        let context = LAContext()
        var error: NSError?
        UserDefaults.standard.setValue(true, forKey: "biometrics")
        if let isSecure = UserDefaults.standard.value(forKey: "isSecure") as? Bool
        {
            if isSecure == false {
                DispatchQueue.main.async {
                    self.onTouchID!(false, "Fallback authentication mechanism selected.")
                }
                return
            }
        } else {
            DispatchQueue.main.async {
                self.onTouchID!(false, "Fallback authentication mechanism selected.")
            }
            return
        }
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self?.onTouchID!(true, "ok")
                    } else {
                        self?.onTouchID!(false, authenticationError!.localizedDescription)
                    }
                    UserDefaults.standard.setValue(false, forKey: "biometrics")
                }
            }
        } else {
            self.onTouchID!(false, "Fallback authentication mechanism selected.")
        }
    }
    
    func getKeyChainSource() throws -> digilira.keychainData {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw digilira.NAError.emptyAuth }
        switch chainId {
        case "T":
            return digilira.keychainData.init(authenticateData: "authenticate", sensitiveData: "sensitive", wavesToken: "wavesToken")
        case "W":
            return digilira.keychainData.init(authenticateData: "authenticateMainnet", sensitiveData: "sensitiveMainnet", wavesToken: "wavesTokenMainnet")
        default:
            throw digilira.NAError.emptyAuth
        }
    }
    
    func updateUser(user: Data?) {
        crud.onError = { error, sts in
            self.onUpdate!(false)
        }
        crud.onResponse = { [self] data, sts in
            switch sts {
            case 200:
                do {
                    if secretKeys.LocksmithSave(forKey: try getKeyChainSource().authenticateData, data: data) {
                        self.onUpdate!(true)
                    } else {
                        self.onUpdate!(false)
                    }
                    
                } catch  {
                    print(error)
                }
                break
            case 502:
                self.onUpdate!(false)
                break
            default:
                self.onUpdate!(false)
            }
        } 
        crud.request(rURL: crud.getApiURL() + digilira.api.userUpdate, postData: user, method: req.method.put)
    }
    
    func updateSmartAcountScript(data: Data) {
        crud.onError = { error, sts in }
        crud.onResponse = { res, sts in
            if (sts == 200) {
                print(res)
            }else {
                print("fail")
            }
        }
        crud.request(rURL: crud.getApiURL() + digilira.api.userUpdate, postData: data, method: req.method.put)
    }
    
    func saveTransactionTransfer(JSON : Data?) {
        crud.request(rURL: crud.getApiURL() + digilira.api.transferNew, postData: JSON, isReturn: false)
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func ticker (ticker: binance.BinanceMarketInfo) -> digilira.ticker {
        var btcUsdtPrice: Double = 0
        var ethUsdtPrice: Double = 0
        var wavesUsdtPrice: Double = 0
        var tryUsdtPrice: Double = 0
        
        for ticks in ticker {
            switch ticks.symbol {
            case "BTCUSDT":
                if let doublePrice = Double(ticks.price) {
                    btcUsdtPrice = doublePrice
                }
                break
            case "ETHUSDT":
                if let doublePrice = Double(ticks.price) {
                    ethUsdtPrice = doublePrice
                }
                break
            case "WAVESUSDT":
                if let doublePrice = Double(ticks.price) {
                    wavesUsdtPrice = doublePrice
                }
                break
            case "USDTTRY":
                if let doublePrice = Double(ticks.price) {
                    tryUsdtPrice = doublePrice
                }
                break
            default:
                break
            }
        }
        
        let res = digilira.ticker.init(ethUSDPrice: ethUsdtPrice,
                                       btcUSDPrice: btcUsdtPrice,
                                       wavesUSDPrice: wavesUsdtPrice,
                                       usdTLPrice: tryUsdtPrice
        )
        return res
    }
    
    func ratePrice(price: Double, asset: String, symbol: digilira.ticker, digits: Int, network: String) throws -> (Double, String, Double) {
        let double = Double(truncating: pow(10,digits) as NSNumber)
        
        switch network {
        case "waves":
            switch asset {
            case digilira.bitcoin.tokenName:
                
                if let tl = symbol.usdTLPrice {
                    if let btc = symbol.btcUSDPrice {
                        let tick = (btc * tl)
                        let result = price / tick
                        return (Double(round(double * result)), digilira.bitcoin.token, tick)
                    }
                }
            case digilira.ethereum.tokenName:
                if let tl = symbol.usdTLPrice {
                    if let eth = symbol.ethUSDPrice {
                        let tick = (eth * tl)
                        let result = price / tick
                        return (Double(round(double * result)), digilira.ethereum.token, tick)
                    }
                }
            case digilira.waves.tokenName:
                if let tl = symbol.usdTLPrice {
                    if let waves = symbol.wavesUSDPrice {
                        let tick = (waves * tl)
                        let result = price / tick
                        return (Double(round(double * result)), digilira.waves.token, tick)
                    }
                }
            case digilira.tetherWaves.tokenName:
                if let usdt = symbol.usdTLPrice {
                    let result = price / usdt
                    return (Double(round(double * result)), digilira.tetherWaves.token, usdt)
                }
            default:
                throw digilira.NAError.emptyAuth
            }
            
        case "bitexen":
            if let usdt = symbol.usdTLPrice {
                let result = price / usdt
                return (Double(round(double * result)), digilira.tetherWaves.token, usdt)
            }
            break
        default:
            break
        }
        throw digilira.NAError.emptyAuth
    }
    
    func exchange(amount: Int64, coin:digilira.coin, symbol:digilira.ticker) throws -> Double {
        let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
        let amountFloat = Double.init(Double.init(amount) / double)
        
        switch coin.network {
        case digilira.bitcoin.network:
            return amountFloat  * symbol.btcUSDPrice! * symbol.usdTLPrice!
        case digilira.ethereum.network:
            return amountFloat * symbol.ethUSDPrice! * symbol.usdTLPrice!
        case digilira.waves.network:
            switch coin.token {
            case digilira.waves.token:
                return amountFloat * symbol.wavesUSDPrice! * symbol.usdTLPrice!
            default:
                throw digilira.NAError.emptyAuth
            }
        default:
            throw digilira.NAError.emptyAuth
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func wipeOut () {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: bex.bexApiDefaultKey.key)
        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "sensitive")
        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "authenticate")
        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "sensitiveMainnet")
        } catch  {
            print(error)
        }
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "authenticateMainnet")
        } catch  {
            print(error)
        }
        
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "environment")
        } catch  {
            print(error)
        }
        throwEngine.resetApp()
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

class OpenUrlManager {
    
    class func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }
    
    static var openUrl: URL?
    static var onURL: ((_ result: digilira.QR)->())?
    
    class func parseUrlParams(openUrl: URL?) {
        if openUrl?.absoluteString == nil {
            return
        }
        let array = openUrl!.absoluteString.components(separatedBy: CharacterSet.init(charactersIn: ":"))
        let caption = array[0]
        var amount: Int64? = 0
        var assetId: String = ""
        switch caption {
        case "file":
            
            if FileManager.default.fileExists(atPath: openUrl!.path) {
                let url = NSURL(string: openUrl!.absoluteString)
                let data = NSData(contentsOf: url! as URL)
                
                if let features = detectQRCode(UIImage(data: data! as Data)), !features.isEmpty{
                    for case let row as CIQRCodeFeature in features{
                        parseUrlParams(openUrl: URL(string: row.messageString!))
                    }
                } 
            }
            break;
        case "digilirapay":
            let digiliraURL = openUrl!.absoluteString.components(separatedBy: CharacterSet.init(charactersIn: "://"))
            if digiliraURL.count > 2 {
                if caption == "digilirapay" {
                    self.onURL!(digilira.QR.init(network: caption, address: digiliraURL[3]))
                }
            }
            break
        case "bitcoin", "ethereum":
            var data = array[1].components(separatedBy: "?amount=")
            
            if (data.count > 1) {
                if data[1] == ""{
                    data[1] = "0"
                }
                let double = Double(truncating: pow(10,8) as NSNumber)
                amount = Int64(Double.init(data[1])! * double)
            }
            self.onURL!(digilira.QR.init(network: caption, address: data[0], amount: amount))
            break
            
        case "waves":
            let data = array[1].components(separatedBy: "?amount=")
            var amountAssetId = data[1].components(separatedBy: "&assetId=")
            
            var amount: Int64? = 0
            if (amountAssetId.count > 1) {
                if amountAssetId[0] == ""{
                    amountAssetId[0] = "0"
                }
                let double = Double(truncating: pow(10,8) as NSNumber)
                amount = Int64(Double.init(amountAssetId[0])! * double)
                assetId = amountAssetId[1]
            }
            self.onURL!(digilira.QR.init(network: caption, address: data[0], amount: amount, assetId: assetId))
            
            break
        default:
            break
        }
    }
    
    class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var picker = UIImagePickerController();
        var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        var viewController: UIViewController?
        var pickImageCallback : ((UIImage) -> ())?;
        
        var accountVerifyImage: Bool = false
        
        override init(){
            super.init()
        }
        
        func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
            pickImageCallback = callback;
            self.viewController = viewController;
            
            let cameraAction = UIAlertAction(title: "Kamera", style: .default){
                UIAlertAction in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Galeri", style: .default){
                UIAlertAction in
                self.openGallery()
            }
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel){
                UIAlertAction in
            }
            
            picker.delegate = self
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            alert.addAction(cancelAction)
            alert.popoverPresentationController?.sourceView = self.viewController!.view
            viewController.present(alert, animated: true, completion: nil)
        }
        func openCamera(){
            alert.dismiss(animated: true, completion: nil)
            if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                picker.sourceType = .camera
                self.viewController!.present(picker, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Dikkat", message: "Kameranız bulunmamaktadır.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
                alert.show(self.viewController!, sender: nil)
            }
        }
        func openGallery(){
            alert.dismiss(animated: true, completion: nil)
            picker.sourceType = .photoLibrary
            self.viewController!.present(picker, animated: true, completion: nil)
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            guard let image = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            pickImageCallback?(image)
        }
        
        @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
            print("ok")
        }
        
    }
}

extension digiliraPayApi: URLSessionDelegate {
    
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
            let pathToCertificate = Bundle.main.path(forResource: digilira.sslPinning.cert, ofType: digilira.sslPinning.fileType)
            let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
            
            //Compare certificates
            if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
                let credential:URLCredential =  URLCredential(trust:serverTrust)
                
                completionHandler(.useCredential,credential)
            }
            else{
                completionHandler(.cancelAuthenticationChallenge,nil)
            }
        }
    }
    
}

class secretKeys: NSObject {
    let jsonEncoder = JSONEncoder()
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) -> T? where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch let parsingError {
            print("Error", parsingError)
            return nil
        }
    }
    
    class func userData() throws -> digilira.auth {
        var authenticateSource = "authenticate"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                authenticateSource = "authenticateMainnet"
            }
        }
        
        do {
            let data = try secretKeys.LocksmithLoad(forKey: authenticateSource, conformance: digilira.auth.self)
            return data
        } catch {
            throw digilira.NAError.emptyAuth
        }
    }
    
    class func LocksmithLoad<T>(forKey: String, conformance: T.Type, setNil: Bool = false) throws -> T where T: Decodable  {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: forKey) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                do{
                    let structData = try JSONDecoder().decode(conformance, from: jsonData)
                    return structData
                } catch let parsingError {
                    throw parsingError
                }
                
            } catch {
                throw digilira.NAError.emptyAuth
            }
        }
        throw digilira.NAError.emptyAuth
    }
    
    class func LocksmithSave(forKey: String, data: Data, setNil: Bool = false) -> Bool {
        
        if Locksmith.loadDataForUserAccount(userAccount: forKey) != nil {
            do {
                let buffer = try secretKeys.userData()
                do{
                    try Locksmith.deleteDataForUserAccount(userAccount: String(forKey))
                    
                    var jsonResponse = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    jsonResponse.removeValue(forKey: "id1")
                    try Locksmith.saveData(data: jsonResponse, forUserAccount: String(forKey))
                    return true
                } catch {
                    print(error)
                    if Locksmith.loadDataForUserAccount(userAccount: forKey) == nil {
                        let jsonResponse = try JSONSerialization.jsonObject(with: JSONEncoder().encode(buffer)) as! Dictionary<String, AnyObject>
                        try Locksmith.saveData(data: jsonResponse, forUserAccount: String(forKey))
                        return true
                    }
                }
            } catch {
                print(error)
                do{
                    var jsonResponse = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    jsonResponse.removeValue(forKey: "id1")
                    try Locksmith.saveData(data: jsonResponse, forUserAccount: String(forKey))
                    return true
                } catch {
                    try? Locksmith.deleteDataForUserAccount(userAccount: String(forKey))
                    
                    var jsonResponse = try? (JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>)
                    jsonResponse!.removeValue(forKey: "id1")
                    try? Locksmith.saveData(data: jsonResponse!, forUserAccount: String(forKey))
                    return true
                }
            }
            
        } else {
            var jsonResponse = try? (JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>)
            jsonResponse!.removeValue(forKey: "id1")
            try? Locksmith.saveData(data: jsonResponse!, forUserAccount: String(forKey))
            return true
        }
        return false
    }
    
}

struct req {
    struct method {
        static let put: String = "PUT"
        static let get: String = "GET"
        static let post: String = "POST"
    }
}

class centralRequest: NSObject {
    private var isCertificatePinning: Bool = true
    
    var onError: ((_ result: Error, _ statusCode: Int)->())?
    var onResponse: ((_ result: Data, _ statusCode: Int)->())?
    
    func getApiURL() -> String {
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                return digilira.api.urlMainnet
            }
        }
        return digilira.api.url
    }
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) throws -> T where T: Decodable  {
        do{
            let type = try JSONDecoder().decode(conformance, from: forKey)
            return type
        } catch let parsingError {
            throw parsingError
        }
    }
    
    func request(rURL: String, postData: Data? = nil, urlParams: String? = "", method: String = req.method.post, isReturn: Bool = true) {
        
        if let url = URL(string: rURL) {
            var request = URLRequest(url: url)
            request.httpMethod = method
            if let json = postData {
                request.httpBody = json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            if urlParams != "" {
                request.url?.appendPathComponent(urlParams!, isDirectory: true)
            }
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            isCertificatePinning = true
            let task = session.dataTask(with: request) { (data, response, error) in
                if !isReturn {return}
                if let httpResponse = response as? HTTPURLResponse {
                    if error != nil {
                        self.onError!(digilira.NAError.anErrorOccured, 555)
                    } else if data != nil {
                        guard let dataResponse = data,
                              error == nil else {
                            switch httpResponse.statusCode {
                            case 400:
                                self.onError!(digilira.NAError.E_400, httpResponse.statusCode)
                            case 502:
                                self.onError!(digilira.NAError.E_502, httpResponse.statusCode)
                            default:
                                self.onError!(digilira.NAError.anErrorOccured, 555)
                            }
                            return }
                        self.onResponse!(dataResponse, httpResponse.statusCode)
                    }
                }
            }
            task.resume()
        }
    }
}


extension centralRequest: URLSessionDelegate {
    
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
            
            let pathToCertificate = Bundle.main.path(forResource: digilira.sslPinning.cert, ofType: digilira.sslPinning.fileType)
            let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
            
            if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
                let credential:URLCredential =  URLCredential(trust:serverTrust)
                
                completionHandler(.useCredential,credential)
            }
            else{
                completionHandler(.cancelAuthenticationChallenge,nil)
            }
        }
    }
    
}

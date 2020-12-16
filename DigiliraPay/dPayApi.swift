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
    
    let jsonEncoder = JSONEncoder()
    var onTouchID: ((_ result: Bool, _ status: String)->())?
    var onError: ((_ result: Error, _ statusCode: Int)->())?
    var onResponse: ((_ result: [String:Any], _ statusCode: Int?)->())?
    var onUpdate: ((_ result: Bool)->())?
    var onTicker: ((_ result: String)->())?
    var onLogin2: ((_ result: digilira.auth, _ statusCode: Int?)->())?
    var onMember: ((_ result: Bool, _ data: digilira.externalTransaction?)->())?
    
    var crud = centralRequest()
    var throwEngine = ErrorHandling()
    
    func request(rURL: String, JSON: Data? = nil,
                 PARAMS: String = "", METHOD: String, AUTH: Bool = false,
                 returnCompletion: @escaping ([String:Any], Int?) -> ()) {
        
        var request = URLRequest(url: URL(string: rURL)!)
        
        request.httpMethod = METHOD
        
        if JSON != nil {
            request.httpBody = JSON
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        
        if PARAMS != "" {
            request.url?.appendPathComponent(PARAMS, isDirectory: true)
        }
        
        if AUTH  {
            do {
                let t = try auth().token
                let tokenString = "Bearer " + t
                request.setValue(tokenString, forHTTPHeaderField: "Authorization")
            } catch {
                //TODO - token not found
                print(error)
            }
        }
        
        
        let session2 = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task2 = session2.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
                
                //                print("error: \(error!.localizedDescription): \(error!)")
                self.onError!(error!, 0)
                
            } else if data != nil {
                
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
            
        }
        task2.resume()
        
    }
    
    func decodeDefaults<T>(forKey: Data, conformance: T.Type, setNil: Bool = false ) throws -> T where T: Decodable  {
        do{
            let ticker = try JSONDecoder().decode(conformance, from: forKey)
            return ticker
        } catch let parsingError {
            throw parsingError
        }
    }

    func touchID(reason: String) {
        
        let context = LAContext()
        var error: NSError?
        
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
                }
            }
        } else {
            self.onTouchID!(false, "Fallback authentication mechanism selected.")
        }
        
    }
    
    
    var onGetOrder: ((_ result: digilira.order)->())?
    
    func getOrder(PARAMS: String) {
        var request = URLRequest(url: URL(string: getApiURL() + digilira.api.payment + PARAMS)!)
        
        request.httpMethod = "GET"
        
        do {
            let t = try auth().token
            let tokenString = "Bearer " + t
            request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        } catch {
            //TODO - token not found
            print(error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let session2 = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task2 = session2.dataTask(with: request) { [self] (data, response, error) in
            
            if error != nil {
                //                print("error: \(error!.localizedDescription): \(error!)")
                self.onError!(error!, 0)
                
            } else if data != nil {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    DispatchQueue.main.async { // Correct
                        
                        let products = json["products"] as? Array<[String:Any]>
                        let refunds = json["refunds"] as? Array<[String:Any]>
                        
                        var someArray = [digilira.product]()
                        var someRefunds = [digilira.refund]()
                        
                        if products != nil {
                            for item in products! {
                                someArray.append(digilira.product(json:item))
                            }
                        }
                        
                        if refunds != nil {
                            for item in refunds! {
                                someRefunds.append(digilira.refund(json:item))
                            }
                        }
                        
                        
                        let order = digilira.order.init(_id: (json["id"] as? String)!,
                                                        merchant: (json["merchant"] as? String)!,
                                                        user: json["merchant"] as? String,
                                                        language: json["language"] as? String,
                                                        order_ref: json["order_ref"] as? String,
                                                        createdDate: json["createdDate"] as? String,
                                                        order_date: json["order_date"] as? String,
                                                        order_shipping: json["order_shipping"] as? Double,
                                                        conversationId: json["conversationId"] as? String,
                                                        rate: (json["rate"] as? Int64),
                                                        totalPrice: json["totalPrice"] as? Double,
                                                        paidPrice: json["paidPrice"] as? Double,
                                                        refundPrice: json["refundPrice"] as? Double,
                                                        currency: json["currency"] as? String,
                                                        currencyFiat: json["currencyFiat"] as? Double,
                                                        userId: json["userId"] as? String,
                                                        paymentChannel: json["paymentChannel"] as? String,
                                                        ip: json["ip"] as? String,
                                                        registrationDate: json["registrationDate"] as? String,
                                                        wallet: (json["wallet"] as? String)!,
                                                        asset: json["asset"] as? String,
                                                        successUrl: json["successUrl"] as? String,
                                                        failureUrl: json["failureUrl"] as? String,
                                                        callbackSuccess: json["callbackSuccess"] as? String,
                                                        callbackFailure: json["callbackFailure"] as? String,
                                                        mobile: json["mobile"] as? Int64,
                                                        status: json["status"] as? Int64,
                                                        products: someArray,
                                                        refund: someRefunds
                        )
                        
                        self.onGetOrder?(order)
                    }
                } catch {
                    onError!(error, 400)
                }
                
            }
            
        }
        task2.resume()
        
    }
    
    func updateUser(user: Data?) {
        
        self.onResponse = { res, sts in
            if (sts == 200) {
                self.onUpdate!(true)
            }else {
                self.onUpdate!(false)
            }
        }
        request2(rURL: getApiURL() + digilira.api.userUpdate, JSON: user, METHOD: digilira.requestMethod.put, AUTH: true)
    }
    
    func updateSmartAcountScript(data: NodeService.Query.Transaction) {
        
        self.onResponse = { res, sts in
            if (sts == 200) {
                print(res)
            }else {
                print("fail")
            }
        }
        
        request2(rURL: getApiURL() + digilira.api.updateScript, JSON: data.data, METHOD: digilira.requestMethod.post, AUTH: true)
        
    }
    
    func getSymbolTicker(symbol:String) {
        self.onResponse = { res, sts in
            if (sts == 200) {
                self.onTicker!(res["price"] as! String)
                print(res)
            }else {
                print("fail")
            }
        }
        
        request2(rURL: "https://api.binance.com/api/v3/ticker/price?symbol=" + symbol, METHOD: digilira.requestMethod.get)
        
    }
    
    func request2(rURL: String, JSON: Data? = nil, PARAMS: String = "", METHOD: String, AUTH: Bool = false) {
        
        var request = URLRequest(url: URL(string: rURL)!)
        
        request.httpMethod = METHOD
        
        if JSON != nil {
            request.httpBody = JSON
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if PARAMS != "" {
            request.url?.appendPathComponent(PARAMS, isDirectory: true)
        }
        
        if AUTH  {
            do {
                let t = try auth().token
                let tokenString = "Bearer " + t
                request.setValue(tokenString, forHTTPHeaderField: "Authorization")
            } catch {
                //TODO - token not found
                print(error)
            }
        }
        
        let session2 = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.isCertificatePinning = true
        
        let task2 = session2.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
                //self.onError!("SSL PINNING MISMATCH", 503)
                
            } else if data != nil {
                
                guard let dataResponse = data,
                      error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
                do{
                    
                    let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse) as! Dictionary<String, AnyObject>
                    self.onResponse!(jsonResponse, httpResponse?.statusCode)
                    
                } catch let parsingError {
                    print("Error", parsingError)
                    self.onResponse!([:], httpResponse?.statusCode)
                }
            }
            
        }
        task2.resume()
        
        
        
    }
    
    func isLoggedIn() -> Bool {
        return false
    }
    
    func setOdemeAliniyor(JSON : Data?) {
        if let json = try! JSONSerialization.jsonObject(with: JSON!, options: []) as? [String: Any] {
            // try to read out a string array
            if let status = json["status"] as? String {
                if (status == "2") {
                    //guard let url = URL(string: "https://api.digilirapay.com/v7/?h=" + (json["id"] as! String)) else { return }
                    //UIApplication.shared.open(url)
                }
            }
        }
        
        request(rURL: getApiURL() + digilira.api.paymentStatus,
                JSON: JSON,
                METHOD: digilira.requestMethod.post,
                AUTH: true
        ) { (json, statusCode) in
            DispatchQueue.global(qos: .background).async  {
                print(json)
            }
        }
        
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
            case digilira.charity.tokenName:
                return (price * double, digilira.charity.token, 1)
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
            case digilira.charity.token:
                return amountFloat * 1 
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
    
    
    func isOurMember(external: digilira.externalTransaction) {
        
        let normalizedAddress = external.address?.components(separatedBy: "?")
        let croppedAddress = normalizedAddress?.first
        
        let user = digilira.externalTransaction.init(
            network: external.network,
            address: external.address
        )
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(user)
        
        self.onResponse = { res, sts in
            if (sts == 200) {
                let response = digilira.externalTransaction.init(network: external.network,
                                                                 address: external.address,
                                                                 amount: external.amount,
                                                                 owner: res["owner"] as? String,
                                                                 wallet: (res["wallet"] as! String),
                                                                 assetId: external.assetId,
                                                                 destination: res["destination"] as? String
                )
                
                self.onMember!(true, response)
            }else {
                
                let response = digilira.externalTransaction.init(network: external.network,
                                                                 address: croppedAddress,
                                                                 amount: 0,
                                                                 owner: croppedAddress,
                                                                 wallet: digilira.gatewayAddress,
                                                                 assetId: external.assetId,
                                                                 destination: digilira.transactionDestination.foreign
                )
                self.onMember!(false, response)
            }
        }
        request2(rURL: getApiURL() + digilira.api.isOurMember, JSON: data, METHOD: digilira.requestMethod.post, AUTH: true)
        
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
    
    func auth() throws -> digilira.auth {
        
        var authenticateSource = "authenticate"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                authenticateSource = "authenticateMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: authenticateSource, conformance: digilira.auth.self)
            return loginCredits
        } catch  {
            throw digilira.NAError.tokenNotFound

        }
        
    }
    
    func encode2<T>(jsonData: T) -> Data? where T: Encodable {
        let encoder = JSONEncoder()
        do {
            let load = try encoder.encode(jsonData)
            return load
        } catch  {
            return nil
        }
        
    }
    
    func getApiURL() -> String {
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                return digilira.api.urlMainnet
            }
        }
        return digilira.api.url
    }
    
    func login2() {
        
        var sensitiveSource = "sensitive"
        var authenticateSource = "authenticate"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
                authenticateSource = "authenticateMainnet"
            }
        }
        

        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: digilira.login.self)
                
                if let json = encode2(jsonData: loginCredits) {
                    crud.onResponse = { [self] res, sts in
                        
                        switch (sts) {
                        
                        case 503, 502:
                            onError!(digilira.NAError.E_502, sts)
                            break;
                            
                        case 404:
                            do {
                                try Locksmith.deleteDataForUserAccount(userAccount: sensitiveSource)
                            } catch  {
                                onError!(digilira.NAError.seed404, sts)
                            }
                            
                            do {
                                try Locksmith.deleteDataForUserAccount(userAccount: authenticateSource)
                            } catch  {
                                onError!(digilira.NAError.user404, sts)
                            }
                            onError!(digilira.NAError.E_404, sts)
                            
                            break;
                            
                        case 200:
                            if secretKeys.LocksmithSave(forKey: authenticateSource, data: res) {
                                do {
                                    let user = try self.decodeDefaults(forKey: res, conformance: digilira.auth.self)
                                     
                                    if let latestApp = user.appV {
                                        if let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                            if let appV = Double(appVersion) {
                                                if latestApp > appV {
                                                    self.onError!(digilira.NAError.updateAPP,0)
                                                     return
                                                }
                                            }
                                           

                                        }
                                    }
                                    
                                    
                                    onLogin2!(user, sts)
                                    DispatchQueue.main.async {
                                        let defaults = UserDefaults.standard
                                        if let savedApnToken = defaults.object(forKey: "deviceToken") as? String {
                                            if savedApnToken != user.apnToken {
                                                let user = digilira.exUser.init(
                                                    apnToken:savedApnToken
                                                )
                                                
                                                let encoder = JSONEncoder()
                                                let data = try? encoder.encode(user)
                                                self.onUpdate = { res in
                                                    print(res)
                                                }
                                                self.updateUser(user: data)
                                            }
                                        }
                                        
                                    }
                                    
                                } catch {
                                    print(error)
                                }
                                 
                            }
                            break;
                            
                        default:
                            break;
                            
                        }
                        
                    }
                    
                    crud.onError = { [self] res, sts in
                        sleep(10)
                        login2()
                    }
                    
                    crud.request(rURL: getApiURL() + digilira.api.auth, postData: json, method: digilira.requestMethod.post)
                }
                
            
            
        } catch  {
            sleep(3)
            login2()
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
            //return []
            break
        }
        
        //return ["",""]
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
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default){
                UIAlertAction in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Gallery", style: .default){
                UIAlertAction in
                self.openGallery()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
                UIAlertAction in
            }
            
            // Add the actions
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

class Utility {
    
    class func checkDeviceLockState(completion: @escaping (DeviceLockState) -> Void) {
        
        DispatchQueue.main.async {
            if UIApplication.shared.isProtectedDataAvailable {
                completion(.unlocked)
            } else {
                completion(.locked)
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
            do{
                try Locksmith.deleteDataForUserAccount(userAccount: String(forKey))
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
            try Locksmith.saveData(data: jsonResponse, forUserAccount: String(forKey))
            return true
        } catch let parsingError {
            print("Error", parsingError)
            return false
        }
        
    }
    
}



class centralRequest: NSObject {
    
    private var isCertificatePinning: Bool = true
    
    var onError: ((_ result: String, _ statusCode: Int)->())?
    var onResponse: ((_ result: Data, _ statusCode: Int)->())?
    
    func request(rURL: String, postData: Data? = nil, urlParams: String? = "", method: String, token: String? = "") {
        
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
            
            if token != "" {
                let tokenString = "Bearer " + token!
                request.setValue(tokenString, forHTTPHeaderField: "Authorization")
            }
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            isCertificatePinning = true
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if error != nil {
                        
                        //print("error: \(error!.localizedDescription): \(error!)")
                        self.onError!("error: \(error!.localizedDescription): \(error!)", 0)
                        
                    } else if data != nil {
                        
                        guard let dataResponse = data,
                              error == nil else {
                            self.onError!(error!.localizedDescription, httpResponse.statusCode)
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

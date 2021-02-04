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
    var lang = Localize()

    var onTouchID: ((_ result: Bool, _ status: String)->())?
    var onResponse: ((_ result: [String:Any], _ statusCode: Int?)->())?
    var onUpdate: ((_ result: digilira.auth?, _ status: Bool)->())?
    var onTicker: ((_ result: String)->())?
    var onBitexenTicker: ((_ result: bex.bexAllTicker)->())?
 
    
    var crud = centralRequest()
    var throwEngine = ErrorHandling()
    var listedTokens = ListedTokens()

    func touchID(reason: String) {
        let context = LAContext()
        var error: NSError?
        
        if let isSecure = UserDefaults.standard.value(forKey: "isSecure") as? Bool
        {
            if isSecure == false {
                UserDefaults.standard.setValue(false, forKey: "biometrics")
                DispatchQueue.main.async {
                    self.onTouchID!(false, "Fallback authentication mechanism selected.")
                }
                return
            }
        } else {
            UserDefaults.standard.setValue(false, forKey: "biometrics")
            DispatchQueue.main.async {
                self.onTouchID!(false, "Fallback authentication mechanism selected.")
            }
            return
        }
        UserDefaults.standard.setValue(true, forKey: "biometrics")
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self?.onTouchID!(true, "ok")
                        UserDefaults.standard.set(0, forKey: "wrongEntry")
                    } else {
                        self?.onTouchID!(false, authenticationError!.localizedDescription)
                    }
                    UserDefaults.standard.setValue(false, forKey: "biometrics")
                }
            }
        } else {
            self.onTouchID!(false, "Fallback authentication mechanism selected.")
            UserDefaults.standard.setValue(false, forKey: "biometrics")
        }
    }
    
    func getChain() throws -> String {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw digilira.NAError.emptyAuth }
        return chainId
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
    
    
    func stringify (x: Any) -> String{
        
        if let y = x as? Int {
            return y.description
        }
        
        if let y = x as? Double {
            return y.description
        }
        
        
        if let y = x as? String {
            return y
        }
        
        if let y = x as? Bool {
            if (y) {
                return "true"
            } else {
                return "false"
            }
            
        }
        
        return ""
    }
    private let wavesCrypto: WavesCrypto = WavesCrypto()

    func validateUser(user: Data) -> Bool {
 
        let dataAddress = Blockchain().returnPublicKey()
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: user) as! Dictionary<String, AnyObject>
            let sorted = jsonResponse.sorted(by: { $0.key < $1.key })
  
            var sign = ""
            var array:[String] = []
            for item in sorted {
                switch item.key {
                case "zmark":
                    sign = stringify(x: item.value)
                    break
                case "id", "id1", "":
                    break
                default:
                    
                    var val = stringify(x: item.value)
 
                    if (item.key == "imported") {
                        if (val == "0") {
                            val = "false"
                        } else {
                            val = "true"
                        }
                    }
                    array.append(val)
                }
                 
            }

            var bytes: [UInt8] = []

                var byteString = ""
                for item in array {
                    if item != "" {
                        byteString = byteString + item
                    }
                }
                
            let array1: [UInt8] = Array(byteString.utf8)
                
            bytes.append(contentsOf: array1)
            let s = wavesCrypto.base58decode(input: sign)
            if wavesCrypto.verifySignature(publicKey: dataAddress, bytes: bytes, signature: s!) {
                return true
            } else {
                return false
            }
  
        } catch {
            return false
        }
    }
    
    func updateUser(user: Data?, signature: String) {
        crud.onError = { error, sts in
            self.onUpdate!(nil, false)
        }
        crud.onResponse = { [self] data, sts in
            switch sts {
            case 200:
                DispatchQueue.main.async {
                    if validateUser(user: data) {
                        do {
                            if secretKeys.LocksmithSave(forKey: try getKeyChainSource().authenticateData, data: data) {
                                let user = try crud.decodeDefaults(forKey: data, conformance: digilira.auth.self)
                                
                                self.onUpdate!(user, true)
                            } else {
                                self.onUpdate!(nil, false)
                            }
                            
                        } catch  {
                            print(error)
                        }
                    } else {
                        self.onUpdate!(nil, false)
                    }
                }
                
                break
            case 502:
                self.onUpdate!(nil, false)
                break
            default:
                self.onUpdate!(nil, false)
            }
        } 
        crud.request(rURL: crud.getApiURL() + digilira.api.userUpdate, postData: user, method: req.method.put, signature: signature)
    }
    
    func updateSmartAcountScript(data: Data, signature: String) {
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
    
    func saveTransactionTransfer(JSON : Data?, signature: String) {
        crud.onError = { error, sts in }
        crud.onResponse = { res, sts in
            
            if (sts == 200) {
            }else {
                print("fail")
            }
        }
        
        crud.request(rURL: crud.getApiURL() + digilira.api.transferNew, postData: JSON, isReturn: true, signature: signature)
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
    
    func ratePrice(price: Double, asset: digilira.DigiliraPayBalance, symbol: digilira.ticker) throws -> (Double, String, Double) {
        let double = Double(truncating: pow(10,asset.decimal) as NSNumber)

        switch asset.network {
        case "waves":
            
            do {
                let tokens = try listedTokens.returnAsset(assetId: asset.tokenName)
                switch tokens.network {
                case digilira.bitcoinNetwork:
                    
                    if let tl = symbol.usdTLPrice {
                        if let btc = symbol.btcUSDPrice {
                            let tick = (btc * tl)
                            let result = price / tick
                            return (Double(round(double * result)), tokens.token, tick)
                        }
                    }
                case digilira.ethereumNetwork:
                    switch asset.tokenSymbol {
                    case "WETH", "Ethereum":
                        if let tl = symbol.usdTLPrice {
                            if let eth = symbol.ethUSDPrice {
                                let tick = (eth * tl)
                                let result = price / tick
                                return (Double(round(double * result)), tokens.token, tick)
                            }
                        }
                    case "USDT":
                            if let usdt = symbol.usdTLPrice {
                                let tick = (usdt)
                                let result = price / tick
                                return (Double(round(double * result)), tokens.token, tick)
                            }
                        break
                    default:
                        throw digilira.NAError.emptyAuth
                    }
               
                case digilira.wavesNetwork:
                    
                    switch tokens.token {
                    case "WAVES":
                        if let tl = symbol.usdTLPrice {
                            if let waves = symbol.wavesUSDPrice {
                                let tick = (waves * tl)
                                let result = price / tick
                                return (Double(round(double * result)), tokens.token, tick)
                            }
                        }
                    default:
                        let tick = (1.0)
                        let result = price / tick
                        return (Double(round(double * result)), tokens.token, tick)
                    }
                default:
                    let tick = (1.0)
                    let result = price / tick
                    return (Double(round(double * result)), tokens.token, tick)
                }
            } catch {
                throw digilira.NAError.emptyAuth
            }
            break
        case "bitexen":
            if let usdt = symbol.usdTLPrice {
                let result = price / usdt
                return (Double(round(double * result)), asset.tokenName, usdt)
            }
            break
        default:
            break
        }
         
         throw digilira.NAError.emptyAuth
    }
    
    func exchange(amount: Int64, coin:WavesListedToken, symbol:digilira.ticker) throws -> Double {
        let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
        let amountFloat = Double.init(Double.init(amount) / double)
        
        switch coin.network {
        case digilira.bitcoinNetwork:
            return amountFloat  * symbol.btcUSDPrice! * symbol.usdTLPrice!
        case digilira.ethereumNetwork:
            return amountFloat * symbol.ethUSDPrice! * symbol.usdTLPrice!
        case digilira.wavesNetwork:
            switch coin.token {
            case "WAVES":
                return amountFloat * symbol.wavesUSDPrice! * symbol.usdTLPrice!
            default:
                return amountFloat * 1
            }
        default:
            throw digilira.NAError.emptyAuth
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func returnBexChain() -> String{
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return bex.bexApiDefaultKey.key }
        switch chainId {
        case "W":
            return bex.bexApiDefaultKey.testKey
        default:
            return bex.bexApiDefaultKey.key
        }
    }
    
    func wipeOut () {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: returnBexChain())
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
        
        UserDefaults.standard.setValue(true, forKey: "environment")
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
    static var notSupportedYet: ((_ result: Bool, _ network: String)->())?
    
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
            checkRegex(address: caption)
            break
        }
    }
    
    class func eval(template: String, address: String) -> Bool {
        let addressTest = NSPredicate(format: "SELF MATCHES %@", template)
        let result = addressTest.evaluate(with: address)
        return result
    }
    
    class func returnEnv() -> String  {
        switch WavesSDK.shared.enviroment.server {
        case .mainNet:
            return "mainnet"
        case .testNet:
            return "testnet"
        default:
            return "-"
        }
    }
    
    class func checkRegex(address: String) {
 
        let env = returnEnv()
        
        var avax = "^(X-avax1)[a-zA-HJ-NP-Z0-9]{38}$"
        var bitcoinSegwit = "^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$"
        if env == "testnet" {
            bitcoinSegwit = "^(tb1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$"
            avax = "^(X-fuji1)[a-zA-HJ-NP-Z0-9]{38}$"
        }
        
        let bitcoinReg = "^[13][a-km-zA-HJ-NP-Z0-9]{26,33}$"
        let ethereumReg = "^0x[a-fA-F0-9]{40}$"
        let wavesreg = "^[3][a-zA-Z0-9]{34}"
        
        let regexString = wavesreg
         
        let result = eval(template: regexString, address: address)
        
        if (!result) {
            let avaxResult = eval(template: avax, address: address)
            if avaxResult {
                self.notSupportedYet!(true, "AVAX")
                return
            }
            
            let btcresult = eval(template: bitcoinReg, address: address)
            
            if btcresult {
                self.onURL!(digilira.QR.init(network: "bitcoin", address: address, amount: 0))
                return
            }
            
            let btcresultSegwit = eval(template: bitcoinSegwit, address: address)
            
            if btcresultSegwit {
                self.onURL!(digilira.QR.init(network: "bitcoin", address: address, amount: 0))
                return
            }
            
            let ethresult = eval(template: ethereumReg, address: address)
            
            if ethresult {
                self.onURL!(digilira.QR.init(network: "ethereum", address: address, amount: 0))
                return
            }
        }
        
        if result {
            self.onURL!(digilira.QR.init(network: "waves", address: address, amount: 0, assetId: "WAVES"))
            return
        }
        self.notSupportedYet!(false, "-")

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
            let lang = Localize()

            alert.dismiss(animated: true, completion: nil)
            if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                picker.sourceType = .camera
                self.viewController!.present(picker, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: lang.const(x: "attention") , message: lang.const(x: "no_camera"), preferredStyle: UIAlertController.Style.alert)
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
                return
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

class ListedTokens: NSObject {
    
    func base64 (data:String) -> String {
        let attachment =  WavesCrypto.shared.base64decode(input: data)
        if let a = attachment {
            if let string = String(bytes: a, encoding: .utf8) {
                return string
            }
        }
        return "DIGILIRAPAY TRANSFER"
    }
    
    func returnAsset (assetId: String?) throws -> WavesListedToken {
        
        var assetId = assetId
        if assetId == nil {
            assetId = "WAVES"
        }
         
        do {
            let tokens = try returnCoins()
            if let i = tokens.firstIndex(where: { $0.token == assetId || $0.tokenName == assetId || $0.network == assetId }) {
                let token = tokens[i]
                return token
            }
            throw digilira.NAError.tokenNotFound
        } catch {
            throw digilira.NAError.notListedToken
        }
    }
    
    func returnCoins() throws -> [WavesListedToken] {
        
        guard let result = UserDefaults.standard.value(forKey: "listedTokens") as? Data else {
            throw digilira.NAError.tokenNotFound
        }
        
        let type = try JSONDecoder().decode(WavesDataTransaction.self, from: result)
       
        if type.type == "binary" {
            let d = try JSONDecoder().decode(String.self, from: type.value.data!)
            let data = d.components(separatedBy: "base64:")
            let b64 = base64(data: data[1].description)
            let jsonData = b64.data(using: .utf8)!
            let decoder = JSONDecoder()
            
            do {
                let wavesListedTokens = try decoder.decode([WavesListedToken].self, from: jsonData)
                return wavesListedTokens
            } catch {
                throw digilira.NAError.tokenNotFound
            }
        }
        throw digilira.NAError.tokenNotFound
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
    
    func request(rURL: String, postData: Data? = nil, urlParams: String? = "", method: String = req.method.post, isReturn: Bool = true, signature: String = "NO-SIG") {
        
        if let url = URL(string: rURL) {
            var request = URLRequest(url: url)
            request.httpMethod = method
            if let json = postData {
                request.httpBody = json
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue(signature, forHTTPHeaderField: "X-Signature")

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

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

class DigiliraPayService: NSObject {
    private var isCertificatePinning: Bool = true
    
    var token:String?
    var lang = Localize()

    var onTouchID: ((_ result: Bool, _ status: String)->())?
    var onResponse: ((_ result: [String:Any], _ statusCode: Int?)->())?
    var onUpdate: ((_ result: Constants.auth?, _ status: Bool)->())?
    var onTicker: ((_ result: String)->())?
    var onBitexenTicker: ((_ result: BexSign.bexAllTicker)->())?
    private let wavesCrypto: WavesCrypto = WavesCrypto()

    
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
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw Constants.NAError.emptyAuth }
        return chainId
    }
    
    func getKeyChainSource() throws -> Constants.keychainData {
        guard let chainId = WavesSDK.shared.enviroment.chainId else { throw Constants.NAError.emptyAuth }
        switch chainId {
        case "T":
            return Constants.keychainData.init(authenticateData: "authenticate", sensitiveData: "sensitive", wavesToken: "wavesToken")
        case "W":
            return Constants.keychainData.init(authenticateData: "authenticateMainnet", sensitiveData: "sensitiveMainnet", wavesToken: "wavesTokenMainnet")
        default:
            throw Constants.NAError.emptyAuth
        }
    }
    
    func stringify (AnyVal: Any) -> String{
        
        if let proxyVal = AnyVal as? Int {
            return proxyVal.description
        }
        
        if let proxyVal = AnyVal as? Double {
            return proxyVal.description
        }
        
        
        if let proxyVal = AnyVal as? String {
            return proxyVal
        }
        
        if let proxyVal = AnyVal as? Bool {
            if (proxyVal) {
                return "true"
            } else {
                return "false"
            }
            
        }
        
        return ""
    }

    func validateUser(user: Data) -> Bool {
 
        let dataAddress = BlockchainService().returnPublicKey()
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: user) as! Dictionary<String, AnyObject>
            let sorted = jsonResponse.sorted(by: { $0.key < $1.key })
  
            var sign = ""
            var array:[String] = []
            for item in sorted {
                switch item.key {
                case "zmark":
                    sign = stringify(AnyVal: item.value)
                    break
                case "id", "id1", "":
                    break
                default:
                    
                    var val = stringify(AnyVal: item.value)
 
                    if (item.key == "imported" || item.key == "isTether") {
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
            if let s = wavesCrypto.base58decode(input: sign) {
                if wavesCrypto.verifySignature(publicKey: dataAddress, bytes: bytes, signature: s) {
                    return true
                } else {
                    return false
                }
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
                                let user = try crud.decodeDefaults(forKey: data, conformance: Constants.auth.self)
                                
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
        crud.request(rURL: crud.getApiURL() + Constants.api.userUpdate, postData: user, method: req.method.put, signature: signature)
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
        crud.request(rURL: crud.getApiURL() + Constants.api.userUpdate, postData: data, method: req.method.put)
    }
    
    func saveTransactionTransfer(JSON : Data?, signature: String) {
        crud.onError = { error, sts in }
        crud.onResponse = { res, sts in
            
            if (sts == 200) {
            }else {
                print("fail")
            }
        }
        
        crud.request(rURL: crud.getApiURL() + Constants.api.transferNew, postData: JSON, isReturn: true, signature: signature)
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func ticker (ticker: BinanceService.BinanceMarketInfo) -> Constants.ticker {
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
        
        let res = Constants.ticker.init(ethUSDPrice: ethUsdtPrice,
                                       btcUSDPrice: btcUsdtPrice,
                                       wavesUSDPrice: wavesUsdtPrice,
                                       usdTLPrice: tryUsdtPrice
        )
        return res
    }
    
    func ratePrice(price: Double, asset: Constants.DigiliraPayBalance, symbol: Constants.ticker) throws -> (Double, String, Double) {
        let double = Double(truncating: pow(10,asset.decimal) as NSNumber)

        switch asset.network {
        case "waves":
            
            do {
                let tokens = try listedTokens.returnAsset(assetId: asset.tokenName)
                switch tokens.network {
                case Constants.bitcoinNetwork:
                    
                    if let tl = symbol.usdTLPrice {
                        if let btc = symbol.btcUSDPrice {
                            let tick = (btc * tl)
                            let result = price / tick
                            return (Double(round(double * result)), tokens.token, tick)
                        }
                    }
                case Constants.ethereumNetwork:
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
                        throw Constants.NAError.emptyAuth
                    }
               
                case Constants.wavesNetwork:
                    
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
                throw Constants.NAError.emptyAuth
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
         
         throw Constants.NAError.emptyAuth
    }
    
    func exchange(amount: Int64, coin:WavesListedToken, symbol:Constants.ticker) throws -> Double {
        let double = Double(truncating: pow(10,coin.decimal) as NSNumber)
        let amountFloat = Double.init(Double.init(amount) / double)
        
        switch coin.network {
        case Constants.bitcoinNetwork:
            return amountFloat  * symbol.btcUSDPrice! * symbol.usdTLPrice!
        case Constants.ethereumNetwork:
            return amountFloat * symbol.ethUSDPrice! * symbol.usdTLPrice!
        case Constants.wavesNetwork:
            switch coin.token {
            case "WAVES":
                return amountFloat * symbol.wavesUSDPrice! * symbol.usdTLPrice!
            default:
                return amountFloat * 1
            }
        default:
            throw Constants.NAError.emptyAuth
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func returnBexChain() -> String{
        guard let chainId = WavesSDK.shared.enviroment.chainId else { return BexSign.bexApiDefaultKey.key }
        switch chainId {
        case "W":
            return BexSign.bexApiDefaultKey.testKey
        default:
            return BexSign.bexApiDefaultKey.key
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
    static var onURL: ((_ result: Constants.QR)->())?
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
                    self.onURL!(Constants.QR.init(network: caption, address: digiliraURL[3]))
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
            self.onURL!(Constants.QR.init(network: caption, address: data[0], amount: amount))
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
            self.onURL!(Constants.QR.init(network: caption, address: data[0], amount: amount, assetId: assetId))
            
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
                self.onURL!(Constants.QR.init(network: "bitcoin", address: address, amount: 0))
                return
            }
            
            let btcresultSegwit = eval(template: bitcoinSegwit, address: address)
            
            if btcresultSegwit {
                self.onURL!(Constants.QR.init(network: "bitcoin", address: address, amount: 0))
                return
            }
            
            let ethresult = eval(template: ethereumReg, address: address)
            
            if ethresult {
                self.onURL!(Constants.QR.init(network: "ethereum", address: address, amount: 0))
                return
            }
        }
        
        if result {
            self.onURL!(Constants.QR.init(network: "waves", address: address, amount: 0, assetId: "WAVES"))
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

extension DigiliraPayService: URLSessionDelegate {
    
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
            let pathToCertificate = Bundle.main.path(forResource: Constants.sslPinning.cert, ofType: Constants.sslPinning.fileType)
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
            throw Constants.NAError.tokenNotFound
        } catch {
            throw Constants.NAError.notListedToken
        }
    }
    
    func returnCoins() throws -> [WavesListedToken] {
        
        guard let result = UserDefaults.standard.value(forKey: "listedTokens") as? Data else {
            throw Constants.NAError.tokenNotFound
        }
        
        let type = try JSONDecoder().decode(WavesDataTransaction.self, from: result)
       
        if type.type == "binary" {
            var serial: Data;
            if #available(iOS 13.0, *) {
                let d = try JSONDecoder().decode(String.self, from: type.value.data!)
                let data = d.components(separatedBy: "base64:")
                let b64 = base64(data: data[1].description)
                serial = b64.data(using: .utf8)!
            } else {
                // Fallback on earlier versionsü
                let str = String(describing: type.value)
                let data = str.components(separatedBy: "base64:")
                let data2 = data[1].components(separatedBy: "\"")
                let b64 = base64(data: data2[0].description)
                serial = b64.data(using: .utf8)!
            }
            
            let decoder = JSONDecoder()
            
            do {
                let wavesListedTokens = try decoder.decode([WavesListedToken].self, from: serial)
                return wavesListedTokens
            } catch {
                throw Constants.NAError.tokenNotFound
            }
        }
        throw Constants.NAError.tokenNotFound
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
    
    class func userData() throws -> Constants.auth {
        var authenticateSource = "authenticate"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                authenticateSource = "authenticateMainnet"
            }
        }
        
        do {
            let data = try secretKeys.LocksmithLoad(forKey: authenticateSource, conformance: Constants.auth.self)
            if data.status == 2 {
                if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
                    if !selfied {
                        UserDefaults.standard.set(true, forKey: "isSelfied")
                    }
                }
                
            }
            return data
        } catch {
            throw Constants.NAError.emptyAuth
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
                throw Constants.NAError.emptyAuth
            }
        }
        throw Constants.NAError.emptyAuth
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
                return Constants.api.urlMainnet
            }
        }
        return Constants.api.url
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
                        self.onError!(Constants.NAError.anErrorOccured, 555)
                    } else if data != nil {
                        guard let dataResponse = data,
                              error == nil else {
                            switch httpResponse.statusCode {
                            case 400:
                                self.onError!(Constants.NAError.E_400, httpResponse.statusCode)
                            case 502:
                                self.onError!(Constants.NAError.E_502, httpResponse.statusCode)
                            default:
                                self.onError!(Constants.NAError.anErrorOccured, 555)
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
            
            let pathToCertificate = Bundle.main.path(forResource: Constants.sslPinning.cert, ofType: Constants.sslPinning.fileType)
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

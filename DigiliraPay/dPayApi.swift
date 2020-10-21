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
import Starscream

 
class digiliraPayApi {
    
    var token:String?
    
    let jsonEncoder = JSONEncoder()
    var onTouchID: ((_ result: Bool, _ status: String)->())?
    var onError: ((_ result: String)->())?
    var onResponse: ((_ result: [String:Any], _ statusCode: Int?)->())?
    var onUpdate: ((_ result: Bool)->())?
    var onTicker: ((_ result: String)->())?
    var onMember: ((_ result: Bool, _ data: digilira.externalTransaction?)->())?

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
            let tokenString = "Bearer " + auth().token!
              request.setValue(tokenString, forHTTPHeaderField: "Authorization")
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
     var request = URLRequest(url: URL(string: digilira.api.url + digilira.api.payment + PARAMS)!)
        
        request.httpMethod = "GET"
       let tokenString = "Bearer " + auth().token!

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        //let httpResponse = response as? HTTPURLResponse

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
                                                    rate: (json["rate"] as? Int64)!,
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
                print(error)
            }
        })
        
        task.resume()
        
    }
    
    func updateUser(user: Data?) {
        
        self.onResponse = { res, sts in
            if (sts == 200) {
                self.onUpdate!(true)
            }else {
                self.onUpdate!(false)
            }
        }
        request2(rURL: digilira.api.url + digilira.api.userUpdate, JSON: user, METHOD: digilira.requestMethod.put, AUTH: true)
    }
    
    func updateSmartAcountScript(data: NodeService.Query.Transaction) {
        
        self.onResponse = { res, sts in
            if (sts == 200) {
                print(res)
            }else {
                print("fail")
            }
        }
        
        request2(rURL: digilira.api.url + digilira.api.updateScript, JSON: data.data, METHOD: digilira.requestMethod.post, AUTH: true)

        
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
          let tokenString = "Bearer " + auth().token!
            request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

          let httpResponse = response as? HTTPURLResponse
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
        task.resume()
        
        
    }
    
    func getToken() -> String {
        let token = UserDefaults.standard.string(forKey: "token")
        return token!
    }
    
    func getName() -> String {
        return auth().name! + " " + auth().surname!
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
        
        request(rURL: digilira.api.url + digilira.api.paymentStatus,
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
    
    
    
    
    func credentials (PARAMS: String) -> digilira.login {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: PARAMS)
        let loginCredentials = digilira.login.init(username: dictionary?["username"] as! String,
                                                   password: dictionary?["password"] as! String
        )
        return loginCredentials
    }
    
    func ticker () -> digilira.ticker {
        let ethUSDPrice: Double? = 376.77
        let btcUSDPrice: Double? = 11352
        let wavesUSDPrice: Double? = 2.49
        let usdTLPrice: Double? = 7.8
        
        let res = digilira.ticker.init(ethUSDPrice: ethUSDPrice,
                                       btcUSDPrice: btcUSDPrice,
                                       wavesUSDPrice: wavesUSDPrice,
                                       usdTLPrice: usdTLPrice
        )
        return res
    }
    
    func exchange(amount: Int64, network: String, assetId:String) -> Double {
        let symbol = ticker()
        let amountFloat = Double.init(Double.init(amount) / 100000000)
        
        switch network {
        case "bitcoin":
            return amountFloat  * symbol.btcUSDPrice! * symbol.usdTLPrice!
        case "ethereum":
            return amountFloat * symbol.ethUSDPrice! * symbol.usdTLPrice!
        case "waves":
            switch assetId {
            case digilira.waves.token:
                return amountFloat * symbol.wavesUSDPrice! * symbol.usdTLPrice!
                
            case digilira.charity.token:
                return amountFloat * 1
            
            default:
                return 0.0
            }
            
        default:
            return 0.0
        }
        
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
                                                                 assetId: external.assetId
                )
                
                self.onMember!(true, response)
            }else {
                
                let response = digilira.externalTransaction.init(network: external.network,
                                                                 address: croppedAddress,
                                                                     owner: "",
                                                                     wallet: ""
                    )
                self.onMember!(false, response)
            }
        }
        request2(rURL: digilira.api.url + digilira.api.isOurMember, JSON: data, METHOD: digilira.requestMethod.post, AUTH: true)
        
        
    }
    
 


    func auth() -> digilira.auth {

        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "auth")
        
        let authCredentials = digilira.auth.init(name: dictionary?["name"] as? String,
                                                  surname: dictionary?["surname"] as? String,
                                                  token: dictionary?["token"] as? String,
                                                  status: dictionary?["status"] as? Int64,
                                                  pincode: dictionary?["pincode"] as? Int32
        )
        return authCredentials
        
    }
    
    
    func login(returnCompletion: @escaping (digilira.user, Int?) -> () ) {
 
        let loginCredits = credentials(PARAMS: "sensitive")
             
            request(rURL: digilira.api.url + digilira.api.auth,
                                  JSON: try? self.jsonEncoder.encode(loginCredits),
                                  METHOD: digilira.requestMethod.post
            ) { (json, statusCode) in
                
                DispatchQueue.main.async {
                     
                    switch (statusCode) {
                    
                    case 503:
                        let kullanici = digilira.user.init() 
                        returnCompletion(kullanici, statusCode)
                        break;
                    
                    case 400, 404:
                        let kullanici = digilira.user.init()
                        try? Locksmith.deleteDataForUserAccount(userAccount: "sensitive")
                        returnCompletion(kullanici, statusCode)
                        break;
                        
                    case 200:
                        let pin =  Int32((json["pincode"] as? String)!)

                        let kullanici = digilira.user.init(username: json["username"] as? String,
                                                           firstName: json["firstName"] as? String,
                                                           lastName: json["lastName"] as? String,
                                                           tcno: json["tcno"] as? String,
                                                           tel: json["tel"] as? String,
                                                           mail: json["mail"] as? String,
                                                           btcAddress: json["btcAddress"] as? String,
                                                           ethAddress: json["ethAddress"] as? String,
                                                           ltcAddress: json["ltcAddress"] as? String,
                                                           wallet: json["wallet"] as? String,
                                                           token: json["token"] as? String,
                                                           status: json["status"] as? Int64,
                                                           pincode: pin,
                                                           apnToken: json["apnToken"] as? String
                        )
                        
                         
                        try? Locksmith.deleteDataForUserAccount(userAccount: "auth")
                        
                        try? Locksmith.saveData(data: [
                            "token": json["token"] as Any,
                            "name": json["firstName"] as Any,
                            "surname": json["lastName"] as Any,
                            "status": json["status"] as Any,
                            "pincode": json["pincode"] as Any
                        ], forUserAccount: "auth")
                
                        let defaults = UserDefaults.standard
                        if let savedApnToken = defaults.object(forKey: "deviceToken") as? String {
                            print(savedApnToken)
                            
                            let user = digilira.user.init(
                                apnToken:savedApnToken
                            )
                            
                            let encoder = JSONEncoder()
                            let data = try? encoder.encode(user)
                            self.onUpdate = { res in
                                print(res)
                            }
                            self.updateUser(user: data)
                        }
                        
                        
                        
                        returnCompletion(kullanici, statusCode)
                        break;
                        
                    default:
                        break;
                    
                    }
  
                    

                }
            }
         
    }
    
}

class deviceToken1 {
    
    class func updateMyToken () {
        
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
            let data = array[1].components(separatedBy: "?amount=")

            if (data.count > 1) {
                amount = Int64(Float.init(data[1])! * 100000000)
            }
            self.onURL!(digilira.QR.init(network: caption, address: data[0], amount: amount))
            break
            
        case "waves":
            let data = array[1].components(separatedBy: "?amount=")
            let amountAssetId = data[1].components(separatedBy: "&assetId=")
            
            var amount: Int64? = 0
            if (amountAssetId.count > 1) {
                amount = Int64(Float.init(amountAssetId[0])! * 100000000)
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
                let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
                alertWarning.show()
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
        //for swift below 4.2
        //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //    picker.dismiss(animated: true, completion: nil)
        //    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //    pickImageCallback?(image)
        //}

        // For Swift 4.2+
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            guard let image = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            pickImageCallback?(image)
        }



        @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        }

    }


}

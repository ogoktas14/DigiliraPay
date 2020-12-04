//
//  VerifyAccountView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class VerifyAccountView: UIView, UITextFieldDelegate, XMLParserDelegate
{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var sendAndContiuneView: UIView!
    @IBOutlet weak var cameraButtonView: UIView!
    @IBOutlet weak var galleryButtonView: UIView!
    @IBOutlet weak var goHomeView: UIView!
    
    @IBOutlet weak var enterInfoView: UIView!
    @IBOutlet weak var sendIDPhotoView: UIView!
    @IBOutlet weak var finishedView: UIView!
    
    weak var delegate: VerifyAccountDelegate?
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var dogum: UIDatePicker!
    
    @IBOutlet weak var understand: UISwitch!
    
    @IBOutlet weak var onayImage: UIImageView!
    @IBOutlet weak var infoTitle: UILabel!
    
    var isVerified:Bool = false
    var isExit: Bool = false
    
    var dogumTarihi: Date?
 
    let digiliraPay = digiliraPayApi()
    var onUpdate: ((_ result: [String:Any])->())?

    override func didMoveToSuperview() {
        do {
            let user = try secretKeys.userData()
    
               nameText.text = user.firstName
               surnameText.text = user.lastName
               tcText.text = user.tcno
               telText.text = user.tel
               mailText.text = user.mail
                
                if let dogumTarihi = user.dogum {
                    let isoDateFormatter = ISO8601DateFormatter()
                    isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    isoDateFormatter.formatOptions = [
                        .withFullDate,
                        .withFullTime,
                        .withDashSeparatorInDate,
                        .withFractionalSeconds]
                    
                    if let date1 = isoDateFormatter.date(from:dogumTarihi) {
                        dogum.setDate(date1, animated: true)
                    }
                }
                 
        }catch{
            
        }
    }
    
    @IBAction func yesIKnow(_ sender: Any) {
        if let tick = sender as? UISwitch {
            delegate?.dismissKeyboard()
            if tick.isOn {
                sendAndContiuneView.alpha = 1
                sendAndContiuneView.isUserInteractionEnabled = true
            } else {
                sendAndContiuneView.alpha = 0.4
                sendAndContiuneView.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func btnExit(_ sender: Any) {
        isExit = true
        goHome()
    }
    
    private func exampleSoapRequest(tc: String, ad: String, soyad: String, dogum: String) {
        let url = URL(string: digilira.tcDoguralma)!
        let bodyData = """
<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <TCKimlikNoDogrula xmlns="http://tckimlik.nvi.gov.tr/WS">
              <TCKimlikNo>
""" + tc + """
</TCKimlikNo>
              <Ad>
""" + ad + """
</Ad>
              <Soyad>
""" + soyad + """
</Soyad>
              <DogumYili>
""" + dogum + """
</DogumYili>
            </TCKimlikNoDogrula>
          </soap:Body>
        </soap:Envelope>
"""
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData.data(using: .utf8)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("SOAPAction", forHTTPHeaderField: digilira.soapAction)

        let task = URLSession.shared
            .dataTask(with: request as URLRequest,
                      completionHandler: { data, response, error in
                        guard let dataResponse = data,
                              error == nil else {
                            return }
                        let dataString = NSString(data: dataResponse, encoding: String.Encoding.utf8.rawValue)
                                  print(dataString!)
                        
                        let parser = XMLParser(data: dataResponse)
                        parser.delegate = self
                        parser.parse()
  
            })
        task.resume()
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        DispatchQueue.main.async { [self] in
        var sts = 0
            if string == "true" {
                sts = 1 
                onayImage.image = UIImage(named: "TransactionPopupSucces")
                infoTitle.text = "Profiliniz onaylanmıştır."
                 
                goHomeView.isUserInteractionEnabled = true
                goHomeView.alpha = 1
                
                isVerified = true
            }else {
                
                onayImage.image = UIImage(named: "forbidden")
                infoTitle.text = "Girdiğiniz bilgiler hatalıdır. Kontrol ederek yeniden deneyin."
                isVerified = false
                
                understand.isEnabled = true
                sendAndContiuneView.isUserInteractionEnabled = true
                sendAndContiuneView.alpha = 1
                
                goHomeView.isUserInteractionEnabled = true
                goHomeView.alpha = 1
            }
        
        finishedView.translatesAutoresizingMaskIntoConstraints = true
        finishedView.frame.origin.y = self.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.enterInfoView.frame.origin.y = self.self.frame.height
            self.finishedView.frame.origin.y = 0
            self.finishedView.alpha = 1
        }
        
        
        digiliraPay.onUpdate = { res in

            self.digiliraPay.onLogin2 = { user, status in
                //self.delegate?.dismissVErifyAccountView()
                
            }
            
            self.digiliraPay.login2()
        }
        
        //let b64 = digiliraPay.convertImageToBase64String(img: UIImage(named: "test.jpg")!)
 
            delegate?.dismissKeyboard()
 
            let user = digilira.exUser.init(
                firstName: nameText.text,
                lastName: surnameText.text,
                tcno: tcText.text,
                dogum: dogum.date.description,
                tel: telText.text,
                mail: mailText.text,
                status: sts
            )
            
            let encoder = JSONEncoder()
            let data = try? encoder.encode(user)
            
            digiliraPay.updateUser(user: data)
        

        }
    }

    
    func validateEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if textField == tcText {return count <= 11}
        return count <= 40
    }
    
    override func awakeFromNib()
    {
        let sendAndContiuneGesture = UITapGestureRecognizer(target: self, action: #selector(sendAndContiune))
        
        let openCameraGesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        
        let openGalleryGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        
        let goHomeGesture = UITapGestureRecognizer(target: self, action: #selector(goHome))
        
        sendAndContiuneView.addGestureRecognizer(sendAndContiuneGesture)
        sendAndContiuneView.isUserInteractionEnabled = true
        
        cameraButtonView.addGestureRecognizer(openCameraGesture)
        cameraButtonView.isUserInteractionEnabled = true
        
        galleryButtonView.addGestureRecognizer(openGalleryGesture)
        galleryButtonView.isUserInteractionEnabled = true
        
        goHomeView.isUserInteractionEnabled = true
        goHomeView.addGestureRecognizer(goHomeGesture)
        
        nameText.delegate = self
        surnameText.delegate = self
        tcText.delegate = self
        tcText.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        telText.delegate = self
        
        mailText.delegate = self
        

        
    }
    
    func validate(value: String) -> Bool {
            let tcrgx = "^\\d{11}$"
            let tcTest = NSPredicate(format: "SELF MATCHES %@", tcrgx)
            let result = tcTest.evaluate(with: value)
            return result
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case nameText:
            surnameText.becomeFirstResponder()
        case surnameText:
            tcText.becomeFirstResponder()
        case tcText:
            telText.becomeFirstResponder()
        case telText:
            mailText.becomeFirstResponder()
        case mailText:
            delegate?.dismissKeyboard()
        default:
            delegate?.dismissKeyboard()
        }
 
        return true
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {

       print("print \(sender.date)")

        let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "MMM dd, YYYY"
        let somedateString = dateFormatter.string(from: sender.date)
       print(somedateString)  // "somedateString" is your string date
   }
    
    func KYC() {
        
        if let ad = nameText.text {
            if let soyad = surnameText.text {
                if let tc = tcText.text {
                let date = dogum.date
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                    exampleSoapRequest(tc:tc, ad:ad, soyad: soyad, dogum: year.description)
                }
            }
        }
         
    }
    
    @objc func sendAndContiune()
    {
        understand.isEnabled = false
        sendAndContiuneView.isUserInteractionEnabled = false
        sendAndContiuneView.alpha = 0.4
        
        let emailVal = validateEmail(enteredEmail: mailText.text!)
        let tcVal = validate(value: tcText.text!)
        
        var error = false
        
        if (emailVal == false) {
            mailText.textColor = .red
            error = true
        }
        
        if (tcVal == false) {
            tcText.textColor = .red
            error = true
        }
         
        if error {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

            let alert = UIAlertController(title: "Bilgilerinizi kontrol edin",message:"Hatalı girilen alanlar bulunmaktadır.",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertAction.Style.default,handler: nil))
            window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        enterInfoView.translatesAutoresizingMaskIntoConstraints = true
        sendIDPhotoView.translatesAutoresizingMaskIntoConstraints = true
         
        sendIDPhotoView.frame.origin.y = self.frame.height
        
        
//        UIView.animate(withDuration: 0.3) {
//            self.enterInfoView.frame.origin.y = self.self.frame.height
//            self.sendIDPhotoView.frame.origin.y = 0
//            self.sendIDPhotoView.alpha = 1
//        }
        KYC()
        

    }
    
    @objc func openCamera()
    {
        KYC()
        
        finishedView.translatesAutoresizingMaskIntoConstraints = true
        finishedView.frame.origin.y = self.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.sendIDPhotoView.frame.origin.y = self.self.frame.height
            self.finishedView.frame.origin.y = 0
            self.finishedView.alpha = 1
        }
    }
    
    @objc func openGallery()
    {
        finishedView.translatesAutoresizingMaskIntoConstraints = true
        finishedView.frame.origin.y = self.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.enterInfoView.frame.origin.y = self.self.frame.height
            self.sendIDPhotoView.frame.origin.y = 0
            self.finishedView.alpha = 1
        }
    }
    
    @objc func goHome()
    {
        goHomeView.isUserInteractionEnabled = false
        goHomeView.alpha = 0.4
        
        if isExit {
            delegate?.dismissVErifyAccountView()
            return
        }
        if isVerified {
            delegate?.dismissVErifyAccountView()
        } else {
            finishedView.translatesAutoresizingMaskIntoConstraints = true
            finishedView.frame.origin.y = self.frame.height
            
            UIView.animate(withDuration: 0.3) {
                self.enterInfoView.frame.origin.y = 0
                self.enterInfoView.alpha = 1
                self.finishedView.alpha = 0
            }
        }
    }
}

//
//  VerifyAccountView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
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
    @IBOutlet weak var scrollAres: UIScrollView!
    
    @IBOutlet weak var enterInfoView: UIView!
    
    weak var delegate: VerifyAccountDelegate?
    weak var errors: ErrorsDelegate?
    
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
                let bottomOffset = CGPoint(x: 0, y: scrollAres.contentSize.height - scrollAres.bounds.size.height)
                scrollAres.setContentOffset(bottomOffset, animated: true)
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
    
    @IBAction func touchBirth(_ sender: Any) {
        delegate?.dismissKeyboard()
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
                enterInfoView.alpha = 0
                
                errors?.errorHandler(message: "Kimlik bilgileriniz doğrulandı, ancak KYC sürecini tamamlamak için kimliğinizin ön yüzü görünecek biçimde boş bir kağıda günün tarihini ve DigiliraPay yazarak Profil Onayı sayfasına yükleyin.", title: "Profiliniz Güncellendi", error: false)
                
                delegate?.dismissVErifyAccountView()
            }else {
                errors?.errorHandler(message: "Girdiğiniz bilgileri kontrol edip tekrar deneyin.", title: "Bir Hata Oluştu", error: true)
                understand.isEnabled = true
                understand.isOn = false
            }
            
            digiliraPay.onUpdate = { res in
                
                self.digiliraPay.onLogin2 = { user, status in
                    delegate?.enableEntry(user:user)
                }
                self.digiliraPay.login2()
            }
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
        
        sendAndContiuneView.addGestureRecognizer(sendAndContiuneGesture)
        sendAndContiuneView.isUserInteractionEnabled = true
        
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
            
            let bottomOffset = CGPoint(x: 0, y: 120)
            scrollAres.setContentOffset(bottomOffset, animated: true)
            
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        
        let bottomOffset = CGPoint(x: 0, y: 200)
        scrollAres.setContentOffset(bottomOffset, animated: true)
    }
    
    func KYC() {
        if var ad = nameText.text {
            if var soyad = surnameText.text {
                if ad.last == " " {ad.removeLast()}
                if soyad.last == " " {soyad.removeLast()}
                nameText.text = ad
                surnameText.text = soyad
                
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
            DispatchQueue.main.async {
                
                self.errors?.errorHandler(message: "Girdiğiniz bilgileri kontrol edip tekrar deneyin.", title: "Bir Hata Oluştu", error: true)
            }
            
            understand.isEnabled = true
            sendAndContiuneView.isUserInteractionEnabled = true
            sendAndContiuneView.alpha = 1
            return
        }
        KYC()
    }
    
    @objc func goHome()
    {
        
        if isExit {
            delegate?.dismissVErifyAccountView()
            return
        }
        if isVerified {
            delegate?.dismissVErifyAccountView()
        } else {
            
            UIView.animate(withDuration: 0.3) {
                self.enterInfoView.frame.origin.y = 0
                self.enterInfoView.alpha = 1
            }
        }
    }
}

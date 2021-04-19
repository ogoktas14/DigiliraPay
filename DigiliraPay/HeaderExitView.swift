//
//  HeaderExitView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 9.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit


class HeaderExitView: UIView{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var scrollArea: UIScrollView!
    @IBOutlet weak var verify: UIView!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    weak var delegate: SeedBackupDelegate?
    let generator = UINotificationFeedbackGenerator()

    @IBOutlet weak var s01: UILabel!
    @IBOutlet weak var s02: UILabel!
    @IBOutlet weak var s03: UILabel!
    @IBOutlet weak var s04: UILabel!
    @IBOutlet weak var s05: UILabel!
    @IBOutlet weak var s06: UILabel!
    @IBOutlet weak var s07: UILabel!
    @IBOutlet weak var s08: UILabel!
    @IBOutlet weak var s09: UILabel!
    @IBOutlet weak var s10: UILabel!
    @IBOutlet weak var s11: UILabel!
    @IBOutlet weak var s12: UILabel!
    @IBOutlet weak var s13: UILabel!
    @IBOutlet weak var s14: UILabel!
    @IBOutlet weak var s15: UILabel!
    @IBOutlet weak var compare: UILabel!
    var labelArray: [UILabel] = []
    private var seedArray: [String] = []
    private var selectArray: [String] = []
    
    var isPressed = 0
    var isVerifiable: Bool = false
    var isVerified: Bool = false
    var isSeedHidden: Bool = false
    
    @IBAction func exitButton(_ sender: Any)
    {
        self.delegate?.dismissSeedBackup()
    }
    
    func show() {
        do {
            let s = try getSeed()
            let fullSeed : [String] = s.components(separatedBy: " ")
            seedArray = []
            for i in 0..<15 {
                self.labelArray[i].text = fullSeed[i]
                self.seedArray.append(fullSeed[i])
            }
        } catch {
           print("notxool")
        }
    }
    
    @objc func fx_showSeeds() {
        generator.notificationOccurred(.success)
        if isSeedHidden {
            isSeedHidden = false
            show()
            verifyLabel.text = "Kelimeleri Gizle"
        } else {
            
            if !isVerified {
                show()
            }else {
                verifyLabel.text = "Kelimeleri Göster"
                isSeedHidden = true
                for i in 0..<15 {
                    self.labelArray[i].text = "***"
                }
            }
            
            
        }
        
        
    }
    
    @objc func fx_shuffle() {
        generator.notificationOccurred(.success)
        do {
            let s = try getSeed()
            
            if isVerifiable {
                isVerifiable = false
                
                for item in labelArray {
                    UIView.animate(withDuration: 0.3, animations: {
                        item.alpha = 1
                    })
                }
                
                if selectArray == seedArray {
                    selectArray = []
                    isPressed = 0
                    delegate?.seedBackedUp()
                } else {
                    scrollArea.shake()
                    selectArray = []
                    isPressed = 0
                    start()
                    compare.text = "Anahtar kelimeleriniz ile seçilen kelimeler uyuşmamaktadır. Lütfen tekrar deneyin."
                    return
                }
                
            } else {
                var fullSeed : [String] = s.components(separatedBy: " ")
                fullSeed.shuffle()
                
                for i in 0..<15 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.labelArray[i].alpha = 0.7
                    }, completion: {_ in
                        UIView.animate(withDuration: 0.3, animations: {
                            self.labelArray[i].alpha = 1
                            self.labelArray[i].text = fullSeed[i]
                            self.labelArray[i].isUserInteractionEnabled = true
                        })
                    })
                }
                
                verify.isUserInteractionEnabled = false
                verify.alpha = 0.4
                verifyLabel.text = "Doğrula"
                compare.text = ""
            }
        } catch {
            
        }
    }
    
    private func getSeed() throws -> String{
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: Constants.login.self)
            let seed = loginCredits.seed
            return seed
        } catch {
            throw Constants.NAError.seed404
        }
    }
    
    func start() {
 
            let click01 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click02 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click03 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click04 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click05 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click06 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click07 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click08 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click09 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click10 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click11 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click12 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click13 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click14 = UITapGestureRecognizer(target: self, action: #selector(respond))
            let click15 = UITapGestureRecognizer(target: self, action: #selector(respond))
            
            let shuffle = UITapGestureRecognizer(target: self, action: #selector(fx_shuffle))
            let showSeeds = UITapGestureRecognizer(target: self, action: #selector(fx_showSeeds))

            s01.addGestureRecognizer(click01)
            s02.addGestureRecognizer(click02)
            s03.addGestureRecognizer(click03)
            s04.addGestureRecognizer(click04)
            s05.addGestureRecognizer(click05)
            s06.addGestureRecognizer(click06)
            s07.addGestureRecognizer(click07)
            s08.addGestureRecognizer(click08)
            s09.addGestureRecognizer(click09)
            s10.addGestureRecognizer(click10)
            s11.addGestureRecognizer(click11)
            s12.addGestureRecognizer(click12)
            s13.addGestureRecognizer(click13)
            s14.addGestureRecognizer(click14)
            s15.addGestureRecognizer(click15)
            
            if isVerified {
                compare.text = "Anahtar kelimelerinizi sizden başka kimse bilemez. Buna biz de dahiliz. Lütfen anahtar kelimelerinizi yedekleyin."
                verify.addGestureRecognizer(showSeeds)
               
                fx_showSeeds()
            } else {
                fx_showSeeds()
                 
                verify.addGestureRecognizer(shuffle)
                
                verifyLabel.text = "Yedekledim"
                compare.text = "Anahtar kelimelerinizi yedekledikten sonra Yedekledim butonuna basarak doğrulama sürecini başlatabilirsiniz. Kelimeler karışık olarak sıralanacak, sizden yeniden sıralamanız istenecek."
            }
    }
    
    @objc func screenshotTaken() {
        delegate?.alertSomething(title: "Dikkat", message: "Ekran görüntüsü alarak anahtar kelimeleri yedeklemeniz durumunda, anahtar kelimeleriniz sizden başka birisinin eline geçebilir ve kripto paralarınızı kaybedebilirsiniz. Lütfen daha güvenli bir yedekleme metodu gerçekleştiriniz.")
    }
    
    private var seedContainer: String = ""
    override  func awakeFromNib() {
        
        verify.layer.cornerRadius = verify.frame.size.height / 2
        NotificationCenter.default.addObserver(self, selector: #selector(screenshotTaken), name: UIApplication.userDidTakeScreenshotNotification, object: nil)

        labelArray = [s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15]
        
    }
     
    @objc func respond(sender: UIGestureRecognizer) {
        generator.notificationOccurred(.success)
        if let label = sender.view as? UILabel {
            
            if label.alpha == 1 {
                UIView.animate(withDuration: 0.3, animations: { [self] in
                    label.alpha = 0.4
                    label.isUserInteractionEnabled = false
                    
                    if let t = label.text {
                        selectArray.append(t)
                    }
                    isPressed += 1
                    
                    if isPressed == 15 {
                        verify.isUserInteractionEnabled = true
                        verify.alpha = 1
                        
                        s01.isUserInteractionEnabled = false
                        s02.isUserInteractionEnabled = false
                        s03.isUserInteractionEnabled = false
                        s04.isUserInteractionEnabled = false
                        s05.isUserInteractionEnabled = false
                        s06.isUserInteractionEnabled = false
                        s07.isUserInteractionEnabled = false
                        s08.isUserInteractionEnabled = false
                        s09.isUserInteractionEnabled = false
                        s10.isUserInteractionEnabled = false
                        s11.isUserInteractionEnabled = false
                        s12.isUserInteractionEnabled = false
                        s13.isUserInteractionEnabled = false
                        s14.isUserInteractionEnabled = false
                        s15.isUserInteractionEnabled = false
                        
                        isVerifiable = true
                         
                    }
                }, completion: {_ in
                    label.isUserInteractionEnabled = true
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { [self] in
                    label.alpha = 1
                    isPressed -= 1
                    label.isUserInteractionEnabled = false
                    if let t = label.text {
                        if let index = selectArray.firstIndex(of: t) {
                            selectArray.remove(at: index)
                        }
                    }
                }, completion: {_ in
                    label.isUserInteractionEnabled = true
                })
            }
        }
        
        compare.text = ""
        for item in selectArray {
            compare.text = compare.text! + item + " "
        }
    }
}

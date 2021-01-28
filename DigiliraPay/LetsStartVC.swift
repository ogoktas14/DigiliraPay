//
//  LetsStartVC.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 15.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import Locksmith

class LetsStartVC: UIViewController {
    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var nextButtonLabel: UILabel!
    @IBOutlet weak var nextButtonContentView: UIView!
    
    var letsStartScrollView = UIScrollView()
    var goMainVCGesture = UITapGestureRecognizer()
    var isKeyWordView = false
    
    var logoAnimation = LogoAnimation()
    var warningView = WarningView()


    var gotoSeedRecover = false
    let BC = Blockchain()
    
    private func initial() {
        do {
            let user = try secretKeys.userData()
            self.BC.checkSmart(address: user.wallet)
        } catch {
            
        } 
    }
    
    func alertWarning (title: String, message: String, error: Bool = true) {
        DispatchQueue.main.async { [self] in
                logoAnimation.removeFromSuperview()
                
                warningView = UIView().loadNib(name: "warningView") as! WarningView
                warningView.frame = self.view.frame
                
                warningView.isError = error
                warningView.title = title
                warningView.message = message
                warningView.setMessage()
                
            self.view.addSubview(warningView)
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initial()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        nextButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        nextButtonView.layer.cornerRadius = nextButtonView.frame.height / 2
        nextButtonView.backgroundColor = UIColor(red:0.11, green:0.46, blue:1.00, alpha:1.0)
        
        setNextButton()
        
        goMainVCGesture = UITapGestureRecognizer(target: self, action: #selector(goMainVC))
        nextButtonView.addGestureRecognizer(goMainVCGesture)
        goMainVCGesture.isEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        setScrollView()
        if (gotoSeedRecover == true) {
            letsStartScrollView.scrollToPage(index: 3)
            nextButtonLabel.text = "Yedekledim"
        }
        nextButtonView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func setNextButton()
    {
        let nextButtonTap = UITapGestureRecognizer(target: self, action: #selector(nextButtonClick))
        nextButtonView.addGestureRecognizer(nextButtonTap)
        nextButtonView.isUserInteractionEnabled = true
        
        let backButtonTap = UITapGestureRecognizer(target: self, action: #selector(backButtonClick))
        backButtonView.addGestureRecognizer(backButtonTap)
        backButtonView.isUserInteractionEnabled = true
        backButtonView.isHidden = true
        backButtonView.alpha = 0
    }
    @objc func nextButtonClick()
    {
        let letsStartScrollPage = letsStartScrollView.contentOffset.x / letsStartScrollView.frame.size.width + 1
        
        if Int(letsStartScrollPage) == letsStartScrollView.subviews.count - 1
        {
            goMainVCGesture.isEnabled = true
        }
        else
        {
            goMainVCGesture.isEnabled = false
        }
        
        switch letsStartScrollPage
        {
        case 0:
            nextButtonLabel.text = "Başla"
        case 1:
            nextButtonLabel.text = "Devam"
        case 2:
            showKeywordView()
            nextButtonLabel.text = "Anahtar Oluştur"
        case 3:
            nextButtonLabel.text = "Yedekledim"
            UserDefaults.standard.set(false, forKey: "seedRecovery")
        case 4:
            nextButtonView.isHidden = true
            nextButtonLabel.text = "Doğrula ve Başla"
            showVerifyView()
        default:
            break
        }
        guard Int(letsStartScrollPage) < letsStartScrollView.subviews.count else {
            return
        }
        letsStartScrollView.scrollToPage(index: UInt8(letsStartScrollPage))
        self.backButtonView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.backButtonView.alpha = 1
        })
        
    }
    @objc func backButtonClick()
    {
        let letsStartScrollPage = letsStartScrollView.contentOffset.x / letsStartScrollView.frame.size.width - 1
        
        if Int(letsStartScrollPage) == letsStartScrollView.subviews.count
        {
            goMainVCGesture.isEnabled = true
        }
        else
        {
            goMainVCGesture.isEnabled = false
        }
        switch letsStartScrollPage
        {
        case 0:
            nextButtonLabel.text = "Başla"
        case 1:
            notShowKeyWordView()
            nextButtonLabel.text = "Devam"
        case 2:
            nextButtonLabel.text = "Anahtar Oluştur"
        case 3:
            nextButtonLabel.text = "Yedekledim"
            nextButtonView.isHidden = false

        default:
            break
        }
        
        guard letsStartScrollPage >= 0 else {
            return
        }
        letsStartScrollView.scrollToPage(index: UInt8(letsStartScrollPage))
        if Int(letsStartScrollPage) == 0
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.backButtonView.alpha = 0
            }) { (_) in
                self.backButtonView.isHidden = true
            }
        }
    }
    
    @objc func goMainVC()
    {
        performSegue(withIdentifier: "toMainScreen", sender: nil)
    }
    @objc func atla()
    {
        performSegue(withIdentifier: "toMainScreen", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toMainScreen"
        {
            let vc = segue.destination as? MainScreen
            vc?.pinkodaktivasyon = true
        }
    }
    
    func setScrollView()
    {
        letsStartScrollView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: scrollAreaView.frame.width,
                                            height: scrollAreaView.frame.height)
        letsStartScrollView.isScrollEnabled = false
        let scrollViewSize: CGSize = scrollAreaView.frame.size
        
        let letsStartView1: OnBoardingView = UIView().loadOnBoardingNib()
        letsStartView1.makeWhiteBackground()
        letsStartView1.setView(image: UIImage(named: "letsStart1")!,
                                titleFirst: "Blokzincir dünyasına",
                                titleSecond: "hoşgeldiniz!",
                                desc: "Dijital cüzdanını oluşturmaya hemen başlayalım.")
        
        letsStartView1.frame = CGRect(x: 0,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        
        let letsStartView2: OnBoardingView = UIView().loadOnBoardingNib()
        letsStartView2.makeWhiteBackground()
        letsStartView2.setView(image: UIImage(named: "letsStart2")!,
                                titleFirst: "Blokzincir cüzdanınız",
                                titleSecond: "şeffaf bir kasa gibidir",
                                desc: "Bu kasayı açabilecek anahtar ise sadece sizin kontrolünüzdedir. Bu kasayı sizden başka kimse açamaz. Anahtarı kaybederseniz buna siz de dahilsiniz.")
        
        letsStartView2.frame = CGRect(x: scrollViewSize.width,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        let letsStartView3: OnBoardingView = UIView().loadOnBoardingNib()
        letsStartView3.makeWhiteBackground()
        letsStartView3.setView(image: UIImage(named: "letsStart3")!,
                                titleFirst: "Anahtar kelimeler ile",
                                titleSecond: "her zaman güvende ol!",
                                desc: "Anahtar kelimelerini senden başka kimse bilemez. Buna biz de dahiliz. Bir sonraki ekranda kullandığınız cihaz üzerinde oluşturulan 15 'anahtar kelime'yi sırasıyla güvenli bir yere kaydetmeyi unutmayın.")
        
        letsStartView3.frame = CGRect(x: scrollViewSize.width * 2,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        let letsStartView4: LetsStartWordsView = UIView().loadNib(name: "LetsStartWordView") as! LetsStartWordsView
        letsStartView4.setTitles(title: "Anahtar kelimelerinizi", subTitle: "asla kaybetmeyin!", desc: "Eğer uygulamanız silinirse veya cüzdanınızı başka bir cihaza aktarmanız gerekirse bu kelimelere ihtiyaç duyacaksınız. Bu kelimeleri sırasıyla not alın.")
        letsStartView4.frame = CGRect(x: scrollViewSize.width * 3,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        let verifyView: Verify_StartView = UIView().loadNib(name: "Verify&StartView") as! Verify_StartView
        verifyView.delegate = self
        verifyView.frame = CGRect(x: scrollViewSize.width * 4,
                                  y: 0,
                                  width: scrollViewSize.width,
                                  height: scrollViewSize.height)
        verifyView.setView()
        
        letsStartScrollView.addSubview(letsStartView1)
        letsStartScrollView.addSubview(letsStartView2)
        letsStartScrollView.addSubview(letsStartView3)
        letsStartScrollView.addSubview(letsStartView4)
        letsStartScrollView.addSubview(verifyView)
        letsStartScrollView.contentSize = CGSize(width: scrollViewSize.width * CGFloat(letsStartScrollView.subviews.count),
                                                  height: scrollViewSize.height)
        
        letsStartScrollView.showsVerticalScrollIndicator = false
        letsStartScrollView.showsHorizontalScrollIndicator = false
        letsStartScrollView.isPagingEnabled = true
        scrollAreaView.addSubview(letsStartScrollView)
    }
    
    func showKeywordView()
    {
        if !isKeyWordView
        {
            isKeyWordView = !isKeyWordView
            UIView.animate(withDuration: 0.5, animations: {
                self.nextButtonView.frame.origin.x -= self.view.frame.width / 5
                self.nextButtonView.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
            })
        }
    }
    
    func notShowKeyWordView()
    {
        if isKeyWordView
        {
            isKeyWordView = !isKeyWordView
            UIView.animate(withDuration: 0.5, animations: {
                self.nextButtonView.frame.origin.x += self.view.frame.width / 5
                self.nextButtonView.backgroundColor = UIColor(red:0.11, green:0.46, blue:1.00, alpha:1.0)
            })
            
        }
    }
    func showVerifyView()
    {
        nextButtonContentView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.5, animations: {
            self.nextButtonView.frame.origin.x = 0
            self.nextButtonView.backgroundColor = UIColor(red:0.24, green:0.54, blue:1.00, alpha:1.0)
            self.nextButtonContentView.center.x = self.nextButtonView.frame.width / 2
        })
    }

    @IBAction func exitButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LetsStartVC: LetsStartSkipDelegate
{
    func warnUser() {
        alertWarning(title: "Dikkat", message: "Ekran görüntüsü alarak anahtar kelimeleri yedeklemeniz durumunda, anahtar kelimeleriniz sizden başka birisinin eline geçebilir ve kripto paralarınızı kaybedebilirsiniz. Lütfen daha güvenli bir yedekleme metodu gerçekleştiriniz.")
    }
    
    func skipTap() {
        atla()
        UserDefaults.standard.set(false, forKey: "seedRecovery")
    }
    
    func dogrula() {
        UserDefaults.standard.set(true, forKey: "seedRecovery")
        goMainVC()
    }
}

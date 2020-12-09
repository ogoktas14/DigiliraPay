//
//  OnBoardingVC.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 8.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import UserNotifications

class OnBoardingVC: UIViewController, PinViewDelegate, DisplayViewControllerDelegate {
    
    var gotoSeedRecover = false
    func doSomethingWith() {
        importAccountView.isHidden = true
        letsGoView.isHidden = true
        nowLetsGo()
    }
    
    func closePinView() {
        self.goMainVC()
    }
    
    func updatePinCode(code: Int32) {
        
    }
    
    func pinSuccess(res: Bool) {
        self.goMainVC()        
    }
    
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var letsGoView: UIView!
    @IBOutlet weak var importAccountView: UILabel!
    @IBOutlet weak var letsGoLabel: UILabel!
    @IBOutlet weak var sendWithQRView: UIView!

    
    var onBoardingScrollView = UIScrollView()
    let digiliraPay = digiliraPayApi()
    let BC = Blockchain()
    
    var onPinSuccess: ((_ result: Bool)->())?
    
    
    var trxs:[digilira.transfer] = []
    var QR:digilira.QR = digilira.QR.init()
    
    
    private func initial2() {
        letsGoView.isHidden = true
        importAccountView.isHidden = true
        pageControl.isHidden = true
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        digiliraPay.onError = { res, sts in
            DispatchQueue.main.async {
                
                switch sts {
                
                case 0:
                    let alert = UIAlertController(title: "Uygulamanızı Güncelleyin", message: "DigiliraPAY uygulamasını kullanmaya devam edebilmek için lütfen uygulamanızı güncelleyin.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                        exit(1)
                    }))
                    self.present(alert, animated: true)
                    break
                case 503:
                    let alert = UIAlertController(title: "Bir Hata Oluştu", message: "Şu anda hizmet veremiyoruz. Lütfen daha sonra yeniden deneyin.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                        exit(1)
                    }))
                    self.present(alert, animated: true)
                    
                    break;
                case 400, 404:
                    
                    let alert = UIAlertController(title: "Kullanıcı Bulunamadı", message: "Cüzdanınızı içeri aktararak başka bir cihazda açtıysanız bu cihazdan giriş yapamazsınız. Böyle bir işlem yapmadıysanız anahtar kelimelerinizi kullanarak cüzdanınızı yeniden tanımlayabilirsiniz.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                        self.letsGoView.isHidden = false
                        self.importAccountView.isHidden = false
                    }))
                    self.present(alert, animated: true)
                    
                    break
                    
                default:
                    
                    let alert = UIAlertController(title: "Bir Hata Oluştu..", message: "Maalesef şu an işleminizi gerçekleştiremiyoruz. Lütfen birazdan tekrar deneyin.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                        exit(1)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                }
            }
        }
        
        
        if BC.checkIfUser() {
            
            digiliraPay.onLogin2 = {user, status in
                DispatchQueue.main.async {
                    switch status {
                        case 200:
                        if user.status == 403 {
                            let alert = UIAlertController(title: "Hata", message: "Hesabınız bloke edilmiştir.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                                self.letsGoView.isHidden = false
                                self.importAccountView.isHidden = false
                                exit(0)
                            }))
                            self.present(alert, animated: true)
                            
                        }
                        
                        self.BC.checkSmart(address: user.wallet)
                        
                        if user.pincode == "-1"
                        {
                            self.goMainVC()
                            return
                        }
                        
                        if let pinView = UIView().loadNib(name: "PinView") as? PinView {
                            pinView.isEntryMode = true
                            pinView.setCode()
                            
                            pinView.delegate = self
                            
                            pinView.frame = CGRect(x: 0,
                                                   y: 0,
                                                   width: self.view.frame.width,
                                                   height: self.view.frame.height)
                            self.view.addSubview(pinView)
                        }
                        
                        break
                        
                    default:
                        
                        let alert = UIAlertController(title: "Hata", message: String(status!), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
                            self.letsGoView.isHidden = false
                            self.importAccountView.isHidden = false
                        }))
                        self.present(alert, animated: true)
                        break
                    }
                }
            }
            digiliraPay.login2()
        } else {
            self.letsGoView.isHidden = false
            self.importAccountView.isHidden = false
        }
    }
    
    
    @objc func goMainVC()
    {
        performSegue(withIdentifier: "toMainScreen", sender: nil)
    }
    
    override func viewDidLoad() {
        
        initial2()
        UNUserNotificationCenter.current().delegate = self;
        
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        let tapLetsGoViewGesture = UITapGestureRecognizer(target: self, action: #selector(letsGO))
        letsGoView.addGestureRecognizer(tapLetsGoViewGesture)
        letsGoView.isUserInteractionEnabled = true
        
        let importGesture = UITapGestureRecognizer(target: self, action: #selector(impoertAccount))
        importAccountView.addGestureRecognizer(importGesture)
        
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        setScrollView()
        setLetsGoView()
        UIView.animate(withDuration: 0.5)
        {
            self.onBoardingScrollView.scrollToPage(index: 2)
        }
        
        UIView.animate(withDuration: 1)
        {
            self.onBoardingScrollView.scrollToPage(index: 0)
        }
    }
    
    @objc func onDidReceiveData(_ sender: Notification) {

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    { return .lightContent }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toMainScreen"
        {
            let vc = segue.destination as? MainScreen
            vc?.pinkodaktivasyon = true
            vc?.QR = QR
        }
        if segue.identifier == "toLetsStartVC"
        {
            let vc = segue.destination as? LetsStartVC
            vc?.gotoSeedRecover = self.gotoSeedRecover
        }
    }
    
    func setLetsGoView()
    {
        letsGoView.layer.cornerRadius = letsGoView.frame.height / 2
        let letsGoGradient = CAGradientLayer()
        letsGoGradient.colors = [
            UIColor(red: 0.24, green: 0.54, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.4, blue: 1, alpha: 1).cgColor
        ]
        letsGoGradient.frame = letsGoView.bounds
        letsGoGradient.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        letsGoGradient.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        letsGoGradient.cornerRadius = letsGoView.frame.height / 2
        letsGoView.layer.addSublayer(letsGoGradient)
        letsGoLabel.layer.zPosition = 1
    }
    
    @objc func letsGO()
    {
        let versionLegal = UserDefaults.standard.value(forKey: "isLegalView")
        let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse")
        
        if versionLegal != nil && versionTerms != nil {
            nowLetsGo()
        } else {
            let controller = DynamicViewController()
            controller.delegate = self
            show(controller, sender: "sender")
        }
    }
    
    func nowLetsGo() {
        let alert = UIAlertController(title: "Lütfen bekleyin", message: "Cüzdanınız oluşturuluyor..", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        BC.create(){ (address) in
            if (address == "TRY AGAIN") {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "toLetsStartVC", sender: nil)
            }
        }
    }
    
    @objc func impoertAccount()
    {
        performSegue(withIdentifier: "toImportAccountVC", sender: nil)
    }
}

extension OnBoardingVC: UIScrollViewDelegate
{
    func setScrollView()
    {
        onBoardingScrollView.delegate = self
        onBoardingScrollView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: scrollAreaView.frame.width,
                                            height: scrollAreaView.frame.height)
        let scrollViewSize: CGSize = scrollAreaView.frame.size
        
        let onBoardingView1: OnBoardingView = UIView().loadOnBoardingNib()
        onBoardingView1.setView(image: UIImage(named: "onboarding1")!,
                                titleFirst: "Blokzincir",
                                titleSecond: "Ödeme Geçidi",
                                desc: "DigiliraPay’e hoşgeldin.\nBlockzincir tabanlı ödeme yöntemimizle tanış.")
        
        onBoardingView1.frame = CGRect(x: 0,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        
        let onBoardingView2: OnBoardingView = UIView().loadOnBoardingNib()
        onBoardingView2.setView(image: UIImage(named: "onboarding2")!,
                                titleFirst: "Kripto Paralarınızı",
                                titleSecond: "Güvenle Saklayın",
                                desc: "Kripto paralarınız bizimle her zaman güvende!")
        
        onBoardingView2.frame = CGRect(x: scrollViewSize.width,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        
        let onBoardingView3: OnBoardingView = UIView().loadOnBoardingNib()
        onBoardingView3.setView(image: UIImage(named: "onboarding3")!,
                                titleFirst: "Tüm İşlemler",
                                titleSecond: "Tek Hesapta Saklı",
                                desc: "Tüm işlemlerini tek hesaptan yönet, \ngüvenli bir şekilde al-sat.")
        
        onBoardingView3.frame = CGRect(x: scrollViewSize.width * 2,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        
        onBoardingScrollView.addSubview(onBoardingView1)
        onBoardingScrollView.addSubview(onBoardingView2)
        onBoardingScrollView.addSubview(onBoardingView3)
        onBoardingScrollView.contentSize = CGSize(width: scrollViewSize.width * 3,
                                                  height: scrollViewSize.height)
        
        
        
        onBoardingScrollView.showsVerticalScrollIndicator = false
        onBoardingScrollView.showsHorizontalScrollIndicator = false
        onBoardingScrollView.isPagingEnabled = true
        scrollAreaView.addSubview(onBoardingScrollView)
        
        pageControl.transform = CGAffineTransform(scaleX: 3, y: 3)
        scrollAreaView.addSubview(pageControl)
        
        
        pageControl.pageIndicatorTintColor = UIColor(red:0.66, green:0.71, blue:0.95, alpha:1.0)
        pageControl.currentPageIndicatorTintColor = UIColor(red:0.24, green:0.54, blue:1.00, alpha:1.0)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        switch scrollView.contentOffset.x
        {
        case 0:
            pageControl.currentPage = 0
        case scrollView.frame.width:
            pageControl.currentPage = 1
        case scrollView.frame.width * 2:
            pageControl.currentPage = 2
        default:
            break
        }
    }
}

extension OnBoardingVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.body);
        completionHandler([.alert, .sound])
    }}


class DynamicViewController: UIViewController, LegalDelegate {
    weak var delegate : DisplayViewControllerDelegate?
    
    var m: String?
    var v: Int?
    let BC = Blockchain()
    
    
    func showLegal(mode: digilira.terms) {
        print(1)
    }
    
    func dismissLegalView() {
        
        let versionLegal = UserDefaults.standard.value(forKey: "isLegalView") as? Int
        let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse") as? Int
        
        if versionLegal != nil && versionTerms != nil {
            UIView.animate(withDuration: 0.4, animations: {
                self.view.frame.origin.y = self.view.frame.height
            })
            
            self.dismiss(animated: true, completion: nil)
            
            delegate?.doSomethingWith()
        }
        showView()
    }
    
    override func loadView() {
        showView()
    }
    
    func showView() {
        
        view = UIView()
        view.backgroundColor = .white
        view.alpha = 1
        
        let versionLegal = UserDefaults.standard.value(forKey: "isLegalView") as? Int
        let versionTerms = UserDefaults.standard.value(forKey: "isTermsOfUse") as? Int
        
        
        let legalXib = UIView().loadNib(name: "LegalView") as! LegalView
        
        legalXib.frame = CGRect(x: 0,
                                y: 0,
                                width: view.frame.width,
                                height: view.frame.height)
        
        legalXib.delegate = self
        
        
        legalXib.backView.isHidden = true
        
        if versionLegal == nil {
            legalXib.titleLabel.text = digilira.legalView.title
            legalXib.contentLabel.text = digilira.legalView.text
        }
        
        if versionTerms == nil {
            legalXib.titleLabel.text = digilira.termsOfUse.title
            legalXib.contentLabel.text = digilira.termsOfUse.text
        }
        
        
        legalXib.setView()
        
        view.addSubview(legalXib)
    }
}

protocol DisplayViewControllerDelegate : NSObjectProtocol{
    func doSomethingWith()
}

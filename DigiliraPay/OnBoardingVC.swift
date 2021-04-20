//
//  OnBoardingVC.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import UserNotifications
import WavesSDK
import Locksmith

class OnBoardingVC: UIViewController, DisplayViewControllerDelegate {
    
    @IBOutlet var curtain:UIView!
    let lang = Localize()
    var gotoSeedRecover = false
    
    func doSomethingWith() {
        importAccountView.isHidden = true
        letsGoView.isHidden = true
        nowLetsGo()
    }
    
    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var letsGoView: UIView!
    @IBOutlet weak var importAccountView: UILabel!
    @IBOutlet weak var letsGoLabel: UILabel!
    
    var notifyDest: NSNotification.Name?
    
    var logoAnimation = LogoAnimation()
    var warningView = WarningView()
    var throwEngine = ErrorHandling()

    var onScreeen = false
    var onBoardingScrollView = UIScrollView()
    let BC = BlockchainService()
    let digiliraPay = DigiliraPayService()
    
    var QR:Constants.QR = Constants.QR.init()
 
    private func initial2() {        
        letsGoView.isHidden = true
        importAccountView.isHidden = true
        pageControl.isHidden = false
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        if BC.checkIfUser() {
            DispatchQueue.main.async { [self] in
                if let user = try? secretKeys.userData() {
                    self.BC.checkSmart(address: user.wallet)
                    self.goMainVC()
                }
            }
        } else {
            self.letsGoView.isHidden = false
            self.importAccountView.isHidden = false
            curtain.isHidden = true
            
        }
    }
    
    private func setUI() {
        letsGoLabel.text = lang.getLocalizedString(Localize.onBoardingView.lets_start.rawValue)
        importAccountView.text = lang.getLocalizedString(Localize.onBoardingView.import_account.rawValue)
    }
    
    func checkSeed() {
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: Constants.login.self)
            let seed = loginCredits.seed
            
            nowLetsGo(imported: true,  seed: seed)
        } catch {
            print (error)
        }
    }
    
    func waitPlease () {
        logoAnimation.removeFromSuperview()
        
        DispatchQueue.main.async { [self] in
            
            logoAnimation = UIView().loadNib(name: "LogoAnimation") as! LogoAnimation
            logoAnimation.frame = self.view.frame
            
            logoAnimation.setImage()
            
            self.view.addSubview(logoAnimation)
            
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
    
    
    
    @objc func goMainVC()
    {
        performSegue(withIdentifier: "toMainScreen", sender: nil)
    }
    
    func initialWaves() {
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if let E = environment as? Bool {
                if !E {
                    WavesSDK.initialization(servicesPlugins: .init(data: [],
                                                                   node: [],
                                                                   matcher: []),
                                            enviroment: .init(server: .testNet, timestampServerDiff: 0))
                    return
                }
            }
        }
        
        UserDefaults.standard.setValue(true, forKey: "environment")
        
        WavesSDK.initialization(servicesPlugins: .init(data: [],
                                                       node: [],
                                                       matcher: []),
                                enviroment: .init(server: .mainNet, timestampServerDiff: 0))
        return
    }
    
    override func viewDidLoad() {
        initialWaves()

        initial2()
        setUI()
        UNUserNotificationCenter.current().delegate = self;
        
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
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
        letsGoView.layer.cornerRadius = 25
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
    
    func nowLetsGo(imported: Bool = false, seed: String = "") {
        
        BC.onComplete = { [self] res, status in
            print(res,status)
            switch status {
            case 200:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: { [self] in
                        logoAnimation.alpha = 0
                        
                    },completion: { [self]_ in
                        logoAnimation.removeFromSuperview()
                        logoAnimation.alpha = 1
                        
                        if imported {
                            self.goMainVC()
                        }else {
                            self.performSegue(withIdentifier: "toLetsStartVC", sender: nil)
                        }
                    })
                }
            case 400:
                self.alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue), message: lang.getLocalizedString(Localize.keys.check_the_information_entered.rawValue), error: true)
                letsGoView.isHidden = false
            case 502:
                self.alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue), message: lang.getLocalizedString(Localize.keys.cannot_perform_this_action_try_again.rawValue), error: true)
            default:
                self.alertWarning(title: lang.getLocalizedString(Localize.keys.an_error_occured.rawValue), message: lang.getLocalizedString(Localize.keys.cannot_perform_this_action_try_again.rawValue), error: true)
            }
        }
        
        DispatchQueue.main.async { [self] in
            waitPlease()
        }

        BC.createMainnet(imported: imported, importedSeed: seed)
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
        onBoardingView1.setView(image: UIImage(named: "letsStart1")!,
                                titleFirst: lang.getLocalizedString(Localize.onBoardingView.page_1_line_1.rawValue),
                                titleSecond: lang.getLocalizedString(Localize.onBoardingView.page_1_line_2.rawValue),
                                desc: lang.getLocalizedString(Localize.onBoardingView.page_1_line_3.rawValue))
        
        onBoardingView1.frame = CGRect(x: 0,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        let onBoardingView2: OnBoardingView = UIView().loadOnBoardingNib()
        onBoardingView2.setView(image: UIImage(named: "onboarding2")!,
                                titleFirst: lang.getLocalizedString(Localize.onBoardingView.page_2_line_1.rawValue),
                                titleSecond: lang.getLocalizedString(Localize.onBoardingView.page_2_line_2.rawValue),
                                desc: lang.getLocalizedString(Localize.onBoardingView.page_2_line_3.rawValue))
        
        onBoardingView2.frame = CGRect(x: scrollViewSize.width,
                                       y: 0,
                                       width: scrollViewSize.width,
                                       height: scrollViewSize.height)
        
        let onBoardingView3: OnBoardingView = UIView().loadOnBoardingNib()
        onBoardingView3.setView(image: UIImage(named: "onboarding3")!,
                                titleFirst: lang.getLocalizedString(Localize.onBoardingView.page_3_line_1.rawValue),
                                titleSecond: lang.getLocalizedString(Localize.onBoardingView.page_3_line_2.rawValue),
                                desc: lang.getLocalizedString(Localize.onBoardingView.page_3_line_3.rawValue))
        
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
        
        scrollAreaView.addSubview(pageControl)
        
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
    
    func showLegal(mode: Constants.terms) {
        
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
            legalXib.titleLabel.text = NSLocalizedString(Localize.keys.new_legal_view_title.rawValue, comment: "")
            legalXib.contentText.text = Constants.legalView.text
            legalXib.setView(mode: 0)
        }
        
        if versionTerms == nil {
            legalXib.titleLabel.text = NSLocalizedString(Localize.keys.new_terms_of_use_title.rawValue, comment: "")
            legalXib.contentText.text = Constants.termsOfUse.text
            legalXib.setView(mode: 1)
        }
        
        
        
        view.addSubview(legalXib)
    }
}

protocol DisplayViewControllerDelegate : NSObjectProtocol{
    func doSomethingWith()
}

extension NSNotification.Name {
    enum Notifications: String {
        case foo, bar
    }
    init(_ value: Notifications) {
        self = NSNotification.Name(value.rawValue)
    }
}

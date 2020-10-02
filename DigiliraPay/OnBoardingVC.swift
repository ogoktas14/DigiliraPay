//
//  OnBoardingVC.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 8.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import Locksmith

class OnBoardingVC: UIViewController {

    @IBOutlet weak var scrollAreaView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var letsGoView: UIView!
    @IBOutlet weak var importAccountView: UILabel!
    @IBOutlet weak var letsGoLabel: UILabel!
    
    
    var onBoardingScrollView = UIScrollView()
    let digiliraPay = digiliraPayApi()
    
    var kullanici: digilira.user?

    var trxs:[digilira.transfer] = []
    var QR: String?

    
    
    func fetch() {

         
    }

    
    private func initial2() {
        letsGoView.isHidden = true
        importAccountView.isHidden = true
        pageControl.isHidden = true
         
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
        
        if dictionary != nil {
            
            digiliraPay.login() { (json) in
                DispatchQueue.main.async {
                    print(json)
                    self.kullanici = json

                    self.goMainVC()
                    let BC = Blockchain()
                    BC.checkSmart(address: self.kullanici!.wallet!)
                    

                }
             }
        } else {
            print("EMPTY")
                   let digiliraPay = createWallet()

                   digiliraPay.create(){ (seed) in
                       DispatchQueue.main.async {
                                                            
                        self.letsGoView.isHidden = false
                        self.importAccountView.isHidden = false
  
                       }
                   }
        }
        
    }
    
    
    @objc func goMainVC()
    {
        performSegue(withIdentifier: "toMainScreen", sender: nil)
    }
    
    override func viewDidLoad() {
        
        initial2()
        
        super.viewDidLoad()
        
        let tapLetsGoViewGesture = UITapGestureRecognizer(target: self, action: #selector(letsGO))
        letsGoView.addGestureRecognizer(tapLetsGoViewGesture)
        letsGoView.isUserInteractionEnabled = true
        
        let importGesture = UITapGestureRecognizer(target: self, action: #selector(impoertAccount))
        importAccountView.addGestureRecognizer(importGesture)
        
        let main = UITapGestureRecognizer(target: self, action: #selector(letsGO))
        importAccountView.addGestureRecognizer(main)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)

        
    }
    override func viewDidAppear(_ animated: Bool) {
        setScrollView()
        setLetsGoView()
    }
    
    @objc func onDidReceiveData(_ sender: Notification) {
       // Do what you need, including updating IBOutlets
        let A = UserDefaults.standard.object(forKey: "QRURL")
        QR = A as! String
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    { return .lightContent }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toMainScreen"
        {
            let vc = segue.destination as? MainScreen
            vc?.kullanici = kullanici
            vc?.pinkodaktivasyon = true
            vc?.QR = QR
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
        performSegue(withIdentifier: "toLetsStartVC", sender: nil)
    }
    
    @objc func impoertAccount()
    {
        performSegue(withIdentifier: "toLetsStartVC", sender: nil)

        //performSegue(withIdentifier: "toImportAccountVC", sender: nil)
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
                                titleFirst: "Blokzincir Tabanlı",
                                titleSecond: "Ödeme Geçidi",
                                desc: "Digilirapay’e hoşgeldin.\nBlockzincir tabanlı ödeme yöntemimizle tanış.")
        
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



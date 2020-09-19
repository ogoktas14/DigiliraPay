//
//  ImportAccountVC.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit

class ImportAccountVC: UIViewController {

    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var nextButtonLabel: UILabel!
    @IBOutlet weak var keyWordsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButtonView.layer.maskedCorners = [.layerMinXMinYCorner]
        nextButtonView.layer.cornerRadius = nextButtonView.frame.height / 2
        nextButtonView.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
        let tapGoHome = UITapGestureRecognizer(target: self, action: #selector(goHome))
        nextButtonView.addGestureRecognizer(tapGoHome)
        
        let tapGoBack = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backButtonView.addGestureRecognizer(tapGoBack)
    
    }
    

    @objc func goHome()
    {
        performSegue(withIdentifier: "toMainVCFromImport", sender: nil)
    }
    
    @objc func goBack()
    {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func exitButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

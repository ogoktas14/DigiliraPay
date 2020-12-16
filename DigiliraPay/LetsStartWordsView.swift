//
//  LetsStartWordsView.swift
//  
//
//  Created by Yusuf Özgül on 23.08.2019.
//

import UIKit
import Locksmith

class LetsStartWordsView: UIView {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var view8: UIView!
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view10: UIView!
    @IBOutlet weak var view11: UIView!
    @IBOutlet weak var view12: UIView!
    @IBOutlet weak var view13: UIView!
    @IBOutlet weak var view14: UIView!
    @IBOutlet weak var view15: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label13: UILabel!
    @IBOutlet weak var label14: UILabel!
    @IBOutlet weak var label15: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var okButtonView: UIButton!
    
    var viewArray: [UIView] = []
    var labelArray: [UILabel] = []
    
    weak var delegate: seedViewDelegate?

    override func awakeFromNib()
    {
        viewArray = [view1, view2, view3, view4, view5, view6, view7, view8, view9, view10, view11, view12, view13, view14, view15]
        labelArray = [label1, label2, label3, label4, label5, label6, label7, label8, label9, label10, label11, label12, label13, label14, label15]
        setViewLayout()
        
    }
    
    @IBAction func goHomeButton(_ sender: Any)
    {
        delegate?.closeSeedView()
    }
    
    private func setViewLayout()
    {
        viewArray.forEach { (view) in
            view.layer.cornerRadius = 10
            view.backgroundColor = .white
            
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.3
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 4
            
        }
        
        okButtonView.isHidden = true
        
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: digilira.login.self)
            let seed = loginCredits.seed
            let fullNameArr : [String] = seed.components(separatedBy: " ")
            
            for i in 0..<15 {
                self.labelArray[i].text = fullNameArr[i]
            }
        } catch {
            print (error)
        }
        
    }
    func setTitles(title: String, subTitle: String, desc: String)
    {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.descLabel.text = desc
        
        titleLabel.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
        subTitleLabel.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
        descLabel.textColor = UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0)
        
        
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            titleLabel.textColor = .white
            subTitleLabel.textColor = .systemGray
            descLabel.textColor = .systemGray2
        }
    }
}

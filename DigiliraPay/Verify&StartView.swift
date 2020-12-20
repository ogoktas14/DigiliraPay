//
//  Verify&StartView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 23.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//
import Locksmith
import UIKit

class Verify_StartView: UIView {
    
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
    @IBOutlet weak var okButton: UIButton!

    @IBOutlet weak var overall: UILabel!
    
    var keywordArray: [String] = []
    var selectedWords: [String] = []
    public var shuffled: [String] = []
    private var seed: String?
    
    var verified: Bool = false
    
    var word: Int8 = 0
    
    var labelSelectedFont = UIFont(name: "Avenir-Black", size: 16)
    var labelUnselectedFont = UIFont(name: "Avenir-Heavy", size: 16)
    
    weak var delegate: LetsStartSkipDelegate?
    
    override func awakeFromNib()
    {
        setView1()
    }
    
    func setView1() {
        var sensitiveSource = "sensitive"
        
        if let environment = UserDefaults.standard.value(forKey: "environment") {
            if environment as! Bool {
                sensitiveSource = "sensitiveMainnet"
            }
        }
        
        do {
            let loginCredits = try secretKeys.LocksmithLoad(forKey: sensitiveSource, conformance: digilira.login.self)
           
                let seed = loginCredits.seed
            self.seed = seed
                let fullNameArr : [String] = seed.components(separatedBy: " ")
                keywordArray = fullNameArr
                shuffled = fullNameArr.shuffled()
        } catch {
            print (error)
        }
        
        overall.text = ""
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap7 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap8 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap9 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap10 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap11 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap12 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap13 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap14 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        let tap15 = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        view1.addGestureRecognizer(tap1)
        view2.addGestureRecognizer(tap2)
        view3.addGestureRecognizer(tap3)
        view4.addGestureRecognizer(tap4)
        view5.addGestureRecognizer(tap5)
        view6.addGestureRecognizer(tap6)
        view7.addGestureRecognizer(tap7)
        view8.addGestureRecognizer(tap8)
        view9.addGestureRecognizer(tap9)
        view10.addGestureRecognizer(tap10)
        view11.addGestureRecognizer(tap11)
        view12.addGestureRecognizer(tap12)
        view13.addGestureRecognizer(tap13)
        view14.addGestureRecognizer(tap14)
        view15.addGestureRecognizer(tap15)
        
        setView()
    }
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        if let tapped = gesture.view {
             
            if let label = tapped.subviews[0] as? UILabel {
                if let text = overall.text {
                    if let label = label.text {
                        
                        if let index = selectedWords.firstIndex(of: label) {
                            selectedWords.remove(at: index)
                            tapped.alpha = 1
                            let parsed = text.replacingOccurrences(of: label + " ", with: "")
                            
                            overall.text = parsed
                        } else {
                            tapped.alpha = 0.1
                            overall.text = text + label + " "
                            selectedWords.append(label)
                        }
                    }
                }
            }
            
            if seed != nil {
                if selectedWords == keywordArray {
                    overall.textColor = .blue
                    verified = true
                    okButton.setTitle("Doğrula", for: .normal)
                } else {
                    verified = false
                    overall.textColor = .red
                    okButton.setTitle("Bu aşamayı atla", for: .normal)
                }
            }
             
        }
        
    }
     

    func setView()
    {

        if keywordArray.count > 0 {
            
            label1.text = keywordArray[0]
            label2.text = keywordArray[1]
            label3.text = keywordArray[2]
            label4.text = keywordArray[3]
            label5.text = keywordArray[4]
            label6.text = keywordArray[5]
            label7.text = keywordArray[6]
            label8.text = keywordArray[7]
            label9.text = keywordArray[8]
            label10.text = keywordArray[9]
            label11.text = keywordArray[10]
            label12.text = keywordArray[11]
            label13.text = keywordArray[12]
            label14.text = keywordArray[13]
            label15.text = keywordArray[14]
        }
    }
    
    func setFirstView(lineView: UIView, count: Int)
    {
        let wordScrollView = UIScrollView()
        wordScrollView.frame = lineView.frame
        wordScrollView.frame.origin.x = 0
        wordScrollView.frame.origin.y = 0
        wordScrollView.showsHorizontalScrollIndicator = false
        
        for i in 0...2
        {
            let aview = UIView()
            aview.isUserInteractionEnabled = false
            aview.frame = CGRect(x: 0,
                                 y: 0,
                                 width: wordScrollView.frame.width / 4,
                                 height: lineView.frame.size.height)
            aview.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.99, alpha:1.0)
            aview.layer.cornerRadius = lineView.frame.size.height / 2
            let label = UILabel()
            
            label.text = shuffled[i + (count*3)]
            
            label.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
            label.font = labelUnselectedFont
            label.frame = CGRect(x: 0,
                                 y: 0,
                                 width: wordScrollView.frame.width / 4,
                                 height: lineView.frame.size.height)
            label.textAlignment = .center
            label.tag = i
            aview.addSubview(label)
            
            let button = UIButton()
            button.frame = label.frame
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(self.tapWordView(sender:)), for: .touchUpInside)
            button.addSubview(aview)
            button.frame = CGRect(x: (wordScrollView.frame.width / 4 + 10) * CGFloat(i) + 10,
                                  y: 0,
                                  width: wordScrollView.frame.width / 4,
                                  height: lineView.frame.size.height)
            
            wordScrollView.addSubview(button)
            
        }
        wordScrollView.contentSize.width = wordScrollView.frame.width / 3 * CGFloat(wordScrollView.subviews.count)
        lineView.addSubview(wordScrollView)
        
        
    }
  

    @objc func tapWordView(sender: UIButton)
    {

        if let aView = sender.subviews.first
        {
            if aView.backgroundColor == UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            {
                aView.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.99, alpha:1.0)
                if let label = aView.subviews.first as? UILabel
                {
                    selectedWords.removeLast()

                    label.textColor = UIColor(red:0.65, green:0.65, blue:0.66, alpha:1.0)
                    label.font = labelUnselectedFont
                }
            }
            else
            {
                aView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
                if let label = aView.subviews.first as? UILabel
                {
                    
                    selectedWords.append(label.text!)
                    print(selectedWords)

                    label.isHidden = true
                    label.textColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
                    label.font = labelSelectedFont
                    
                    word += 1

                    if (word == 15) {
                        print (selectedWords, keywordArray)
                        delegate?.dogrula()

                    }
                    
                }
            }
            
        }
    }
    
    @IBAction func skipButton(_ sender: Any)
    {
        if verified {
            delegate?.dogrula()
        } else {
            delegate?.skipTap()
        }
    }
}

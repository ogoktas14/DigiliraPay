//
//  Verify&StartView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 23.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//
import Locksmith
import UIKit

class Verify_StartView: UIView {

    @IBOutlet weak var scrollLine1: UIView!
    @IBOutlet weak var scrollLine2: UIView!
    @IBOutlet weak var scrollLine3: UIView!
    @IBOutlet weak var scrollLine4: UIView!
    @IBOutlet weak var scrollLine5: UIView!
    @IBOutlet weak var scrollLine6: UIView!
    
    var keywordArray: [String] = []
    var selectedWords: [String] = []
    public var shuffled: [String] = []
    
    var word: Int8 = 0
    
    var labelSelectedFont = UIFont(name: "Montserrat-ExtraBold", size: 16)
    var labelUnselectedFont = UIFont(name: "Montserrat-SemiBold", size: 16)
    
    weak var delegate: LetsStartSkipDelegate?
    
    override func awakeFromNib()
    {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "sensitive")
        let seed = dictionary?["seed"] as! String
        
        let fullNameArr : [String] = seed.components(separatedBy: " ")
        keywordArray = fullNameArr
        shuffled = fullNameArr.shuffled()
        
    }

    func setView()
    {

        let viewArray = [scrollLine1, scrollLine2, scrollLine3, scrollLine4, scrollLine5]
        var count = 0
        viewArray.forEach { lineView in
            if count % 2 == 0
            { setFirstView(lineView: lineView!, count: count) }
            else
            { setFirstView(lineView: lineView!, count: count) }
            count += 1
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
        delegate?.skipTap()
    }
}

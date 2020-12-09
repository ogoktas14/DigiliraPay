//
//  HighlightedButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: Float = 10
    static let  borderWidth = 2.0
}


class trxLabel: UILabel {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        let radius = CGFloat(10)
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius

        
        
    }
    
}


class smallButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        self.setTitleColor(.white, for: .normal)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.cornerRadius = self.frame.height / 2
        let letsGoGradient = CAGradientLayer()
        letsGoGradient.colors = [
            UIColor(red: 0.24, green: 0.54, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.4, blue: 1, alpha: 1).cgColor
        ]
        letsGoGradient.frame = self.bounds
        letsGoGradient.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        letsGoGradient.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        letsGoGradient.cornerRadius = self.frame.height / 2
        layer.insertSublayer(letsGoGradient, at: 0)
 
        
    }
    
}

class MyLabel: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
         
        let gradientColor1 = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0).cgColor
        let gradientColor2 = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0).cgColor
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        
        
        btnGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        btnGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
        self.layer.masksToBounds = true
        
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10

        
    }
    
}

class DarkGreyGradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.cornerRadius = self.frame.height / 2

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let gradientColor1 = UIColor(red: 0.4392, green: 0.4392, blue: 0.4392, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.498, green: 0.498, blue: 0.498, alpha: 1.0).cgColor
        
        theLayer.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        theLayer.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        
        theLayer.colors = [gradientColor1, gradientColor2]
 
        theLayer.frame = self.bounds
        theLayer.cornerRadius = self.frame.height / 2

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}


class BlackNoRadGradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.cornerRadius = 10

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        let gradientColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor

        theLayer.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        theLayer.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        
        theLayer.colors = [gradientColor1, gradientColor2]
 
        theLayer.frame = self.bounds
        theLayer.cornerRadius = 10

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class BlackGradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.cornerRadius = self.frame.height / 2

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        let gradientColor1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor

        theLayer.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        theLayer.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        
        theLayer.colors = [gradientColor1, gradientColor2]
 
        theLayer.frame = self.bounds
        theLayer.cornerRadius = self.frame.height / 2

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class BlueNoRadGradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight] 

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let gradientColor1 = UIColor(red: 0.24, green: 0.54, blue: 1, alpha: 1).cgColor
        let gradientColor2 = UIColor(red: 0, green: 0.4, blue: 1, alpha: 1).cgColor
        
        theLayer.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        theLayer.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        
        theLayer.colors = [gradientColor1, gradientColor2]
 
        theLayer.frame = self.bounds

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class BlueGradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.cornerRadius = self.frame.height / 2

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let gradientColor1 = UIColor(red: 0.24, green: 0.54, blue: 1, alpha: 1).cgColor
        let gradientColor2 = UIColor(red: 0, green: 0.4, blue: 1, alpha: 1).cgColor
        
        theLayer.startPoint = CGPoint(x: 0.17355118936567193, y: 1.2736177884615385)
        theLayer.endPoint = CGPoint(x: 0.8794163945895522, y: -0.8311899038461539)
        
        theLayer.colors = [gradientColor1, gradientColor2]
 
        theLayer.frame = self.bounds
        theLayer.cornerRadius = self.frame.height / 2

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 1, green: 1, blue: 0.9961, alpha: 1.0).cgColor
        
        theLayer.colors = [gradientColor1, gradientColor2]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class TextViewDP: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 1, green: 1, blue: 0.9961, alpha: 1.0).cgColor
        
        theLayer.colors = [gradientColor1, gradientColor2]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class digiliraView: UIView {
    let btnGradient = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let gradientColor1 = UIColor(red:0.57, green:0.18, blue:0.42, alpha:1.0).cgColor
        let gradientColor2 = UIColor(red:0.88, green:0.08, blue:0.16, alpha:1.0).cgColor
         
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false

        btnGradient.frame = layer.bounds
        btnGradient.masksToBounds = true

        btnGradient.colors = [gradientColor1, gradientColor2]
        self.translatesAutoresizingMaskIntoConstraints = false
        btnGradient.locations = [0.0, 1.0]
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
    }
    
}

 


class profileView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        let radius = CGFloat(20)
        
        self.backgroundColor = UIColor.white
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 20.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        
        
    }
}


class TabBarView: UIView {
    
  
    
    @IBOutlet weak var img0: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    
    @IBOutlet var view: UIView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func initialize() {
        
        Bundle.main.loadNibNamed("TabBar", owner: self, options: nil)
        addSubview(view)
        
        //view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
        view.frame = self.bounds
        
        //img1.image = (UIImage(named: "iconMain"))
        //img2.image = (UIImage(named: "iconPerson"))
        //img0.image = (UIImage(named: "iconQR"))

        
    }
    
}



class textView1: UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        let radius = CGFloat(5)
        
        self.backgroundColor = UIColor.white
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
    }
    
}


class headerLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        let radius = CGFloat(20)
        
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.8941, green: 0.8941, blue: 0.8941, alpha: 1.0).cgColor
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        
        
        btnGradient.startPoint = CGPoint(x: 0.0, y: 1)
        btnGradient.endPoint = CGPoint(x: 1, y: 0.0)
        btnGradient.cornerRadius = radius
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        
        
    }
    
}


class digiliraViewWhite: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        let radius = CGFloat(5)
        
        self.backgroundColor = UIColor.white
        
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.8941, green: 0.8941, blue: 0.8941, alpha: 1.0).cgColor
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = CGRect(x: 0, y: 0, width: 70, height:100)
        btnGradient.colors = [gradientColor1, gradientColor2]
        
        
        btnGradient.startPoint = CGPoint(x: 0.0, y: 1)
        btnGradient.endPoint = CGPoint(x: 1, y: 0.0)
        btnGradient.cornerRadius = radius
        
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 20.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius

        
    }
    
}


class coinView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    
    func initializeLabel() {
        
        
        self.backgroundColor = UIColor.white
        
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1.0).cgColor
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        
        
        btnGradient.startPoint = CGPoint(x: 0.0, y: 1)
        btnGradient.endPoint = CGPoint(x: 1, y: 0.0)
        
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.masksToBounds = false
        
        
    }
    
}


class MyCustomTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 15.0
         self.backgroundColor = UIColor.white
        self.tintColor = UIColor.red
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)

        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.masksToBounds = false


    }
}


class HighlightedButton: UIButton {
    
    @IBInspectable var highlightedBackground: UIColor?
    private var defaultBackgroundColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color = UIColor.white
        let disabledColor = color.withAlphaComponent(0.7)
        
        self.frame.origin = CGPoint(x: (((superview?.frame.width)! / 2) - (self.frame.width / 2)), y: self.frame.origin.y)
        
        self.layer.cornerRadius = 25.0
        self.clipsToBounds = true
        
        self.layer.borderColor = color.cgColor
        
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
        
        let gradientColor1 = UIColor(red:0.57, green:0.18, blue:0.42, alpha:1.0).cgColor
        let gradientColor2 = UIColor(red:0.88, green:0.08, blue:0.16, alpha:1.0).cgColor
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        
 
        btnGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        btnGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.layer.insertSublayer(btnGradient, at: 0)
        
        self.contentEdgeInsets.bottom = 4
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
 
    
    override var isHighlighted: Bool {
        didSet {
            setupBackgroundColor()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupBackgroundColor()
    }
}

private extension HighlightedButton {
    
    func initialize() {
     }
    
    func setupBackgroundColor() {
        let gradientColor1 = UIColor.yellow
        let gradientColor2 = UIColor.blue
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        self.layer.insertSublayer(btnGradient, at: 0)
        
    }
}

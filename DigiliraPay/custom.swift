//
//  HighlightedButton.swift
//  WavesWallet-iOS
//
//  Created by Hayrettin İletmiş on 24.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
         
                
        self.layer.masksToBounds = true
         
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.backgroundColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10

        
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
        let gradientColor1 = UIColor(red: 0.5882, green: 0.1922, blue: 0.4471, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.8941, green: 0.0941, blue: 0.1686, alpha: 1.0).cgColor
        
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

class GradientImage: UIImageView {

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
        let gradientColor2 = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
        
        theLayer.colors = [gradientColor1, gradientColor2]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class GradientView1: UIView {

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
        let gradientColor2 = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
        
        theLayer.colors = [gradientColor1, gradientColor2]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

class HeaderTotalColor: UIView {

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
        let gradientColor1 = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4).cgColor
        let gradientColor2 = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.4).cgColor
        
        theLayer.colors = [gradientColor1, gradientColor2]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
        theLayer.cornerRadius = 25
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.masksToBounds = false
        layer.cornerRadius = 25

    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}


class DLGradient: UIView {

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
        let gradientColor1 = UIColor(red: 0.5882, green: 0.1922, blue: 0.4471, alpha: 1.0).cgColor
        let gradientColor2 = UIColor(red: 0.8941, green: 0.0941, blue: 0.1686, alpha: 1.0).cgColor
        
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


class InfoView: UIView {

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
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
        layer.cornerRadius = 10

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


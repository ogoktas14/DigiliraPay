//
//  ProfileSettingsView.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 1.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit

class ProfileSettingsView: UIView {

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameInfoLabel: UILabel!
    @IBOutlet weak var surNameInfoLabel: UILabel!
    @IBOutlet weak var mailInfoLabel: UILabel!
    @IBOutlet weak var phoneNumberInfoLabel: UILabel!
    @IBOutlet weak var countryInfoLabel: UILabel!
    @IBOutlet weak var notificationInfoLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surNameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: ProfileSettingsViewDelegate?
    
    var infoColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.3)
    var textColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    override func awakeFromNib()
    {
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            infoColor = UIColor.secondaryLabel
            textColor = .white
        }
        
        nameInfoLabel.textColor = infoColor
        surNameInfoLabel.textColor = infoColor
        mailInfoLabel.textColor = infoColor
        phoneNumberInfoLabel.textColor = infoColor
        countryInfoLabel.textColor = infoColor
        
        nameTextField.textColor = textColor
        surNameTextField.textColor = textColor
        mailTextField.textColor = textColor
        phoneTextField.textColor = textColor
        countryTextField.textColor = textColor
        notificationInfoLabel.textColor = textColor
        
        biometricColor()
        
        let saveData = UITapGestureRecognizer(target: self, action: #selector(self.saveData))
        saveView.addGestureRecognizer(saveData)
        saveView.isUserInteractionEnabled = true
        
        saveView.backgroundColor = UIColor(red:0.40, green:0.64, blue:1.00, alpha:1.0)
        saveView.clipsToBounds = true
        saveView.layer.cornerRadius = 10
        
        scrollView.contentSize.height = self.frame.height * 1.5
        
        let dismissViewGesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        backImage.addGestureRecognizer(dismissViewGesture)
        backImage.isUserInteractionEnabled = true
        
        setPanGesture()
    }
    
    func setPanGesture()
    {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left

        self.addGestureRecognizer(edgePan)
    }
    
    func biometricColor()
    {
        notificationSwitch.onTintColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
        if notificationSwitch.isOn
        {
            notificationSwitch.thumbTintColor = UIColor(red:0.40, green:0.64, blue:1.00, alpha:1.0)
        }
        else
        {
            notificationSwitch.thumbTintColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
        }
    }
    
    @objc func closeView()
    {
        delegate?.dismissProfileMenu()
    }
    @objc func saveData()
    {
        // TODO: OPERATIONS
        print("SAVED")
    }
    @IBAction func addProfilePhotoButton(_ sender: Any)
    {
        
    }
    @IBAction func notificationStateChange(_ sender: Any)
    {
        biometricColor()
    }
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer)
    {
        guard let view = recognizer.view else { return }
        let shift = recognizer.translation(in: view)
        
        if shift.x > 50
        {
            delegate?.dismissProfileMenu()
        }
    }
}

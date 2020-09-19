//
//  ProfileMenuDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 2.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

protocol ProfileMenuDelegate: class 
{
    func goProfileSettings()
    func verifyProfile()
    func showTermsofUse()
    func showLegalText()
    func showPinView()
}

protocol ProfileSettingsViewDelegate: class 
{
    func dismissProfileMenu()
}

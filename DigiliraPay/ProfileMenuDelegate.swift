//
//  ProfileMenuDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 2.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol ProfileMenuDelegate: class 
{
    func goProfileSettings()
    func verifyProfile()
    func showTermsofUse()
    func showLegalText()
    func showPinView()
    func showSeedView()
    func showBitexenView()
    func showCommissions()
}

protocol ProfileSettingsViewDelegate: class 
{
    func dismissProfileMenu()
}

protocol BitexenAPIDelegate: class
{
    func dismissBitexen()
}

//
//  VerifyAccountDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol VerifyAccountDelegate: class
{
    func dismissVErifyAccountView()
    func dismissKeyboard()
    func removeWarning()
    func disableEntry()
    func uploadImage()
    func uploadIdentity()
    func enableEntry(user:Constants.auth)
    func loadEssentials()
}

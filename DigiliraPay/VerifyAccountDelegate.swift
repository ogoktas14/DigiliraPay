//
//  VerifyAccountDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol VerifyAccountDelegate: class
{
    func dismissVErifyAccountView()
    func dismissKeyboard()
    func removeWarning()
    func disableEntry()
    func enableEntry(user:digilira.auth)
}

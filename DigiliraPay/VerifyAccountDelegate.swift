//
//  VerifyAccountDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

protocol VerifyAccountDelegate: class
{
    func dismissVErifyAccountView(user: digilira.user)
    func dismissKeyboard()
}

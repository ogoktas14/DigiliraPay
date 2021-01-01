//
//  MenuViewDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 30.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol MenuViewDelegate: class
{
    func goHomeScreen()
    func goWalletScreen(coin: String)
    func goSettingsScreen()
    func goQRScreen()
    func goPayments()
    func goSettings()
}

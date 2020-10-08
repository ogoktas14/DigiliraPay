//
//  MenuViewDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 30.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

protocol MenuViewDelegate: class
{
    func goHomeScreen()
    func goWalletScreen(coin:Int)
    func goSettingsScreen()
    func goQRScreen()
    func goPayments()
    func goSettings()
}

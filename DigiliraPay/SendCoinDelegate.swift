//
//  SendCoinDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 1.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol SendCoinDelegate: class
{
    func sendCoin(params:SendTrx)
    func getQR()
}

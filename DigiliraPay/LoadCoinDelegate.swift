//
//  LoadCoinDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation
import UIKit

protocol LoadCoinDelegate: class
{
    func dismissLoadView()
    func shareQR(image: UIImage?)
}


protocol NewCoinSendDelegate: class {
    func readAddressQR()
    func dismissNewSend()
    func sendCoinNew(params:SendTrx)
}

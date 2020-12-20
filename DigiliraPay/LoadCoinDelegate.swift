//
//  LoadCoinDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation
import UIKit

protocol LoadCoinDelegate: class
{
    func dismissLoadView()
    func shareQR(image: UIImage?)
}

protocol ErrorsDelegate: class {
    func errorHandler(message: String, title: String, error:Bool)
    func errorCaution(message: String, title: String)
    func transferConfirmation(txConMsg: digilira.txConfMsg, destination: NSNotification.Name)
    func evaluate(error: digilira.NAError)
    func removeAlert()
    func waitPlease()
    func removeWait()
    
}


protocol NewCoinSendDelegate: class {
    func readAddressQR()
    func dismissNewSend()
    func sendCoinNew(params:SendTrx)
}

protocol SelectCoinViewDelegate: class {
    func cancel()
    func dismissNewSend(params: digilira.order)
    func selectCoin(params: String)
}

protocol PageCardViewDeleGate: class {
    func cancel1(id: String)
    func dismissNewSend1(params: digilira.order)
    func selectCoin1(params: String)
}

//
//  LoadCoinDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.09.2019.
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
 
protocol PageCardViewDeleGate: class {
    func cancel1(id: String)
    func dismissNewSend1(params: PaymentModel)
    func selectCoin1(params: String)
}

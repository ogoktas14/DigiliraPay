//
//  SendWithQrDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

protocol SendWithQrDelegate: class
{
    func dismissSendWithQr()
    func sendQR(ORDER: digilira.order)
    func qrError(error: String)

}
 

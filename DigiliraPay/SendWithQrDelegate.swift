//
//  SendWithQrDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol SendWithQrDelegate: class
{
    func dismissSendWithQr(url: String)
    func sendWithQRError(error: Error)

}
 

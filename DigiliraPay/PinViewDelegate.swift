//
//  PinViewDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 27.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import Foundation

protocol PinViewDelegate: class {
    func closePinView()
    func updatePinCode(code:Int32)
    func pinSuccess(res:Bool)
}

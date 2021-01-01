//
//  PinViewDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 27.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol PinViewDelegate: class {
    func closePinView()
    func updatePinCode(code:Int32)
    func pinSuccess(res:Bool)
}


protocol seedViewDelegate: class {
    func closeSeedView()
}



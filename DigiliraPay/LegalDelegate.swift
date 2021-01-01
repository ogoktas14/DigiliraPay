//
//  LegalDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 4.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import Foundation

protocol LegalDelegate: class
{
    func showLegal(mode: digilira.terms)
    func dismissLegalView()
}


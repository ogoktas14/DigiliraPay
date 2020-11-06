//
//  NetworkClient.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 5.11.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation

struct Certificates {
  static let stackExchange =
    Certificates.certificate(filename: "digilirapay.com")
  
  private static func certificate(filename: String) -> SecCertificate {
    let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let certificate = SecCertificateCreateWithData(nil, data as CFData)!
    
    return certificate
  }
}

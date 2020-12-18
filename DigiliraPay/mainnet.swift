//
//  mainnet.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 15.12.2020.
//  Copyright © 2020 DigiliraPay. All rights reserved.
//

import Foundation


struct wavesMainnet {
    
    static var ethereumWaves = digilira.coin.init(
        token: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
        symbol: "ETH",
        tokenName: "Ethereum",
        decimal: 8,
        network: "ethereum",
        tokenSymbol: "WETH",
        gatewayFee: 0.01
    )
    static var bitcoinWaves = digilira.coin.init(
        token: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
        symbol: "BTC",
        tokenName: "Bitcoin",
        decimal: 8,
        network: "bitcoin",
        tokenSymbol: "WBTC",
        gatewayFee: 0.001
    )
    static var tetherWaves = digilira.coin.init(
        token: "34N9YcEETLWn93qYQ64EsP1x89tSruJU44RrEMSXXEPJ",
        symbol: "USDT",
        tokenName: "Tether USD",
        decimal: 6,
        network: "ethereum",
        tokenSymbol: "USDT",
        gatewayFee: 5
    )
    
    static var litecoinWaves = digilira.coin.init(
        token: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
        symbol: "LTC",
        tokenName: "Litecoin",
        decimal: 8,
        network: "litecoin",
        tokenSymbol: "WLTC",
        gatewayFee: 0.01
    )

    
}

//
//  CountryRule.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/23/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class CountryRule : Rule {
    let countryCode: String
    let match: Bool
    let adapterFactory: AdapterFactory
    
    init(countryCode: String, match: Bool, adapterFactory: AdapterFactory) {
        self.countryCode = countryCode
        self.match = match
        self.adapterFactory = adapterFactory
        super.init()
    }
    
    override func match(var request :ConnectMessage) -> AdapterFactory? {
        if (request.country != countryCode) != match {
            return adapterFactory
        }
        return nil
    }
}

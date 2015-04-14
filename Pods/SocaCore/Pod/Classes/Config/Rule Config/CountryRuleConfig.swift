//
//  CountryRuleConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(CountryRuleConfig)
class CountryRuleConfig: RuleConfig {

    @NSManaged var country: String
    @NSManaged var match: Bool

    override var type: String { return "Country" }
    
    override func rule() -> Rule {
        return CountryRule(countryCode: country, match: match, adapterFactory: adapter.adapterFactory())
    }
}

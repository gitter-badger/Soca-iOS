//
//  AllRuleConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(AllRuleConfig)
class AllRuleConfig: RuleConfig {

    override var type: String { return "All Match" }
    
    override func rule() -> Rule {
        return AllRule(adapterFactory: adapter.adapterFactory())
    }
}

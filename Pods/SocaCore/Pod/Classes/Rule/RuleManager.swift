
//
//  RuleSet.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class RuleManager {
    var rules: [Rule] = []
    
    init(fromRules rules: [Rule], appendDirect: Bool = false) {
        self.rules = rules
        
        if appendDirect || self.rules.count == 0 {
            self.rules.append(DirectRule())
        }
    }
    
    func match(request: ConnectMessage) -> AdapterFactory! {
        for rule in rules {
            if let adapterFactory = rule.match(request) {
                return adapterFactory
            }
        }
        return nil // this should never happens
    }
}
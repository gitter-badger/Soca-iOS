//
//  RuleConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(RuleConfig)
class RuleConfig: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var adapter: AdapterConfig
    @NSManaged var proxy: ProxyConfig
    
    var type: String { return "" }
    
    func rule() -> Rule {
        return Rule()
    }
}

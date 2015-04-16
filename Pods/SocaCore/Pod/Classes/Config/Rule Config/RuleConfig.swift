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
public class RuleConfig: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var adapter: AdapterConfig
    @NSManaged public var proxy: ProxyConfig
    
    public var type: String { return "" }
    
    func rule() -> Rule {
        return Rule()
    }
}

//
//  ProxyConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(ProxyConfig)
public class ProxyConfig: NSManagedObject {

    @NSManaged public var name: String?
    @NSManaged public var port: Int
    @NSManaged public var profile: ProfileConfig
    @NSManaged public var rules: NSOrderedSet

    public var type: String { return "" }
    
    class public func createWithDefaultRule(context: NSManagedObjectContext?) -> ProxyConfig {
        var proxyConfig: ProxyConfig!
        if let context = context {
            proxyConfig = MR_createInContext(context) as! ProxyConfig
        } else {
            proxyConfig = MR_createEntity() as! ProxyConfig
        }
        let defaultConfig = DirectAdapterConfig.MR_findFirstInContext(proxyConfig.managedObjectContext) as! AdapterConfig
        let defaultRule = AllRuleConfig.MR_createInContext(proxyConfig.managedObjectContext) as! RuleConfig
        defaultRule.adapter = defaultConfig
        defaultRule.name = "Default Direct Rule"
        proxyConfig.rules = NSOrderedSet(object: defaultRule)
        return proxyConfig
    }
    
    func proxyServer() -> ProxyServer! {
        return nil
    }
    
    func ruleManager() -> RuleManager {
        let ruleSet = (rules.array as! [RuleConfig]).map() {
            $0.rule()
        }
        return RuleManager(fromRules: ruleSet)
    }
}

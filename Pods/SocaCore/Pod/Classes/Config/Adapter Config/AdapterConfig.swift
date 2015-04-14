//
//  AdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/12/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(AdapterConfig)
public class AdapterConfig: NSManagedObject {

    @NSManaged public var name: String!
    @NSManaged public var rules: NSSet
    var type: String { return "" }
    
    func adapterFactory() -> AdapterFactory {
        return DirectAdapterFactory()
    }

    override public func prepareForDeletion() {
        // TODO: find all rules based on this adapter and change them to use DirectAadapter
        let directAdapter = DirectAdapterConfig.MR_findFirstInContext(self.managedObjectContext) as! AdapterConfig
        for rule in rules {
            (rule as! RuleConfig).adapter = directAdapter
        }
    }
}

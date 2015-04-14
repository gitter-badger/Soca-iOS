//
//  AdapterFactoryManager.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/19/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class AdapterFactoryManager {
    var factoryDict: [String:AdapterFactory]
    
    subscript(index: String) -> AdapterFactory? {
        get { return factoryDict[index] }
        set { factoryDict[index] = newValue }
    }
    
    init(factoryDict: [String:AdapterFactory]) {
        self.factoryDict = factoryDict
    }
}

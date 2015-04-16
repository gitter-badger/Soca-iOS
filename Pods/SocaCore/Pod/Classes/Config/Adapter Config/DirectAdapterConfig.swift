//
//  DirectConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/13/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(DirectAdapterConfig)
public class DirectAdapterConfig: AdapterConfig {
    override public var type: String { return "Direct" }

}

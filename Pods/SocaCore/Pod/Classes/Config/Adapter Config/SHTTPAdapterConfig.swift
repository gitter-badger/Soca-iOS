//
//  SHTTPAdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/12/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(SHTTPAdapterConfig)
public class SHTTPAdapterConfig: HTTPAdapterConfig {
    override public var type: String { return "Secured HTTP" }
    
    override func adapterFactory() -> AdapterFactory {
        return SecureHTTPAdapterFactory(host: server, port: UInt16(port), auth: authObject())
    }
}

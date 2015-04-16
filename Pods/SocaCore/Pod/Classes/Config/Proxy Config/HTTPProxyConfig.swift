//
//  HTTPProxyConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(HTTPProxyConfig)
public class HTTPProxyConfig: ProxyConfig {

    override public var type: String { return "HTTP Server" }
    
    override func proxyServer() -> ProxyServer {
        return HTTPProxyServer(listenPort: UInt16(port), ruleManager: ruleManager())
    }
}

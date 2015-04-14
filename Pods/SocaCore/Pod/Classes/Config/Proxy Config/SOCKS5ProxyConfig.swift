//
//  SOCKS5ProxyConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(SOCKS5ProxyConfig)
class SOCKS5ProxyConfig: ProxyConfig {

    override var type: String { return "SOCKS5 Server" }
    
    override func proxyServer() -> ProxyServer {
        return SOCKS5ProxyServer(listenPort: UInt16(port), ruleManager: ruleManager())
    }
}

//
//  SOCKS5AdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/12/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(SOCKS5AdapterConfig)
public class SOCKS5AdapterConfig: ServerAdapterConfig {
    override var type: String { return "SOCKS5" }
    
    override func adapterFactory() -> AdapterFactory {
        return SOCKS5AdapterFactory(host: server, port: UInt16(port))
    }
}

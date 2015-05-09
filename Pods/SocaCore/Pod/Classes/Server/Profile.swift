//
//  Profile.swift
//  soca
//
//  Created by Zhuhao Wang on 4/2/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

/**
 *  Profile holds the set of proxies with specific rules you would like to run simutaneouly.
*/
public class Profile {
    public let config: ProfileConfig
    public var running = false
    
    lazy var servers: [ProxyServer] = {
        [unowned self] in
        self.config.proxies.allObjects.map() {
            ($0 as! ProxyConfig).proxyServer()
        }
    }()
    
    init(profileConfig: ProfileConfig) {
        self.config = profileConfig
    }
    
    public func start() {
        for server in servers {
            server.startProxy()
        }
        running = true
    }
    
    public func stop() {
        for server in servers {
            server.disconnect()
        }
        running = false
    }
}
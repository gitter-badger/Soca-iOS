//
//  Profile.swift
//  soca
//
//  Created by Zhuhao Wang on 4/2/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class Profile {
    var config: ProfileConfig!
    var running = false
    lazy var servers: [ProxyServer] = {
        [unowned self] in
        self.config.proxies.allObjects.map() {
            ($0 as! ProxyConfig).proxyServer()
        }
    }()
    
    init(profileConfig: ProfileConfig) {
        self.config = profileConfig
    }
    
    func start() {
        for server in servers {
            server.startProxy()
        }
        running = true
    }
    
    func stop() {
        for server in servers {
            server.disconnect()
        }
        running = false
    }
}
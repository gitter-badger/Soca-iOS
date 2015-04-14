//
//  SecureHTTPAdapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SecureHTTPAdapter : HTTPAdapter {
    override func socketDidConnectToHost(host: String, onPort port: UInt16) {
        socket._socket.startTLS([kCFStreamSSLPeerName: self.serverHost])
//        socket.startTLS([NSObject: AnyObject]())
        super.socketDidConnectToHost(host, onPort: port)
    }
}
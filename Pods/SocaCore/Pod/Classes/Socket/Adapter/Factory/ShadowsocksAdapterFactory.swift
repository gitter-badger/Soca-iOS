//
//  ShadowsocksAdapterFactory.swift
//  soca
//
//  Created by Zhuhao Wang on 4/7/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class ShadowsocksAdapterFacotry: ServerAdapterFactory {
    let key: NSData
    let method: ShadowsocksAdapter.EncryptMethod
    let password: String
    
    init(host: String, port: UInt16, key: NSData, method: ShadowsocksAdapter.EncryptMethod, password: String) {
        self.key = key
        self.method = method
        self.password = password
        super.init(host: host, port: port)
    }
    
    override func canHandle(request: ConnectMessage) -> Bool {
        return true
    }
    
    override func getAdapter(request: ConnectMessage, delegateQueue: dispatch_queue_t) -> Adapter {
        return ShadowsocksAdapter(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort, key: key, encryptMethod: method, password: password)
    }
}
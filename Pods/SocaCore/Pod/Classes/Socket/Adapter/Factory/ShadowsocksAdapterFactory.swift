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
    
    init(host: String, port: Int, key: NSData, method: ShadowsocksAdapter.EncryptMethod) {
        self.key = key
        self.method = method
        super.init(host: host, port: port)
    }
    
    override func canHandle(request: ConnectRequest) -> Bool {
        return true
    }
    
    override func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        return ShadowsocksAdapter(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort, key: key, encryptMethod: method)
    }
}
//
//  AdapterServerFactory.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class ServerAdapterFactory : AdapterFactory {
    let serverHost: String
    let serverPort: Int
    
    init(host: String, port: Int) {
        serverHost = host
        serverPort = port
    }
    
    func canHandle(request: ConnectRequest) -> Bool {
        return false
    }
    
    func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        return DirectAdapter(request: request, delegateQueue: delegateQueue)
    }
}
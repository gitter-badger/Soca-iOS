//
//  SOCKS5Factory.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/19/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SOCKS5AdapterFactory : ServerAdapterFactory {
    override func canHandle(request: ConnectRequest) -> Bool {
        return true
    }
    
    override func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        return SOCKS5Adapter(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort)
    }
}
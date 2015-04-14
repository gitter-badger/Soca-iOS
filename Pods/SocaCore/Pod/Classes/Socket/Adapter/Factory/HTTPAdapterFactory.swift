//
//  HTTPAdapterFactory.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class HTTPAdapterFactory : AuthenticationAdapterFactory {

    override func canHandle(request: ConnectMessage) -> Bool {
        return true
    }
    
    override func getAdapter(request: ConnectMessage, delegateQueue: dispatch_queue_t) -> Adapter {
        return HTTPAdapter(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort, auth: self.auth)
    }
}
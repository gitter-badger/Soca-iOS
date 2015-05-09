//
//  SecureHTTPAdapterFactory.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SecureHTTPAdapterFactory : HTTPAdapterFactory {
    override func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        return SecureHTTPAdapter(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort, auth: self.auth)
    }
}
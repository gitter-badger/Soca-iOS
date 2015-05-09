//
//  DirectProxyConfig.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class DirectAdapterFactory : AdapterFactory {
    func canHandle(request: ConnectRequest) -> Bool {
        return true
    }
    
    func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        return DirectAdapter(request: request, delegateQueue: delegateQueue)
    }
}
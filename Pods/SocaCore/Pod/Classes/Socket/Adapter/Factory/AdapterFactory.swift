//
//  ProxyConfig.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

protocol AdapterFactory: class {
    func canHandle(request: ConnectMessage) -> Bool
    func getAdapter(request: ConnectMessage, delegateQueue: dispatch_queue_t) -> Adapter
}
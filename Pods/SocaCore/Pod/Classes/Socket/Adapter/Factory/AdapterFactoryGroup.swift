//
//  AdapterFactoryManager.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class AdapterFactoryGroup : AdapterFactory {
    let factories: [AdapterFactory]
    
    init(factories: [AdapterFactory] = []) {
        self.factories = factories
    }
    
    func canHandle(request: ConnectRequest) -> Bool {
        for factory in factories {
            if factory.canHandle(request) {
                return true
            }
        }
        return false
    }
    
    func getAdapter(request: ConnectRequest, delegateQueue: dispatch_queue_t) -> Adapter {
        for factory in factories {
            if factory.canHandle(request) {
                return factory.getAdapter(request, delegateQueue: delegateQueue)
            }
        }
        return factories[0].getAdapter(request, delegateQueue: delegateQueue) // never run
    }
}
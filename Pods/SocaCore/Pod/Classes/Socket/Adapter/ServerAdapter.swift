//
//  ServerAdapter.swift
//  Pods
//
//  Created by Zhuhao Wang on 5/8/15.
//
//

import Foundation

class ServerAdapter : Adapter {
    let serverHost: String
    let serverPort: Int
    
    init(request: ConnectRequest, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: Int){
        self.serverHost = serverHost
        self.serverPort = serverPort
        
        super.init(request:request, delegateQueue: delegateQueue)
    }
}
//
//  DirectSocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class DirectAdapter : Adapter {
    override func connectToRemote() {
        if self.connectRequest.IP != "" {
            self.socket.connectTo(self.connectRequest.IP, port: self.connectRequest.port)
        } else {
            Setup.getLogger().error("DNS look up failed for direct connect to \(self.connectRequest.destinationHost), disconnect now")
            self.connectDidFail()
        }
        
    }
    
    override func socketDidConnectToHost(host: String, onPort: UInt16) {
        self.ready()
    }
}
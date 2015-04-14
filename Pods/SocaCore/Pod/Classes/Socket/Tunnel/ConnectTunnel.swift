//
//  DirectTunnel.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class ConnectTunnel : Tunnel {
    override func proxySocketBecameReady() {
        receiveData(tag: .DATA)
        readData(tag: .DATA)
    }
    
    override func didReadData(data: NSData, withTag tag: TunnelReadTag) {
        switch tag {
        case .DATA:
            sendData(data, withTag: .DATA)
            readData(tag: .DATA)
        default:
            DDLogError("Tunnel read some data with unknown data tag \(tag), should be DATA, disconnect now")
            self.connectDidFail()
        }
    }

    override func didReceiveData(data: NSData, withTag tag: TunnelReceiveTag) {
        switch tag {
        case .DATA:
            writeData(data, withTag: .DATA)
            receiveData(tag: .DATA)
        default:
            DDLogError("Tunnel received some data with unknown data tag \(tag), should be DATA, disconnect now")
            self.connectDidFail()
        }
    }
}
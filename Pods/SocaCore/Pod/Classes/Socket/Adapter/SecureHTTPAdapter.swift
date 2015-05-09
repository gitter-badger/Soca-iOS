//
//  SecureHTTPAdapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SecureHTTPAdapter : HTTPAdapter {
    override func connectionEstablished() {
        socket.startTLS([kCFStreamSSLPeerName: serverHost])
        super.connectionEstablished()
    }
}
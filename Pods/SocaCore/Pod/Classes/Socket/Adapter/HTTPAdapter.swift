//
//  HTTPAdapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class HTTPAdapter : Adapter {
    let serverHost: String
    let serverPort: UInt16
    var auth: Authentication?
    
    enum ReadTag: Int {
        case CONNECT_RESPONSE = 30000
    }
    enum WriteTag: Int {
        case CONNECT = 40000, HEADER
    }
    
    init(request: ConnectMessage, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: UInt16){
        self.serverHost = serverHost
        self.serverPort = serverPort
        
        super.init(request: request, delegateQueue: delegateQueue)
    }
    
    convenience init(request: ConnectMessage, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: UInt16, auth: Authentication?) {
        self.init(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort)
        
        self.auth = auth
    }
    
    override func connectToRemote() {
        self.socket.connectTo(self.serverHost, port: self.serverPort)
    }
    
    override func socketDidConnectToHost(host: String, onPort: UInt16) {
        switch self.connectRequest.method {
        case .HTTP_CONNECT, .SOCKS5:
            var message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, "CONNECT", NSURL(string: "\(self.connectRequest.destinationHost):\(self.connectRequest.port)"), kCFHTTPVersion1_1).takeRetainedValue()
            if let authData = self.auth {
                CFHTTPMessageSetHeaderFieldValue(message, "Proxy-Authorization", authData.authString())
            }
            CFHTTPMessageSetHeaderFieldValue(message, "Host", "\(self.connectRequest.destinationHost):\(self.connectRequest.port)")
            CFHTTPMessageSetHeaderFieldValue(message, "Content-Length", "0")
            var requestData = CFHTTPMessageCopySerializedMessage(message).takeRetainedValue()
            self.writeData(requestData, withTag: WriteTag.CONNECT.rawValue)
            self.readDataToData(Utils.HTTPData.DoubleCRLF, withTag: ReadTag.CONNECT_RESPONSE.rawValue)
        case .HTTP_DIRECT:
            var response = self.connectRequest
            if let authData = self.auth {
                response.addHeader = [("Proxy-Authorization", authData.authString())]
            }
            response.removeHTTPProxyHeader = false
            response.rewritePath = false
            self.connectResponse = response
            self.ready(response: response)
        }
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        if let readTag = ReadTag(rawValue: tag) {
            switch readTag {
            case .CONNECT_RESPONSE:
                var response = self.connectRequest
                self.ready(response: response)
            }
        }
    }

    override func didWriteData(data: NSData, withTag tag: Int) {}

}
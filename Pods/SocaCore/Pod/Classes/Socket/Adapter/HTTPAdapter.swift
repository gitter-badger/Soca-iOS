//
//  HTTPAdapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class HTTPAdapter : ServerAdapter {
    var auth: Authentication?
    
    convenience init(request: ConnectRequest, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: Int, auth: Authentication?) {
        self.init(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort)
        
        self.auth = auth
    }
    
    override func connectToRemote() {
        socket.connectToHost(serverHost, withPort: serverPort)
    }
    
    override func connectionEstablished() {
        connectResponse = connectRequest.getResponse()
        if connectRequest.method == .HTTP_REQUEST {
            if let auth = auth {
                connectResponse!.headerToAdd = [("Proxy-Authorization", auth.authString())]
            }
            connectResponse?.rewritePath = false
            connectResponse?.removeHTTPProxyHeader = false
        } else {
            var message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, "CONNECT", NSURL(string: "\(connectRequest.host):\(connectRequest.port)"), kCFHTTPVersion1_1).takeRetainedValue()
            if let auth = auth {
                CFHTTPMessageSetHeaderFieldValue(message, "Proxy-Authorization", auth.authString())
            }
            CFHTTPMessageSetHeaderFieldValue(message, "Host", "\(connectRequest.host):\(connectRequest.port)")
            CFHTTPMessageSetHeaderFieldValue(message, "Content-Length", "0")
            var requestData = CFHTTPMessageCopySerializedMessage(message).takeRetainedValue()
            writeData(requestData, withTag: SocketTag.HTTP.Header)
            readDataToData(Utils.HTTPData.DoubleCRLF, withTag: SocketTag.HTTP.ConnectResponse)
        }
        sendResponse(response: connectResponse)
    }
    
    override func proxySocketReadyForward() {
        if connectRequest.method == .HTTP_REQUEST {
            readDataForForward()
        }
    }
    
    override func updateRequest(request: ConnectRequest) -> ConnectResponse? {
        connectRequest = request
        return getResponseForHTTPRequest()
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        switch tag {
        case SocketTag.HTTP.ConnectResponse:
            readDataForForward()
        case SocketTag.Forward:
            sendData(data)
            readDataForForward()
        default:
            break
        }
    }
    
    override func didReceiveDataFromLocal(data: NSData) {
        writeData(data, withTag: SocketTag.Forward)
    }
    
    func getResponseForHTTPRequest() -> ConnectResponse {
        let response = connectRequest.getResponse()
        if let auth = auth {
            response.headerToAdd = [("Proxy-Authorization", auth.authString())]
        }
        response.rewritePath = false
        response.removeHTTPProxyHeader = false
        return response
    }
}
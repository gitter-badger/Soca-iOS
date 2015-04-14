//
//  HTTPProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class HTTPProxySocket : ProxySocket {
    enum HTTPMethod : String {
        case GET = "GET", HEAD = "HEAD", POST = "POST", PUT = "PUT", DELETE = "DELETE", TRACE = "TRACE", OPTIONS = "OPTIONS", CONNECT = "CONNECT", PATCH = "PATCH"
    }
    
    override func openSocket() {
        self.readDataToData(Utils.HTTPData.DoubleCRLF, withTag: .HTTP_HEADER)
    }
    
    override func connect() {
        if self.tunnel == nil {
            // if this is a new socket without an adapter
            let adapterFactory = proxy.matchRule(self.connectRequest)
            switch self.connectRequest.method {
            case .HTTP_CONNECT:
                self.tunnel = ConnectTunnel(fromSocket: self, connectTo: self.connectRequest, withAdapterFactory: adapterFactory)
            case .HTTP_DIRECT:
                self.tunnel = HTTPTunnel(fromSocket: self, connectTo: self.connectRequest, withAdapterFactory: adapterFactory)
            default:
                break
            }
            self.tunnel?.connect()
        } else {
            self.tunnel?.updateRequest(self.connectRequest)
            self.adapterBecameReady()
        }
    }
    
    override func didReadData(data: NSData, withTag tag: ProxySocketReadTag) {
        switch tag {
        case .HTTP_HEADER:
            let message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, 1).takeRetainedValue()
            CFHTTPMessageAppendBytes(message, UnsafePointer<UInt8>(data.bytes), data.length)
            let method: String = CFHTTPMessageCopyRequestMethod(message).takeRetainedValue() as String
            switch HTTPMethod(rawValue: method.uppercaseString)! {
            case .CONNECT:
                let _url = CFURLGetString(CFHTTPMessageCopyRequestURL(message).takeRetainedValue()) as String
                let hostPort = _url.componentsSeparatedByString(":")
                let _host = hostPort[0]
                let _port = hostPort[1].toInt()!
                DDLogInfo("Recieved HTTP CONNECT request to \(_host):\(_port)")
                var request = ConnectMessage(host: _host, port: _port, method: .HTTP_CONNECT)
                request.httpProxyRawHeader = data
                self.connectRequest = request
                self.connect()
            default:
                let _url = CFHTTPMessageCopyHeaderFieldValue(message, "Host").takeRetainedValue() as String
                let hostPort = _url.componentsSeparatedByString(":")
                var _host: String, _port: Int
                if hostPort.count > 1 {
                    _host = hostPort[0]
                    _port = hostPort[1].toInt()!
                } else {
                    _host = hostPort[0]
                    _port = 80
                }
                DDLogInfo("Recieved HTTP request to \(_host):\(_port)")
                DDLogDebug("Revieved request header: \n\(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                var request = ConnectMessage(host: _host, port: _port, method: .HTTP_DIRECT)
                request.httpProxyRawHeader = data
                self.connectRequest = request
                self.connect()
            }
        default:
            break
        }
    }
    
    override func adapterBecameReady(_ response: ConnectMessage? = nil) {
        switch self.connectRequest!.method {
        case .HTTP_CONNECT:
            self.writeData(Utils.HTTPData.ConnectSuccessResponse, withTag: .HTTP_CONNECT_RESPONSE)
            self.ready()
        case .HTTP_DIRECT:
            self.ready()
            self.tunnel?.sendHTTPHeader(connectRequest.httpProxyRawHeader!)
        default:
            break
        }
    }
}
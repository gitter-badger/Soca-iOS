//
//  ProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class ProxySocket : SocketDelegate {
    enum ProxySocketReadTag: Int {
        case SOCKS_OPEN = 1000, SOCKS_CONNECT_INIT, SOCKS_CONNECT_IPv4, SOCKS_CONNECT_IPv6, SOCKS_CONNECT_DOMAIN_LENGTH, SOCKS_CONNECT_DOMAIN, SOCKS_CONNECT_PORT, HTTP_HEADER, HTTP_CONTENT
    }
    
    enum ProxySocketWriteTag: Int {
        case HTTP_CONNECT_RESPONSE = 2000, SOCKS_METHOD_RESPONSE, SOCKS_CONNECT_REPONSE
    }
    
    var destinationHost: String!
    var destinationPort: UInt16!
    var connectRequest: ConnectMessage!
    var tunnel: Tunnel?
    let socket: Socket
    var forwarding = false
    unowned let proxy: ProxyServer
    
    var _removed = false
    var _onceToken: dispatch_once_t = 0

    
    init(socket: GCDAsyncSocket, proxy: ProxyServer) {
        self.proxy = proxy
        self.socket = Socket(socket: socket)
        self.socket.socketDelegate = self
    }
    
    func openSocket() {} // called to open the socket to recieve data
    func adapterBecameReady(withResponse: ConnectMessage?) {}
    
    func connect() {} // called to connect to remote server for data
    
    func connectDidFail() {
        dispatch_once(&_onceToken) {
            if !self._removed {
                self.socket._socket.disconnect()
                self.tunnel?.adapter.socket._socket.disconnect()
                self.proxy.socketDidDisconnect(self)
                self._removed = true
            }
        }
    }
    
    func ready() {
        self.forwarding = true
        self.tunnel?.proxySocketBecameReady()
    }
    
    func getDelegateQueue() -> dispatch_queue_t {
        return socket._socket.delegateQueue
    }
    
    func didReadData(data: NSData, withTag tag: ProxySocketReadTag) {}
    func didWriteData(data: NSData, withTag tag: ProxySocketWriteTag) {}
    
    // MARK: helper methods
    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: ProxySocketWriteTag) {
        self.socket.writeData(data, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func writeData(data: NSData, withTag tag: ProxySocketWriteTag) {
        self.writeData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: ProxySocketReadTag) {
        self.socket.readDataToLength(length, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func readDataToLength(length: Int, withTag tag: ProxySocketReadTag) {
        self.readDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    func readData(#tag: ProxySocketReadTag) {
        self.socket.readData(tag: tag.rawValue)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: ProxySocketReadTag) {
        self.socket.readDataToData(data, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func readDataToData(data: NSData, withTag tag: ProxySocketReadTag){
        self.readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    // MARK: delegation methods
    func socketDidDisconnect(socket: Socket, withError err: NSError?) {
        self.connectDidFail()
    }
    
    func socketDidConnectToHost(host: String, onPort: UInt16) {}
    
    func socketDidReadData(data: NSData, withTag tag: Int) {
        if forwarding {
            // call delegate function on tunnel
            if let _tag = Tunnel.TunnelReadTag(rawValue: tag) {
                self.tunnel?.didReadData(data, withTag: _tag)
            } else {
                DDLogError("ProxySocket read some data with unknown data tag \(tag), should be some one in Tunnel.TunnelReadTag, disconnect now")
                self.connectDidFail()
            }
        } else {
            if let _tag = ProxySocketReadTag(rawValue: tag) {
                self.didReadData(data, withTag: _tag)
            } else {
                DDLogError("ProxySocket recieved some data with unknown data tag \(tag), should be some one in ProxySocket.ProxySocketReadTag, disconnect now")
                self.connectDidFail()
            }
        }
    }
    
    func socketDidWriteData(data: NSData, withTag tag: Int) {
        if forwarding {
            if let _tag = Tunnel.TunnelWriteTag(rawValue: tag) {
                self.tunnel?.didWriteData(data, withTag: _tag)
            } else {
                DDLogError("ProxySocket write some data with unknown data tag \(tag), should be some one in Tunnel.TunnelWriteTag, disconnect now")
                self.connectDidFail()
            }
        } else  {
            if let _tag = ProxySocketWriteTag(rawValue: tag) {
                self.didWriteData(data, withTag: _tag)
            } else {
                DDLogError("ProxySocket sent some data with unknown data tag \(tag), should be some one in ProxySocket.ProxySocketWriteTag, disconnect now")
                self.connectDidFail()
            }
        }
    }
}
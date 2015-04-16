//
//  ProxyServer.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/16/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class ProxyServer : NSObject {
    let listeningPort: UInt16
    let ruleManager: RuleManager
    var activeSockets: [ProxySocket]!
    var listeningSocket: GCDAsyncSocket!
    let listeningQueue: dispatch_queue_t = dispatch_queue_create("com.Soca.ProxyServer.listenQueue", DISPATCH_QUEUE_SERIAL)
    
    required init(listenPort port: UInt16, ruleManager: RuleManager) {
        self.listeningPort = port
        self.ruleManager = ruleManager
        
        super.init()
    }
    
    func startProxy() {
        self.disconnect()
        self.listeningSocket = GCDAsyncSocket(delegate: self, delegateQueue: self.listeningQueue)
        self.activeSockets = [ProxySocket]()
        
        var error: NSError?
        self.listeningSocket.acceptOnPort(self.listeningPort, error: &error)
        if let userInfo = error?.userInfo {
            DDLogError("Error listening on port \(self.listeningPort): \(userInfo)")
        }
        Setup.getLogger().info("Listening on port \(self.listeningPort)")
    }
    
    func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {}
    
    func disconnect() {
        self.activeSockets = nil
        self.listeningSocket?.disconnect()
        self.listeningSocket?.delegate = nil
        self.listeningSocket = nil
    }
    
    func socketDidDisconnect(socket: ProxySocket) {
        dispatch_async(self.listeningQueue) {
            let index = (self.activeSockets as NSArray).indexOfObject(socket)
            self.activeSockets.removeAtIndex(index)
            Setup.getLogger().verbose("Removed a closed proxy socket, current sockets: \(self.activeSockets.count)")
        }
    }
    
    func matchRule(request: ConnectMessage) -> AdapterFactory {
        return ruleManager.match(request)
    }
}

class SOCKS5ProxyServer : ProxyServer {
    override func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        Setup.getLogger().verbose("SOCKS5 proxy server accepted new socket")
        let proxySocket = SOCKS5ProxySocket(socket: newSocket, proxy:self)
        self.activeSockets.append(proxySocket)
    }
}

class HTTPProxyServer : ProxyServer {
    override func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        Setup.getLogger().verbose("HTTP proxy server accepted new socket")
        let proxySocket = HTTPProxySocket(socket: newSocket, proxy: self)
        self.activeSockets.append(proxySocket)
        proxySocket.openSocket()
    }
}
//
//  ProxyServer.swift
//  SocaCore
//
//  Created by Zhuhao Wang on 2/16/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

/**
 * ProxyServer is the base proxy server that accepts requests from your device and forwards the requests to remote proxies or remote servers directly based on rules represented by RuleManager.
*/
class ProxyServer : NSObject {
    let listeningPort: Int
    let ruleManager: RuleManager
    var activeSockets = [ProxySocket]()
    var listeningSocket: GCDAsyncSocket!
    let listeningQueue: dispatch_queue_t = dispatch_queue_create("com.Soca.ProxyServer.listenQueue", DISPATCH_QUEUE_SERIAL)
    let socketModifyQueue: dispatch_queue_t = dispatch_queue_create("com.Soca.ProxyServer.socketModifyQueue", DISPATCH_QUEUE_SERIAL)

    required init(listenOnPort port: Int, withRuleManager ruleManager: RuleManager) {
        self.listeningPort = port
        self.ruleManager = ruleManager
    
        super.init()
    }
    
    func startProxy() -> NSError? {
        disconnect()
        listeningSocket = GCDAsyncSocket(delegate: self, delegateQueue: self.listeningQueue)
        var error: NSError?
        listeningSocket.acceptOnPort(UInt16(self.listeningPort), error: &error)
        return error
    }
    
    func didAcceptNewSocket(newSocket: GCDAsyncSocket, withSocket socket: GCDAsyncSocket) {}
    
    func disconnect() {
        listeningSocket?.disconnect()
        listeningSocket?.delegate = nil
        listeningSocket = nil
        
        // make sure the socket finish disconnecting
        NSThread.sleepForTimeInterval(0.01)
        
        dispatch_sync(listeningQueue) {
            [unowned self] in
            for socket in self.activeSockets {
                socket.disconnect()
            }
        }
    }
    
    func addSocket(socket: ProxySocket) {
        dispatch_async(socketModifyQueue) {
            [unowned self] in
            self.activeSockets.append(socket)
        }
    }
    
    func removeSocket(socket: ProxySocket) {
        dispatch_async(socketModifyQueue) {
            [unowned self] in
            let index = (self.activeSockets as NSArray).indexOfObject(socket)
            if index != NSNotFound {
                self.activeSockets.removeAtIndex(index)
            }
        }
    }
    
    func matchRule(request: ConnectMessage) -> AdapterFactory {
        return ruleManager.match(request)
    }
    
    // MARK: Delegation for GCDAsyncSocket
    
    func socketDidDisconnect(socket: ProxySocket) {
        removeSocket(socket)
    }
    
    func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        didAcceptNewSocket(newSocket, withSocket: sock)
    }
}

/**
 *  The SOCKS5 proxy server.
*/
class SOCKS5ProxyServer : ProxyServer {
    override func didAcceptNewSocket(newSocket: GCDAsyncSocket, withSocket socket: GCDAsyncSocket) {
        let proxySocket = SOCKS5ProxySocket(socket: newSocket, proxy:self)
        addSocket(proxySocket)
        proxySocket.openSocket()
    }
}

/**
 *  The HTTP proxy server.
*/
class HTTPProxyServer : ProxyServer {
    override func didAcceptNewSocket(newSocket: GCDAsyncSocket, withSocket socket: GCDAsyncSocket) {
        let proxySocket = HTTPProxySocket(socket: newSocket, proxy: self)
        addSocket(proxySocket)
        proxySocket.openSocket()
    }
}
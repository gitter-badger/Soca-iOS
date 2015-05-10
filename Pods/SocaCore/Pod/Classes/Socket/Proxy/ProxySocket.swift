//
//  ProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class ProxySocket : SocketDelegate {
    enum ProxySocketReadTag: Int {
        case SOCKS_OPEN = 1000, SOCKS_CONNECT_INIT, SOCKS_CONNECT_IPv4, SOCKS_CONNECT_IPv6, SOCKS_CONNECT_DOMAIN_LENGTH, SOCKS_CONNECT_DOMAIN, SOCKS_CONNECT_PORT, HTTP_HEADER, HTTP_CONTENT
    }
    
    enum ProxySocketWriteTag: Int {
        case HTTP_CONNECT_RESPONSE = 2000, SOCKS_METHOD_RESPONSE, SOCKS_CONNECT_REPONSE
    }
    
    var destinationHost: String!
    var destinationPort: Int!
    var connectRequest: ConnectRequest!
    var tunnel: Tunnel?
    let socket: Socket
    
    /**
    Return false when and only when socket and tunnel?.adapter.socket are both disconnected.
    */
    var connected: Bool {
        if (socket.connected || tunnel?.adapter.connected ?? false) {
            return true
        }
        return false
    }

    // Ideally, proxy should be unowned instead of weak.
    // However, the proxy may be already released when the socket is retained by GCD blocks.
    weak var proxy: ProxyServer!
    
    private var removeToken: dispatch_once_t = 0

    init(socket: Socket, proxy: ProxyServer) {
        self.proxy = proxy
        self.socket = socket
        self.socket.socketDelegate = self
    }
    
    convenience init(socket: GCDAsyncSocket, proxy: ProxyServer) {
        let socket = Socket(socket: socket)
        self.init(socket: socket, proxy: proxy)
    }
    
    // MARK: method to implement in subclass for specific type of proxy.
    
    /**
    Override this to begin receive data from local socket.
    */
    func openSocket() {}
    
    /**
    Override this to define how to connect to remote server or proxy server.
    All information is in self.connectRequest.
    */
    func connectToRemote() {}
    
    func recievedResponse(response: ConnectResponse? = nil) {}
    
    func didReadData(data: NSData, withTag tag: Int) {}
    
    func didWriteDataWithTag(tag: Int) {}

    func didRecieveRequest() {}
    
    func didRecieveDataFromRemote(data: NSData) {
        writeData(data, withTag: SocketTag.Forward)
    }
    
    // MARK: control methods
    func disconnect() {
        socket.disconnect()
        tunnel?.adapter.disconnect()
    }
    
    func readyForForward() {
        tunnel?.proxySocketBecameReady()
    }
    
    func getDelegateQueue() -> dispatch_queue_t {
        return socket.delegateQueue
    }
    
    func connectionDidFail() {
        dispatch_once(&removeToken) {
            self.proxy?.socketDidDisconnect(self)
        }
    }
    
    /**
    Call this when self.connectRequest is ready and adapter should start to connect to remote
    */
    func readyToConnectToRemote() {
        connectToRemote()
    }
    
    // MARK: helper methods
    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.writeData(data, withTimeout: timeout, withTag: tag)
    }
    
    func writeData(data: NSData, withTag tag: Int) {
        writeData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: Int) {
        socket.readDataToLength(length, withTimeout: timeout, withTag: tag)
    }
    
    func readDataToLength(length: Int, withTag tag: Int) {
        readDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    func readData(#tag: Int) {
        socket.readData(tag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.readDataToData(data, withTimeout: timeout, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTag tag: Int){
        readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func sendToRemote(#data: NSData) {
        tunnel!.sendToRemote(data)
    }
    
    func readDataForForward() {
        readData(tag: SocketTag.Forward)
    }
    
    // MARK: delegation methods for SocketDelegate
    func socketDidDisconnect(socket: Socket, withError err: NSError?) {
        connectionDidFail()
    }
    
    func socketDidConnectToHost(host: String, onPort: Int) {}
    
    func socketDidReadData(data: NSData, withTag tag: Int) {
        didReadData(data, withTag: tag)
    }
    
    func socketDidWriteDataWithTag(tag: Int) {
        didWriteDataWithTag(tag)
    }
}
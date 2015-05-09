//
//  Adapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class Adapter : SocketDelegate {
    var connectRequest: ConnectRequest
    var connectResponse: ConnectResponse?
    weak var tunnel: Tunnel?

    let socket: Socket

    var connected: Bool {
        return socket.connected
    }
    
    init(request: ConnectRequest, delegateQueue: dispatch_queue_t) {
        let gcdsocket = GCDAsyncSocket()
        socket = Socket(socket: gcdsocket, delegateQueue: delegateQueue)
        connectRequest = request
        socket.socketDelegate = self
    }

    func connect() {
        if !connected {
            connectToRemote()
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendResponse(response: ConnectResponse? = nil) {
        tunnel?.sendResponse(response: response)
    }
    
    // MARK: method to implement in subclass
    func connectToRemote() {}
    func didReadData(data: NSData, withTag tag: Int) {}
    func didWriteDataWithTag(tag: Int) {}
    func didReceiveDataFromLocal(data: NSData) {}
    func proxySocketReadyForward() {}
    
    func connectionDidFail() {
        tunnel?.adapterConnectionDidFail()
    }
    
    func connectionEstablished() {}

    func updateRequest(request: ConnectRequest) -> ConnectResponse? {
        connectRequest = request
        return nil
    }
    
    // MARK: helper methods
    func writeData(data: NSData, withTag tag: Int) {
        writeData(data, withTimeout: -1, withTag: tag)
    }
    
    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.writeData(data, withTimeout: timeout, withTag: tag)
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
    
    func readDataToData(data: NSData, withTag tag: Int){
        readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.readDataToData(data, withTimeout: timeout, withTag: tag)
    }
    
    /**
    Send data to tunnel.
    */
    func sendData(data: NSData) {
        tunnel?.sendToLocal(data)
    }
    
    func readDataForForward() {
        readData(tag: SocketTag.Forward)
    }
    
    // MARK: delegation methods for Socket
    func socketDidDisconnect(socket: Socket, withError err: NSError?) {
        connectionDidFail()
    }
    
    func socketDidConnectToHost(host: String, onPort: Int) {
        connectionEstablished()
    }
    
    func socketDidReadData(data: NSData, withTag tag: Int) {
        didReadData(data, withTag: tag)
    }
    
    func socketDidWriteDataWithTag(tag: Int) {
        didWriteDataWithTag(tag)
    }
}
//
//  BaseSocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

protocol SocketDelegate : class {
    /**
    This will be called when socket disconnects. It will be called only when the socket disconnects not when disconnect() is called.
    
    :param: socket    The disconnected socket.
    :param: withError Error information.
    */
    func socketDidDisconnect(socket: Socket, withError: NSError?)
    func socketDidReadData(data: NSData, withTag: Int)
    func socketDidWriteDataWithTag(tag: Int)
    func socketDidConnectToHost(host: String, onPort: Int)
}

/**
 *  This is the swift wrapper around GCDAsyncSocket.
*/
class Socket : NSObject, GCDAsyncSocketDelegate {
    private let socket: GCDAsyncSocket
    let delegateQueue: dispatch_queue_t
    var forwarding = false
    weak var socketDelegate: SocketDelegate?
    var connected: Bool {
        return !socket.isDisconnected
    }

    init(socket: GCDAsyncSocket, delegateQueue: dispatch_queue_t? = nil) {
        self.socket = socket
        self.delegateQueue = delegateQueue ?? dispatch_queue_create("com.Soca.ProxyServer.SocketQueue", DISPATCH_QUEUE_SERIAL)
        
        super.init()
        
        self.socket.setDelegate(self, delegateQueue: self.delegateQueue)
    }

    // MARK: helper methods
    func writeData(data: NSData, withTag tag: Int) {
        writeData(data, withTimeout: -1, withTag: tag)
    }

    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.writeData(data, withTimeout: timeout, tag: tag)
    }

    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: Int) {
        socket.readDataToLength(UInt(length), withTimeout: timeout, tag: tag)
    }
    
    func readDataToLength(length: Int, withTag tag: Int) {
        readDataToLength(length, withTimeout: -1, withTag: tag)
    }

    func readData(#tag: Int) {
        socket.readDataWithTimeout(-1, tag: tag)
    }
    
    func readDataToData(data: NSData, withTag tag: Int){
        readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        socket.readDataToData(data, withTimeout: timeout, tag: tag)
    }
    
    func connectToHost(host: String, withPort port: Int) {
        socket.connectToHost(host, onPort: UInt16(port), error: nil)
    }
    
    func startTLS(tlsSettings: [NSObject : AnyObject]!) {
        socket.startTLS(tlsSettings)
    }
    
    func disconnect() {
        socket.disconnect()
    }

    // MARK: delegate methods
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        socketDelegate?.socketDidWriteDataWithTag(tag)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        socketDelegate?.socketDidReadData(data, withTag: tag)
    }

    func socketDidDisconnect(socket: GCDAsyncSocket!, withError err: NSError?) {
        socketDelegate?.socketDidDisconnect(self, withError: err)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        socketDelegate?.socketDidConnectToHost(host, onPort: Int(port))
    }

}
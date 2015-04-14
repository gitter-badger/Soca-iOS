//
//  BaseSocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

protocol SocketDelegate {
    func socketDidDisconnect(socket: Socket, withError: NSError?)
    func socketDidReadData(data: NSData, withTag: Int)
    func socketDidWriteData(data: NSData, withTag: Int)
    func socketDidConnectToHost(host: String, onPort: UInt16)
}

class Socket : NSObject, GCDAsyncSocketDelegate {
    let _socket: GCDAsyncSocket
    let delegateQueue: dispatch_queue_t
    var forwarding = false
    var socketDelegate: SocketDelegate?
//    var auxiliaries = [String:Any]()

    init(socket: GCDAsyncSocket, delegateQueue: dispatch_queue_t? = nil) {
        self._socket = socket
        if delegateQueue != nil {
            self.delegateQueue = delegateQueue!
        } else {
            self.delegateQueue = dispatch_queue_create("com.Soca.ProxyServer.SocketQueue", DISPATCH_QUEUE_SERIAL)
        }
        
        super.init()
        
        self._socket.setDelegate(self, delegateQueue: self.delegateQueue)
    }
    
    func isDisconnected() -> Bool {
        return _socket.isDisconnected
    }

    // MARK: helper methods
    func writeData(data: NSData, withTag tag: Int) {
        self.writeData(data, withTimeout: -1, withTag: tag)
    }

    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        self._socket.writeData(data, withTimeout: timeout, tag: tag)
    }

    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: Int) {
        self._socket.readDataToLength(UInt(length), withTimeout: timeout, tag: tag)
    }
    
    func readDataToLength(length: Int, withTag tag: Int) {
        self.readDataToLength(length, withTimeout: -1, withTag: tag)
    }

    func readData(#tag: Int) {
        self._socket.readDataWithTimeout(-1, tag: tag)
    }
    
    func readDataToData(data: NSData, withTag tag: Int){
        self.readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        self._socket.readDataToData(data, withTimeout: timeout, tag: tag)
    }
    
    func connectTo(host: String, port: UInt16) {
        self._socket.connectToHost(host, onPort: port, error: nil)
    }

    // MARK: delegate methods
    func socket(sock: GCDAsyncSocket, didWriteData data: NSData, withTag tag: Int) {
        self.socketDelegate?.socketDidWriteData(data, withTag: tag)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        self.socketDelegate?.socketDidReadData(data, withTag: tag)
    }

    func socketDidDisconnect(socket: GCDAsyncSocket!, withError err: NSError?) {
        self.socketDelegate?.socketDidDisconnect(self, withError: err)
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.socketDelegate?.socketDidConnectToHost(host, onPort: port)
    }

}
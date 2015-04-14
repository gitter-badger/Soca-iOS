//
//  Adapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class Adapter : SocketDelegate {
    var connectRequest: ConnectMessage
    var connectResponse: ConnectMessage?
    weak var tunnel: Tunnel?
    var forwardingWrite = false
    var forwardingRead = false
    let socket: Socket
    var processRead = false
    var processWrite = false
    
    init(request: ConnectMessage, delegateQueue: dispatch_queue_t) {
        let socket = GCDAsyncSocket()
        self.socket = Socket(socket: socket, delegateQueue: delegateQueue)
        self.connectRequest = request
        self.socket.socketDelegate = self
    }

    func connect() {
        if socket.isDisconnected() {
            self.connectToRemote()
        }
    }
    
    func connectDidFail() {
        self.tunnel?.connectDidFail()
    }
    
    func ready(response: ConnectMessage? = nil) {
        self.forwardingWrite = true
        self.forwardingRead = true
        self.tunnel?.adapterBecameReady(response: response)
    }
    
    // MARK: method to implement in subclass
    func connectToRemote() {}
    func didReadData(data: NSData, withTag: Int) {}
    func didWriteData(data: NSData, withTag: Int) {}
    
    // MARK: helper methods
    func writeData(data: NSData, withTag tag: Int) {
        self.writeData(data, withTimeout: -1, withTag: tag)
    }
    
    func writeData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        let writeData = processWrite ? processWriteData(data) : data
        self.socket.writeData(writeData, withTimeout: timeout, withTag: tag)
    }
    
    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: Int) {
        self.socket.readDataToLength(length, withTimeout: timeout, withTag: tag)
    }
    
    func readDataToLength(length: Int, withTag tag: Int) {
        self.readDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    func readData(#tag: Int) {
        self.socket.readData(tag: tag)
    }
    
    func readDataToData(data: NSData, withTag tag: Int){
        self.readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: Int) {
        self.socket.readDataToData(data, withTimeout: timeout, withTag: tag)
    }
    
    // MARK: data preprocess and process
    
    func processReadData(data: NSData) -> NSData {
        return data
    }
    
    func processWriteData(data: NSData) -> NSData {
        return data
    }
    
    // MARK: delegation methods
    func socketDidDisconnect(socket: Socket, withError err: NSError?) {
        self.connectDidFail()
    }
    
    func socketDidConnectToHost(host: String, onPort: UInt16) {}
    
    func socketDidReadData(data: NSData, withTag tag: Int) {
        let readData = processRead ? processReadData(data) : data
        
        if forwardingRead {
            // call delegate function on tunnel
            if let _tag = Tunnel.TunnelReceiveTag(rawValue: tag) {
                self.tunnel?.didReceiveData(readData, withTag: _tag)
            } else {
                DDLogError("Adapter read some data with unknown data tag \(tag), should be some one in Tunnel.TunnelRecieveTag, disconnect now")
                self.connectDidFail()
            }
        } else {
            self.didReadData(readData, withTag: tag)
        }
    }
    
    func socketDidWriteData(data: NSData, withTag tag: Int) {
        if forwardingWrite {
            if let _tag = Tunnel.TunnelSendTag(rawValue: tag) {
                self.tunnel?.didSendData(data, withTag: _tag)
            } else {
                DDLogError("ProxySocket write some data with unknown data tag \(tag), should be some one in Tunnel.TunnelSendTag, disconnect now")
                self.connectDidFail()
            }
        } else  {
            self.didWriteData(data, withTag: tag)
        }
    }
}
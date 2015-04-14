//
//  SocketTunnel.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/15/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class Tunnel {
    unowned let proxySocket :ProxySocket
    let adapter :Adapter
    var connectRequest :ConnectMessage
    var connectResponse :ConnectMessage?
    enum TunnelReadTag :Int {
        case HTTP_REQUEST_HEADER = 4000, HTTP_REQUEST_CONTENT, DATA
    }
    enum TunnelWriteTag :Int {
        case HTTP_RESPONSE_HEADER = 5000, HTTP_RESPONSE_CONTENT, DATA
    }
    enum TunnelSendTag :Int {
        case HTTP_REQUEST_HEADER = 6000, HTTP_REQUEST_CONTENT, DATA
    }
    enum TunnelReceiveTag :Int {
        case HTTP_RESPONSE_HEADER = 7000, HTTP_RESPONSE_CONTENT, DATA
    }
    
    init(fromSocket proxySocket: ProxySocket, connectTo request: ConnectMessage, withAdapterFactory adapterFactory: AdapterFactory) {
        self.proxySocket = proxySocket
        self.connectRequest = request
        self.adapter = adapterFactory.getAdapter(request, delegateQueue: self.proxySocket.getDelegateQueue())
        self.adapter.tunnel = self
    }
    
    func connect() {
        self.adapter.connect()
    }
    
    func updateRequest(request: ConnectMessage) {
        self.connectRequest = request
        self.adapter.connectRequest = request
    }
    
    
    // MARK: helper methods for adapter
    func sendData(data: NSData, withTag tag: TunnelSendTag) {
        self.adapter.writeData(data, withTag: tag.rawValue)
    }
    
    func receiveData(#tag: TunnelReceiveTag) {
        self.adapter.readData(tag: tag.rawValue)
    }
    
    func receiveDataToLength(length :Int, withTimeout timeout: Double, withTag tag: TunnelReceiveTag) {
        self.adapter.readDataToLength(length, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func receiveDataToLength(length: Int, withTag tag: TunnelReceiveTag) {
        self.receiveDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    func receiveDataToData(data: NSData, withTimeout timeout: Double, withTag tag: TunnelReceiveTag) {
        self.adapter.readDataToData(data, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func receiveDataToData(data: NSData, withTag tag: TunnelReceiveTag){
        self.receiveDataToData(data, withTimeout: -1, withTag: tag)
    }

    // MARK: helper methods for proxy socket
    func writeData(data: NSData, withTag tag: TunnelWriteTag) {
        self.proxySocket.socket.writeData(data, withTag: tag.rawValue)
    }
    
    func readData(#tag: TunnelReadTag) {
        self.proxySocket.socket.readData(tag: tag.rawValue)
    }
    
    func readDataToLength(length :Int, withTimeout timeout: Double, withTag tag: TunnelReadTag) {
        self.proxySocket.socket.readDataToLength(length, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func readDataToLength(length: Int, withTag tag: TunnelReadTag) {
        self.readDataToLength(length, withTimeout: -1, withTag: tag)
    }
    
    func readDataToData(data: NSData, withTimeout timeout: Double, withTag tag: TunnelReadTag) {
        self.proxySocket.socket.readDataToData(data, withTimeout: timeout, withTag: tag.rawValue)
    }
    
    func readDataToData(data: NSData, withTag tag: TunnelReadTag){
        self.readDataToData(data, withTimeout: -1, withTag: tag)
    }
    
    func sendHTTPHeader(data: NSData) {}
    
    // MARK: delegate methods
    func didReadData(data: NSData, withTag tag: TunnelReadTag) {}
    func didWriteData(data: NSData, withTag tag: TunnelWriteTag) {}
    func didSendData(data: NSData, withTag tag: TunnelSendTag) {}
    func didReceiveData(data: NSData, withTag tag: TunnelReceiveTag) {}
    
    func connectDidFail() {
        self.proxySocket.connectDidFail()
    }
    
    func adapterBecameReady(response: ConnectMessage? = nil) {
        self.connectResponse = response
        self.proxySocket.adapterBecameReady(response)
    }
    
    func proxySocketBecameReady() {}
}

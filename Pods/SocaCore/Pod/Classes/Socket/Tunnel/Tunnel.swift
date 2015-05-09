//
//  SocketTunnel.swift
//  SocaCore
//
//  Created by Zhuhao Wang on 2/15/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class Tunnel {
    unowned let proxySocket :ProxySocket
    let adapter :Adapter
    var connectRequest :ConnectRequest
    var connectResponse :ConnectResponse?
    
    init(fromSocket proxySocket: ProxySocket, withRequest request: ConnectRequest, andAdapterFactory adapterFactory: AdapterFactory) {
        self.proxySocket = proxySocket
        self.connectRequest = request
        self.adapter = adapterFactory.getAdapter(request, delegateQueue: self.proxySocket.getDelegateQueue())
        self.adapter.tunnel = self
    }
    
    func connectToRemote() {
        adapter.connect()
    }
    
    func updateRequest(request: ConnectRequest) -> ConnectResponse? {
        connectRequest = request
        return adapter.updateRequest(request)
    }
    
    // MARK: helper methods
    func sendToRemote(data: NSData) {
        adapter.didReceiveDataFromLocal(data)
    }
    
    func sendToLocal(data: NSData) {
        proxySocket.didRecieveDataFromRemote(data)
    }
    
    func sendResponse(response: ConnectResponse? = nil) {
        proxySocket.recievedResponse(response: response)
    }
    
    // MARK: delegate methods
    func adapterConnectionDidFail() {
        proxySocket.connectionDidFail()
    }
    
    func proxySocketBecameReady() {
        adapter.proxySocketReadyForward()
    }
}

//
//  HTTPTunnel.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class HTTPTunnel : Tunnel {
    var removeHTTPProxyHeader: Bool = true
    var rewritePath: Bool = true
    var addHeader: [(String, String)]?
//    let HTTP_HEADER_INDICATOR = -100
    let CHUNK_SIZE = 1000
    var dataToSend = 0
    var dataToRecieve = 0
    
    enum HTTPTag: Int {
        case HEADER = 100000, CONTENT
    }
    
    override func adapterBecameReady(response: ConnectMessage? = nil) {
        if response != nil {
            self.connectResponse = response
            self.removeHTTPProxyHeader = response!.removeHTTPProxyHeader
            self.rewritePath = response!.rewritePath
            addHeader = response!.addHeader
        }
        self.receiveData(tag: .DATA)
        self.proxySocket.adapterBecameReady(response)
    }
    
    override func sendHTTPHeader(data: NSData) {
        let _request = HTTPRequest(headerData: data)
        if removeHTTPProxyHeader {
            _request.removeProxyHeader()
        }
        if rewritePath {
            _request.rewriteToRelativePath()
        }
        if addHeader != nil {
            for (key, value) in addHeader! {
                _request.addHeader(key, value: value)
            }
        }
        DDLogVerbose("Send modified HTTP request header: \n\(_request.toString())")
        self.sendData(_request.toData(), withTag: .HTTP_REQUEST_HEADER)
        if let _length = _request["Content-Length"]?.toInt() {
            self.sendBodyInChunkWithLength(_length)
        } else {
            // unknown length
            self.sendBodyInChunkWithLength(0)
        }
    }
    
    override func didReadData(data: NSData, withTag tag: TunnelReadTag) {
        switch tag {
        case .HTTP_REQUEST_CONTENT:
            self.dataToSend -= data.length
            sendData(data, withTag: .HTTP_REQUEST_CONTENT)
            if self.dataToSend > 0 {
                self.readDataToLength(min(CHUNK_SIZE, self.dataToSend), withTag: .HTTP_REQUEST_CONTENT)
            } else {
                self.beginNewRequest()
            }
        default:
            break
        }
    }
    
    override func didReceiveData(data: NSData, withTag tag: TunnelReceiveTag) {
        self.writeData(data, withTag: .DATA)
        self.receiveData(tag: .DATA)
//        switch tag {
//        case .HTTP_RESPONSE_HEADER:
//            let _request = HTTPRequest(headerData: data)
//            DDLogVerbose("Received http response header: \n\(_request.toString())")
//            self.writeData(data, withTag: .HTTP_RESPONSE_HEADER)
//            if let _length = _request["Content-Length"]?.toInt() {
//                self.receiveBodyInChunkWithLength(_length)
//            } else {
//                self.receiveBodyInChunkWithLength(0)
//            }
//        case .HTTP_RESPONSE_CONTENT:
//            self.dataToRecieve -= data.length
//            writeData(data, withTag: .HTTP_RESPONSE_CONTENT)
//            if self.dataToRecieve > 0 {
//                self.receiveDataToLength(min(CHUNK_SIZE, self.dataToSend), withTag: .HTTP_RESPONSE_CONTENT)
//            } else {
//                beginNewRequest()
//            }
//        default:
//            break
//        }
    }
    
    override func proxySocketBecameReady() {}
    
    func beginNewRequest() {
        self.proxySocket.forwarding = false
        self.proxySocket.openSocket()
    }
    
    
//    func adapterReadHeader() {
//        self.receiveDataToData(Utils.HTTPData.DoubleCRLF, withTag: .HTTP_RESPONSE_HEADER)
//    }
    
    func sendBodyInChunkWithLength(length: Int) {
        if length > 0 {
            self.dataToSend = length
            self.readDataToLength(min(CHUNK_SIZE, self.dataToSend), withTag: .HTTP_REQUEST_CONTENT)
        } else {
            self.dataToSend = 0
            beginNewRequest()
        }
    }
    
    func receiveBodyInChunkWithLength(length: Int) {
        if length > 0 {
            self.dataToRecieve = length
            self.receiveDataToLength(min(CHUNK_SIZE, self.dataToRecieve), withTag: .HTTP_RESPONSE_CONTENT)
        } else {
            self.dataToRecieve = 0
            beginNewRequest()
        }
    }
}
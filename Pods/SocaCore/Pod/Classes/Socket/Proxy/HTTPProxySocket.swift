//
//  HTTPProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/22/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class HTTPProxySocket : ProxySocket {
    class HTTPStatus {
        let CHUNK_SIZE = 1000
        var dataLengthToSend = 0
        
        init(contentLength: Int) {
            dataLengthToSend = contentLength
        }
        
        func chuckLengthToRead() -> Int {
            if dataLengthToSend >= 0 {
                return min(CHUNK_SIZE, dataLengthToSend)
            } else {
                return CHUNK_SIZE
            }
        }
        
        func sentLength(length: Int) {
            dataLengthToSend -= length
        }
        
        func finished() -> Bool {
            return (chuckLengthToRead() <= 0)
        }
    }
    
    enum HTTPMethod : String {
        case GET = "GET", HEAD = "HEAD", POST = "POST", PUT = "PUT", DELETE = "DELETE", TRACE = "TRACE", OPTIONS = "OPTIONS", CONNECT = "CONNECT", PATCH = "PATCH"
    }
    
    var status: HTTPStatus?
    var onceToken: dispatch_once_t = 0
    var forward = false
    
    override func openSocket() {
        readDataToData(Utils.HTTPData.DoubleCRLF, withTag: SocketTag.HTTP.Header)
    }
    
    override func connectToRemote() {
        if tunnel == nil {
            // if this is a new socket without an adapter
            let adapterFactory = proxy.matchRule(self.connectRequest)
            tunnel = Tunnel(fromSocket: self, withRequest: connectRequest, andAdapterFactory: adapterFactory)
            tunnel!.connectToRemote()
        } else {
            let response = tunnel!.updateRequest(connectRequest)
            recievedResponse(response: response)
        }
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        switch tag {
        case SocketTag.HTTP.Header:
            let httpRequest = HTTPRequest(headerData: data)
            switch HTTPMethod(rawValue: httpRequest.method)! {
            case .CONNECT:
                var request = ConnectRequest(host: httpRequest.host, port: httpRequest.port, method: .HTTP_CONNECT)
                request.httpRequest = httpRequest
                connectRequest = request
                readyToConnectToRemote()
            default:
                var request = ConnectRequest(host: httpRequest.host, port: httpRequest.port, method: .HTTP_REQUEST)
                request.httpRequest = httpRequest
                connectRequest = request
                status = HTTPStatus(contentLength: httpRequest.contentLength)
                readyToConnectToRemote()
            }
        case SocketTag.HTTP.Content:
            sendToRemote(data: data)
            status!.sentLength(data.length)
            if !status!.finished() {
                readDataToLength(status!.chuckLengthToRead(), withTag: SocketTag.HTTP.Content)
            } else {
                // begin a new request
                openSocket()
            }
        case SocketTag.Forward:
            sendToRemote(data: data)
            readDataForForward()
        default:
            break
        }
    }
    
    override func recievedResponse(response: ConnectResponse? = nil) {
        switch connectRequest!.method {
        case .HTTP_CONNECT:
            writeData(Utils.HTTPData.ConnectSuccessResponse, withTag: SocketTag.HTTP.ConnectResponse)
        case .HTTP_REQUEST:
            if (!forward) {
                readyForForward()
                forward = true
            }
            connectRequest.httpRequest!.processForSend(rewriteToRelativePath: response?.rewritePath ?? true, removeProxyHeader: response?.removeHTTPProxyHeader ?? true, headerToAdd: response?.headerToAdd)
            sendToRemote(data: connectRequest.httpRequest!.toData())
            if !status!.finished() {
                readDataToLength(status!.chuckLengthToRead(), withTag: SocketTag.HTTP.Content)
            } else {
                openSocket()
            }
        default:
            break
        }
    }
    override func didWriteDataWithTag(tag: Int) {
        if tag == SocketTag.HTTP.ConnectResponse {
            readyForForward()
            readDataForForward()
        }
    }
}
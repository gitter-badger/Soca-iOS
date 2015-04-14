//
//  SOCKS5Adapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/19/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SOCKS5Adapter : Adapter {
    let serverHost: String
    let serverPort: UInt16
    let helloData = NSData(bytes: ([0x05, 0x01, 0x00] as [UInt8]), length: 3)
    var compactConnectData = false
    
    
    enum ReadTag :Int {
        case METHOD = 20000, CONNECT_INFO, CONNECT_IPV4, CONNECT_IPV6, CONNECT_DOMAIN_LENGTH, CONNECT_DOMAIN, CONNECT_PORT
    }
    enum WriteTag :Int {
        case HELLO = 21000, CONNECT
    }
    
    init(request: ConnectMessage, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: UInt16){
        self.serverHost = serverHost
        self.serverPort = serverPort
        
        super.init(request: request, delegateQueue: delegateQueue)
    }
    
    override func connectToRemote() {
        self.socket.connectTo(self.serverHost, port: self.serverPort)
    }
    
    override func socketDidConnectToHost(host: String, onPort: UInt16) {
        self.writeData(helloData, withTag: WriteTag.HELLO.rawValue)
        self.readDataToLength(2, withTag: ReadTag.METHOD.rawValue)
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        if let readTag = ReadTag(rawValue: tag) {
            switch readTag {
            case .METHOD:
                if connectRequest.isIPv4() {
                    var response: [UInt8] = compactConnectData ? [0x01] : [0x05, 0x01, 0x00, 0x01]
                    response += Utils.IP.IPv4ToBytes(self.connectRequest.destinationHost)!
                    let responseData = NSData(bytes: &response, length: response.count)
                    self.writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
                } else if connectRequest.isIPv6() {
                    var response: [UInt8] = compactConnectData ? [0x04] : [0x05, 0x01, 0x00, 0x04]
                    response += Utils.IP.IPv6ToBytes(self.connectRequest.destinationHost)!
                    let responseData = NSData(bytes: &response, length: response.count)
                    self.writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
                } else {
                    var response: [UInt8] = compactConnectData ? [0x03] : [0x05, 0x01, 0x00, 0x03]
                    response.append(UInt8(count(self.connectRequest.destinationHost)))
                    response += [UInt8](self.connectRequest.destinationHost.utf8)
                    let responseData = NSData(bytes: &response, length: response.count)
                    self.writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
                }
                var portBytes = Utils.toByteArray(self.connectRequest.port).reverse()
                let portData = NSData(bytes: &portBytes, length: portBytes.count)
                self.writeData(portData, withTag: WriteTag.CONNECT.rawValue)
                self.readDataToLength(4, withTag: ReadTag.CONNECT_INFO.rawValue)
            case .CONNECT_INFO:
                var requestInfo = [UInt8](count: 5, repeatedValue: 0)
                data.getBytes(&requestInfo, length: 5 * sizeof(UInt8))
                let addressType = requestInfo[3]
                switch addressType {
                case 1:
                    self.readDataToLength(4, withTag: ReadTag.CONNECT_IPV4.rawValue)
                case 3:
                    self.readDataToLength(1, withTag: ReadTag.CONNECT_DOMAIN_LENGTH.rawValue)
                case 4:
                    self.readDataToLength(16, withTag: ReadTag.CONNECT_IPV6.rawValue)
                default:
                    break
                }
            case .CONNECT_DOMAIN_LENGTH:
                let length: UInt8 = UnsafePointer<UInt8>(data.bytes).memory
                self.readDataToLength(Int(length), withTag: ReadTag.CONNECT_DOMAIN.rawValue)
            case .CONNECT_IPV4, .CONNECT_IPV6, .CONNECT_DOMAIN:
                self.readDataToLength(2, withTag: ReadTag.CONNECT_PORT.rawValue)
            case .CONNECT_PORT:
                self.ready()
            }
        }
    }
}
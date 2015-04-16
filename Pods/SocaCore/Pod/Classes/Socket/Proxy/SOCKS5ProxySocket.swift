//
//  SOCKSProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CocoaLumberjack
//import CocoaLumberjackSwift

class SOCKS5ProxySocket : ProxySocket {
    override func openSocket() {
        readDataToLength(3, withTag: .SOCKS_OPEN)
    }
    
    override func connect() {
        let adapterFactory = proxy.matchRule(self.connectRequest)
        self.tunnel = ConnectTunnel(fromSocket: self, connectTo: self.connectRequest, withAdapterFactory: adapterFactory)
        self.tunnel?.connect()
    }
    
    override func didReadData(data: NSData, withTag tag: ProxySocketReadTag) {
        switch tag {
        case .SOCKS_OPEN:
            let response = NSData(bytes: [0x05, 0x00] as [UInt8], length: 2 * sizeof(UInt8))
            self.writeData(response, withTag: .SOCKS_METHOD_RESPONSE)
            self.readDataToLength(4, withTag: .SOCKS_CONNECT_INIT)
        case .SOCKS_CONNECT_INIT:
            var requestInfo = [UInt8](count: 5, repeatedValue: 0)
            data.getBytes(&requestInfo, length: 5 * sizeof(UInt8))
            let addressType = requestInfo[3]
            switch addressType {
            case 1:
                self.readDataToLength(4, withTag: .SOCKS_CONNECT_IPv4)
            case 3:
                self.readDataToLength(1, withTag: .SOCKS_CONNECT_DOMAIN_LENGTH)
            case 4:
                self.readDataToLength(16, withTag: .SOCKS_CONNECT_IPv6)
            default:
                break
            }
        case .SOCKS_CONNECT_IPv4:
            var address = [Int8](count: Int(INET_ADDRSTRLEN), repeatedValue: 0)
            inet_ntop(AF_INET, data.bytes, &address, socklen_t(INET_ADDRSTRLEN))
            self.destinationHost = NSString(bytes: &address, length: Int(INET_ADDRSTRLEN), encoding: NSUTF8StringEncoding) as! String
            self.readDataToLength(2, withTag: .SOCKS_CONNECT_PORT)
        case .SOCKS_CONNECT_IPv6:
            var address = [Int8](count: Int(INET6_ADDRSTRLEN), repeatedValue: 0)
            inet_ntop(AF_INET, data.bytes, &address, socklen_t(INET6_ADDRSTRLEN))
            self.destinationHost = NSString(bytes: &address, length: Int(INET6_ADDRSTRLEN), encoding: NSUTF8StringEncoding) as! String
            self.readDataToLength(2, withTag: .SOCKS_CONNECT_PORT)
        case .SOCKS_CONNECT_DOMAIN_LENGTH:
            let length :UInt8 = UnsafePointer<UInt8>(data.bytes).memory
            self.readDataToLength(Int(length), withTag: .SOCKS_CONNECT_DOMAIN)
        case .SOCKS_CONNECT_DOMAIN:
            self.destinationHost = NSString(bytes: data.bytes, length: data.length, encoding: NSUTF8StringEncoding) as! String
            self.readDataToLength(2, withTag: .SOCKS_CONNECT_PORT)
        case .SOCKS_CONNECT_PORT:
            var rawPort :UInt16 = 0
            data.getBytes(&rawPort, length: sizeof(UInt16))
            self.destinationPort = NSSwapBigShortToHost(rawPort)
            Setup.getLogger().info("Recieved request to \(self.destinationHost):\(self.destinationPort)")
            self.connectRequest = ConnectMessage(host: self.destinationHost!, port: self.destinationPort!, method: .SOCKS5)
            self.connect()
        default:
            Setup.getLogger().error("SOCKS5ProxySocket recieved some data with unknown data tag \(tag), should be some one in ProxySocket.ProxySocketReadTag begins with SOCKS_, disconnect now")
            self.connectDidFail()
            break
        }
    }
    
    override func adapterBecameReady(withResponse: ConnectMessage?) {
        var responseBytes = [UInt8](count: 11, repeatedValue: 0)
        responseBytes[0...3] = [0x05, 0x00, 0x00, 0x01]
        responseBytes[4...7] = [0x7f, 0x00, 0x00, 0x01]
        responseBytes[8...9] = [0x50, 0x66]
        let responseData = NSData(bytes: &responseBytes, length: 10)
        self.writeData(responseData, withTag: .SOCKS_CONNECT_REPONSE)
    }
    
    override func didWriteData(data: NSData, withTag tag: ProxySocketWriteTag) {
        if tag == .SOCKS_CONNECT_REPONSE {
            self.ready()
        }
    }
}
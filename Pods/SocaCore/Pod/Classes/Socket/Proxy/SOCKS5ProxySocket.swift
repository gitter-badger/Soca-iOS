//
//  SOCKSProxySocket.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/17/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SOCKS5ProxySocket : ProxySocket {
    override func openSocket() {
        readDataToLength(3, withTag: SocketTag.SOCKS5.Open)
    }
    
    override func connectToRemote() {
        let adapterFactory = proxy.matchRule(connectRequest)
        tunnel = Tunnel(fromSocket: self, withRequest: connectRequest, andAdapterFactory: adapterFactory)
        tunnel!.connectToRemote()
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        switch tag {
        case SocketTag.SOCKS5.Open:
            let response = NSData(bytes: [0x05, 0x00] as [UInt8], length: 2 * sizeof(UInt8))
            writeData(response, withTag: SocketTag.SOCKS5.MethodResponse)
            readDataToLength(4, withTag: SocketTag.SOCKS5.ConnectInit)
        case SocketTag.SOCKS5.ConnectInit:
            var requestInfo = [UInt8](count: 5, repeatedValue: 0)
            data.getBytes(&requestInfo, length: 5 * sizeof(UInt8))
            let addressType = requestInfo[3]
            switch addressType {
            case 1:
                readDataToLength(4, withTag: SocketTag.SOCKS5.ConnectIPv4)
            case 3:
                readDataToLength(1, withTag: SocketTag.SOCKS5.ConnectDomainLength)
            case 4:
                readDataToLength(16, withTag: SocketTag.SOCKS5.ConnectIPv6)
            default:
                break
            }
        case SocketTag.SOCKS5.ConnectIPv4:
            var address = [Int8](count: Int(INET_ADDRSTRLEN), repeatedValue: 0)
            inet_ntop(AF_INET, data.bytes, &address, socklen_t(INET_ADDRSTRLEN))
            destinationHost = NSString(bytes: &address, length: Int(INET_ADDRSTRLEN), encoding: NSUTF8StringEncoding) as! String
            readDataToLength(2, withTag: SocketTag.SOCKS5.ConnectPort)
        case SocketTag.SOCKS5.ConnectIPv6:
            var address = [Int8](count: Int(INET6_ADDRSTRLEN), repeatedValue: 0)
            inet_ntop(AF_INET, data.bytes, &address, socklen_t(INET6_ADDRSTRLEN))
            destinationHost = NSString(bytes: &address, length: Int(INET6_ADDRSTRLEN), encoding: NSUTF8StringEncoding) as! String
            readDataToLength(2, withTag: SocketTag.SOCKS5.ConnectPort)
        case SocketTag.SOCKS5.ConnectDomainLength:
            let length :UInt8 = UnsafePointer<UInt8>(data.bytes).memory
            readDataToLength(Int(length), withTag: SocketTag.SOCKS5.ConnectDomain)
        case SocketTag.SOCKS5.ConnectDomain:
            destinationHost = NSString(bytes: data.bytes, length: data.length, encoding: NSUTF8StringEncoding) as! String
            readDataToLength(2, withTag: SocketTag.SOCKS5.ConnectPort)
        case SocketTag.SOCKS5.ConnectPort:
            var rawPort :UInt16 = 0
            data.getBytes(&rawPort, length: sizeof(UInt16))
            destinationPort = Int(NSSwapBigShortToHost(rawPort))
            connectRequest = ConnectRequest(host: destinationHost!, port: destinationPort!, method: .SOCKS5)
            didRecieveRequest()
            readyToConnectToRemote()
        case SocketTag.Forward:
            sendToRemote(data: data)
            readDataForForward()
        default:
            connectionDidFail()
            break
        }
    }
    
    override func recievedResponse(#response: ConnectResponse?) {
        var responseBytes = [UInt8](count: 11, repeatedValue: 0)
        responseBytes[0...3] = [0x05, 0x00, 0x00, 0x01]
        responseBytes[4...7] = [0x7f, 0x00, 0x00, 0x01]
        responseBytes[8...9] = [0x50, 0x66]
        let responseData = NSData(bytes: &responseBytes, length: 10)
        writeData(responseData, withTag: SocketTag.SOCKS5.ConnectResponse)
    }
    
    override func didWriteDataWithTag(tag: Int) {
        if tag == SocketTag.SOCKS5.ConnectResponse {
            readyForForward()
            readDataForForward()
        }
    }
}
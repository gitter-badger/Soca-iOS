//
//  SOCKS5Adapter.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/19/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class SOCKS5Adapter : ServerAdapter {
    let helloData = NSData(bytes: ([0x05, 0x01, 0x00] as [UInt8]), length: 3)
    
    enum ReadTag :Int {
        case METHOD = 20000, CONNECT_INFO, CONNECT_IPV4, CONNECT_IPV6, CONNECT_DOMAIN_LENGTH, CONNECT_DOMAIN, CONNECT_PORT
    }
    enum WriteTag :Int {
        case HELLO = 21000, CONNECT
    }
    
    override func connectToRemote() {
        socket.connectToHost(serverHost, withPort: serverPort)
    }
    
    override func connectionEstablished() {
        writeData(helloData, withTag: SocketTag.SOCKS5.Open)
        readDataToLength(2, withTag: SocketTag.SOCKS5.MethodResponse)
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        switch tag {
        case SocketTag.SOCKS5.MethodResponse:
            if connectRequest.isIPv4() {
                var response: [UInt8] = [0x05, 0x01, 0x00, 0x01]
                response += Utils.IP.IPv4ToBytes(connectRequest.host)!
                let responseData = NSData(bytes: &response, length: response.count)
                writeData(responseData, withTag: SocketTag.SOCKS5.ConnectIPv4)
            } else if connectRequest.isIPv6() {
                var response: [UInt8] = [0x05, 0x01, 0x00, 0x04]
                response += Utils.IP.IPv6ToBytes(connectRequest.host)!
                let responseData = NSData(bytes: &response, length: response.count)
                writeData(responseData, withTag: SocketTag.SOCKS5.ConnectIPv6)
            } else {
                var response: [UInt8] = [0x05, 0x01, 0x00, 0x03]
                response.append(UInt8(count(connectRequest.host)))
                response += [UInt8](connectRequest.host.utf8)
                let responseData = NSData(bytes: &response, length: response.count)
                // here we send the domain length and the domain together
                writeData(responseData, withTag: SocketTag.SOCKS5.ConnectDomainLength)
            }
            var portBytes = Utils.toByteArray(UInt16(connectRequest.port)).reverse()
            let portData = NSData(bytes: &portBytes, length: portBytes.count)
            writeData(portData, withTag: SocketTag.SOCKS5.ConnectPort)
            readDataToLength(4, withTag: SocketTag.SOCKS5.ConnectResponse)
        case SocketTag.SOCKS5.ConnectResponse:
            sendResponse(response: nil)
        case SocketTag.Forward:
            sendData(data)
            readDataForForward()
        default:
            break
        }
    }

    override func proxySocketReadyForward() {
        readDataForForward()
    }

    override func didReceiveDataFromLocal(data: NSData) {
        writeData(data, withTag: SocketTag.Forward)
    }
}
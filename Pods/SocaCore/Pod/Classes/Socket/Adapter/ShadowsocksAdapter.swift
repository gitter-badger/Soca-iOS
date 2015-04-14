//
//  ShadowsocksAdapter.swift
//  soca
//
//  Created by Zhuhao Wang on 4/6/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import SocaCrypto

class ShadowsocksAdapter: SOCKS5Adapter {
    var readIV: NSData!
    let key: NSData
    let encryptMethod: EncryptMethod
    lazy var writeIV: NSData = {
        [unowned self] in
        ShadowsocksEncryptHelper.getIV(self.encryptMethod)
    }()
    lazy var ivLength: Int = {
        [unowned self] in
        ShadowsocksEncryptHelper.getIVLength(self.encryptMethod)
    }()
    lazy var encryptor: SOCACryptor = {
        [unowned self] in
        SOCACryptor(operaion: .Encrypt, mode: .CFB, algorithm: .AES, initializaionVector: self.writeIV, key: self.key)
    }()
    lazy var decryptor: SOCACryptor = {
        [unowned self] in
        SOCACryptor(operaion: .Decrypt, mode: .CFB, algorithm: .AES, initializaionVector: self.readIV, key: self.key)
    }()
    
    enum EncryptMethod: String {
        case AES128CFB = "AES-128-CFB", AES192CFB = "AES-192-CFB", AES256CFB = "AES-256-CFB"
        
        static let allValues: [EncryptMethod] = [.AES128CFB, .AES192CFB, .AES256CFB]
    }
    
    enum ShadowsocksTag: Int {
        case IV = 25000
    }
    
    init(request: ConnectMessage, delegateQueue: dispatch_queue_t, serverHost: String, serverPort: UInt16, key: NSData, encryptMethod: EncryptMethod, password: String) {
//        self.key = key
        self.encryptMethod = encryptMethod
        (self.key, _) = ShadowsocksEncryptHelper.getKeyAndIV(password, methodType: encryptMethod)
        super.init(request: request, delegateQueue: delegateQueue, serverHost: serverHost, serverPort: serverPort)
    }
    
    override func socketDidConnectToHost(host: String, onPort: UInt16) {
        writeData(writeIV, withTag: 0)
        processWrite = true
        if connectRequest.isIPv4() {
            var response: [UInt8] = [0x01]
            response += Utils.IP.IPv4ToBytes(self.connectRequest.destinationHost)!
            let responseData = NSData(bytes: &response, length: response.count)
            writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
        } else if connectRequest.isIPv6() {
            var response: [UInt8] = [0x04]
            response += Utils.IP.IPv6ToBytes(self.connectRequest.destinationHost)!
            let responseData = NSData(bytes: &response, length: response.count)
            writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
        } else {
            var response: [UInt8] = [0x03]
            response.append(UInt8(count(self.connectRequest.destinationHost)))
            response += [UInt8](self.connectRequest.destinationHost.utf8)
            let responseData = NSData(bytes: &response, length: response.count)
            writeData(responseData, withTag: WriteTag.CONNECT.rawValue)
        }
        var portBytes = Utils.toByteArray(self.connectRequest.port).reverse()
        let portData = NSData(bytes: &portBytes, length: portBytes.count)
        writeData(portData, withTag: WriteTag.CONNECT.rawValue)
        readDataToLength(ivLength, withTag: ShadowsocksTag.IV.rawValue)
        ready()
        forwardingRead = false
    }
    
    override func didReadData(data: NSData, withTag tag: Int) {
        if tag == ShadowsocksTag.IV.rawValue {
            readIV = data
            processRead = true
            forwardingRead = true
            readData(tag: Tunnel.TunnelReceiveTag.DATA.rawValue)
        } else {
            super.didReadData(data, withTag: tag)
        }
    }
    
    override func processReadData(data: NSData) -> NSData {
        return decryptData(data)
    }
    
    override func processWriteData(data: NSData) -> NSData {
        return encryptData(data)
    }
    
    func encryptData(data: NSData) -> NSData {
        return encryptor.update(data)
    }
    
    func decryptData(data: NSData) -> NSData {
        return decryptor.update(data)
    }
}


struct ShadowsocksEncryptHelper {
    static let infoDictionary: [ShadowsocksAdapter.EncryptMethod:(Int,Int)] = [
        .AES128CFB:(16,16),
        .AES192CFB:(24,16),
        .AES256CFB:(32,16),
    ]
    
    static func getKeyLength(methodType: ShadowsocksAdapter.EncryptMethod) -> Int {
        return infoDictionary[methodType]!.0
    }
    
    static func getIVLength(methodType: ShadowsocksAdapter.EncryptMethod) -> Int {
        return infoDictionary[methodType]!.1
    }
    
    static func getKey(password: String, methodType: ShadowsocksAdapter.EncryptMethod) -> NSData {
        let key = NSMutableData(length: getKeyLength(methodType))!
        let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
        let extendPasswordData = NSMutableData(length: passwordData.length + 1)!
        passwordData.getBytes(extendPasswordData.mutableBytes + 1, length: passwordData.length)
        var md5result = SOCADigest.MD5ByString(password)
        var length = 0
        var i = 0
        do {
            let copyLength = min(key.length - length, md5result.length)
            md5result.getBytes(key.mutableBytes + length, length: copyLength)
            extendPasswordData.replaceBytesInRange(NSRange(location: i, length: 1), withBytes: key.bytes)
            md5result = SOCADigest.MD5ByData(extendPasswordData)
            length += copyLength
            i += 1
        } while length < key.length
        return NSData(data: key)
    }
    
    static func getIV(methodType: ShadowsocksAdapter.EncryptMethod) -> NSData {
        let IV = NSMutableData(length: getIVLength(methodType))!
        SecRandomCopyBytes(kSecRandomDefault, IV.length, UnsafeMutablePointer<UInt8>(IV.mutableBytes))
        return NSData(data: IV)
    }
    
    static func getKeyAndIV(password: String, methodType: ShadowsocksAdapter.EncryptMethod) -> (NSData, NSData) {
        let key = NSMutableData(length: getKeyLength(methodType))!
        let iv = NSMutableData(length: getIVLength(methodType))!
        let result = NSMutableData(length: getIVLength(methodType) + getKeyLength(methodType))!
        let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
        var md5result = SOCADigest.MD5ByString(password)
        let extendPasswordData = NSMutableData(length: passwordData.length + md5result.length)!
        passwordData.getBytes(extendPasswordData.mutableBytes + md5result.length, length: passwordData.length)
        var length = 0
        var i = 0
        do {
            let copyLength = min(result.length - length, md5result.length)
            md5result.getBytes(result.mutableBytes + length, length: copyLength)
            extendPasswordData.replaceBytesInRange(NSRange(location: 0, length: md5result.length), withBytes: md5result.bytes)
            md5result = SOCADigest.MD5ByData(extendPasswordData)
            length += copyLength
            i += 1
        } while length < result.length
        return (result.subdataWithRange(NSRange(location: 0, length: key.length)), result.subdataWithRange(NSRange(location: key.length, length: iv.length)))
    }
}
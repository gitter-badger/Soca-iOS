//
//  ConnectRequest.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

struct ConnectMessage {
    enum Method : Int {
        case HTTP_CONNECT, HTTP_DIRECT, SOCKS5
    }
    
    let destinationHost: String
    let port: UInt16
    let method: Method
    var addHeader: [(String, String)]?
    lazy var IP: String = {
        if self.isIP() {
            return self.destinationHost
        } else {
            return Utils.DNS.resolve(self.destinationHost)
        }
    }()
    lazy var country: String = {
        Utils.GeoIPLookup.Lookup(self.IP)
    }()
    var httpProxyRawHeader: NSData?
    var removeHTTPProxyHeader = true
    var rewritePath = true
    
    
    init(host: String, port: UInt16, method: Method) {
        self.destinationHost = host
        self.port = port
        self.method = method
    }
    
    init(host: String, port: Int, method: Method) {
        self.init(host: host, port: UInt16(port), method: method)
    }
    
//    subscript(index: String) -> Any? {
//        get { return auxiliaries[index] }
//        set { auxiliaries[index] = newValue }
//    }
    
    func _getIP() -> String {
        if isIP() {
            return destinationHost
        } else {
            return Utils.DNS.resolve(destinationHost)
        }
    }
    
    func isIPv4() -> Bool {
        return Utils.IP.isIPv4(self.destinationHost)
    }
    
    func isIPv6() -> Bool {
        return Utils.IP.isIPv6(self.destinationHost)
    }
    
    func isIP() -> Bool {
        return isIPv4() || isIPv6()
    }
}
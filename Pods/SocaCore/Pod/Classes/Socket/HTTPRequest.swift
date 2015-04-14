//
//  HTTPHeader.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/25/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class HTTPRequest {
    var HTTPVersion: String
    var method: String
    var path: String
    var headers: [(String, String)] = []
    var rawHeader: NSData? 
    
    init(headerString: String) {
        let lines = headerString.componentsSeparatedByString("\r\n")
        let _request = lines[0].componentsSeparatedByString(" ")
        method = _request[0]
        path = _request[1]
        HTTPVersion = _request[2]
        for _line in lines[1..<lines.count-2] {
            let _header = _line.componentsSeparatedByString(": ")
            headers.append(_header[0], _header[1])
        }
    }
    
    convenience init(headerData: NSData) {
        self.init(headerString: NSString(data: headerData, encoding: NSUTF8StringEncoding)! as String)
        rawHeader = headerData
    }
    
    subscript(index: String) -> String? {
        get {
            for (key, value) in headers {
                if index.caseInsensitiveCompare(key) == .OrderedSame {
                    return value
                }
            }
            return nil
        }
    }
    
    
    func toData() -> NSData {
        return toString().dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func toString() -> String {
        var _strRep = "\(method) \(path) \(HTTPVersion)\r\n"
        for (key, value) in headers {
            _strRep += "\(key): \(value)\r\n"
        }
        _strRep += "\r\n"
        return _strRep
    }
    
    func addHeader(key: String, value: String) {
        headers.append(key, value)
    }
    
    func rewriteToRelativePath() {
        if path[path.startIndex] != "/" {
            path = Utils.URL.matchRelativePath(path)!
        }
        
    }
    
    func removeHeader(key: String) -> String? {
        for i in 0..<headers.count {
            if headers[i].0.caseInsensitiveCompare(key) == .OrderedSame {
                let (_key, _value) = headers.removeAtIndex(i)
                return _value
            }
        }
        return nil
    }
    
    func removeProxyHeader() {
        let _ProxyHeader = ["Proxy-Authenticate", "Proxy-Authorization", "Proxy-Connection"]
        for _header in _ProxyHeader {
            removeHeader(_header)
        }
    }
}
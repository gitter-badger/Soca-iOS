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
    var host: String
    var port: Int
    var contentLength: Int = 0
    var headers: [(String, String)] = []
    var rawHeader: NSData?
    
    init(headerString: String) {
        let lines = headerString.componentsSeparatedByString("\r\n")
        let request = lines[0].componentsSeparatedByString(" ")
        method = request[0]
        path = request[1]
        HTTPVersion = request[2]
        for line in lines[1..<lines.count-2] {
            let header = line.componentsSeparatedByString(": ")
            headers.append(header[0], header[1])
        }
        if (method.uppercaseString == "CONNECT") {
            let urlInfo = path.componentsSeparatedByString(":")
            host = urlInfo[0]
            port = urlInfo[1].toInt()!
        } else {
            var url: String = ""
            for (key, value) in headers {
                if "Host".caseInsensitiveCompare(key) == .OrderedSame {
                    url = value
                    break
                }
            }
            let urlInfo = url.componentsSeparatedByString(":")
            if urlInfo.count > 1 {
                host = urlInfo[0]
                port = urlInfo[1].toInt()!
            } else {
                host = urlInfo[0]
                port = 80
            }
            for (key, value) in headers {
                if "Content-Length".caseInsensitiveCompare(key) == .OrderedSame {
                    contentLength = value.toInt()!
                    break
                }
            }
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
        var strRep = "\(method) \(path) \(HTTPVersion)\r\n"
        for (key, value) in headers {
            strRep += "\(key): \(value)\r\n"
        }
        strRep += "\r\n"
        return strRep
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
                let (key, value) = headers.removeAtIndex(i)
                return value
            }
        }
        return nil
    }
    
    func removeProxyHeader() {
        let ProxyHeader = ["Proxy-Authenticate", "Proxy-Authorization", "Proxy-Connection"]
        for header in ProxyHeader {
            removeHeader(header)
        }
    }
    
    func processForSend(#rewriteToRelativePath: Bool, removeProxyHeader: Bool, headerToAdd: [(String, String)]?) {
        if rewriteToRelativePath {
            self.rewriteToRelativePath()
        }
        if removeProxyHeader {
            self.removeProxyHeader()
        }
        if let headerToAdd = headerToAdd {
            for (key, value) in headerToAdd {
                addHeader(key, value: value)
            }
        }
    }
}
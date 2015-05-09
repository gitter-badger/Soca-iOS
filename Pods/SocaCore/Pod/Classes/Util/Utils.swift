//
//  Utils.swift
//  Soca
//
//  Created by Zhuhao Wang on 2/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

struct Utils {
    struct HTTPData {
        static let DoubleCRLF = "\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
        static let CRLF = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
        static let ConnectSuccessResponse = "HTTP/1.1 200 Connection Established\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    struct DNS {
        enum QueryType {
            case A, AAAA, UNSPEC
        }
        
        static func resolve(name: String, type: QueryType = .UNSPEC) -> String {
            let remoteHostEnt = gethostbyname2((name as NSString).UTF8String, AF_INET)
            
            if remoteHostEnt == nil {
                return ""
            }
            
            let remoteAddr = UnsafeMutablePointer<in_addr>(remoteHostEnt.memory.h_addr_list[0]).memory
            
            let addr = inet_ntoa(remoteAddr)
            return NSString(UTF8String: addr)! as String
        }
    }
    
    struct URL {
        static let relativePathRegex = NSRegularExpression(pattern: "http.?:\\/\\/.*?(\\/.*)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        
        static func matchRelativePath(url: String) -> String? {
            if let result = relativePathRegex.firstMatchInString(url, options: NSMatchingOptions.allZeros,range: NSRange(location: 0, length: count(url))) {
            
                return (url as NSString).substringWithRange(result.rangeAtIndex(1))
            } else {
                return nil
            }
        }
    }
    
    struct IP {
        static func isIPv4(ip: String) -> Bool {
            if let ipint = IPv4ToInt(ip) {
                return true
            } else {
                return false
            }
        }
        
        static func isIPv6(ip: String) -> Bool {
            let utf8Str = (ip as NSString).UTF8String
            var dst = [UInt8](count: 16, repeatedValue: 0)
            return inet_pton(AF_INET6, utf8Str, &dst) == 1
        }
        
        static func isIP(ip: String) -> Bool {
            return isIPv4(ip) || isIPv6(ip)
        }
        
        static func IPv4ToInt(ip: String) -> UInt32? {
            let utf8Str = (ip as NSString).UTF8String
            var dst = in_addr(s_addr: 0)
            if inet_pton(AF_INET, utf8Str, &(dst.s_addr)) == 1 {
                return UInt32(dst.s_addr)
            } else {
                return nil
            }
        }
        
        static func IPv4ToBytes(ip: String) -> [UInt8]? {
            if let ipv4int = IPv4ToInt(ip) {
                return Utils.toByteArray(ipv4int).reverse()
            } else {
                return nil
            }
        }
        
        static func IPv6ToBytes(ip: String) -> [UInt8]? {
            let utf8Str = (ip as NSString).UTF8String
            var dst = [UInt8](count: 16, repeatedValue: 0)
            if inet_pton(AF_INET6, utf8Str, &dst) == 1 {
                return Utils.toByteArray(dst).reverse()
            } else {
                return nil
            }
        }
    }
    
    struct GeoIPLookup {
        static let geoIPInstance: GeoIP = {
            let bundle = NSBundle(forClass: GeoIP.self)
            let databasePath = bundle.pathForResource("GeoIP", ofType: "dat")!
            return GeoIP(database: databasePath)
        }()
        
        static func Lookup(ip: String) -> String {
            if Utils.IP.isIPv4(ip) {
                return geoIPInstance.lookupCountryCodeForIp(ip)
            } else {
                return "--"
            }
        }
    }
    
    static func toByteArray<T>(var value: T) -> [UInt8] {
        return withUnsafePointer(&value) {
            Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
        }
    }
}
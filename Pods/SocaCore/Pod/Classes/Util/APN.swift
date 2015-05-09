//
//  APN.swift
//  Pods
//
//  Created by Zhuhao Wang on 15/4/18.
//
//

import Foundation

public class APN {
    let kProxyPort = "__PROXYPORT__"
    let kAccessPointName = "__ACCESSPOINTNAME__"
    let kUUID1 = "__UUID1__"
    let kUUID2 = "__UUID2__"
    let kConfigName = "__CONFIGNAME__"
    let kConfigDescription = "__CONFIGDESCRIPTION__"
    
    var config: String
    var portSetted = false
    var APNSetted = false
    
    public init() {
        let bundle = NSBundle(forClass: APN.self)
        let configTemplatePath = bundle.pathForResource("apn", ofType: "mobileconfig")!
        config = NSString(contentsOfFile: configTemplatePath, encoding: NSUTF8StringEncoding, error: nil)! as String
        config = config.stringByReplacingOccurrencesOfString(kUUID1, withString: NSUUID().UUIDString)
        config = config.stringByReplacingOccurrencesOfString(kUUID2, withString: NSUUID().UUIDString)
    }
    
    public func setAPN(port: Int, andAPN apn: String) {
        config = config.stringByReplacingOccurrencesOfString(kProxyPort, withString: String(port))
        config = config.stringByReplacingOccurrencesOfString(kAccessPointName, withString: apn)
        config = config.stringByReplacingOccurrencesOfString(kConfigName, withString: "Soca APN")
        config = config.stringByReplacingOccurrencesOfString(kConfigDescription, withString: "Soca APN configuration with port \(port) and APN \(apn)")
        portSetted = true
        APNSetted = true
    }
    
    public func configString() -> String? {
        if portSetted && APNSetted {
            return config
        } else {
            return nil
        }
    }
    
    public func configFile() -> NSURL? {
        if portSetted && APNSetted {
            let path = NSTemporaryDirectory().stringByAppendingPathComponent("socaapn.mobileconfig")
            config.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            return NSURL(fileURLWithPath: path)
        } else {
            return nil
        }
    }
}
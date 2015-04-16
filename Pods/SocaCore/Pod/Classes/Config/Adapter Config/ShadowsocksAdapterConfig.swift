//
//  ShadowsocksAdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 4/7/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(ShadowsocksAdapterConfig)
public class ShadowsocksAdapterConfig: ServerAdapterConfig {
    override public var type: String { return "Shadowsocks" }

    @NSManaged public var password: String
    @NSManaged public var passwordKey: NSData!
    @NSManaged public var method: String

    
    override public func willSave() {
        if !deleted {
            setPrimitiveValue(ShadowsocksEncryptHelper.getKey(password, methodType: encryptMethod()), forKey: "passwordKey")
        }
        super.willSave()
    }
    
    func encryptMethod() -> ShadowsocksAdapter.EncryptMethod {
        return ShadowsocksAdapter.EncryptMethod(rawValue: method)!
    }
    
    override func adapterFactory() -> AdapterFactory {
        return ShadowsocksAdapterFacotry(host: server, port: UInt16(port), key: passwordKey, method: encryptMethod(), password: password)
    }
    
    public class func allEncryptMethod() -> [String] {
        return ShadowsocksAdapter.EncryptMethod.allValues.map() {
            return $0.rawValue
        }
    }
}

//
//  HTTPAdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/12/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(HTTPAdapterConfig)
public class HTTPAdapterConfig: AuthenticationServerAdapterConfig {
    override public var type: String { return "HTTP" }

    override func adapterFactory() -> AdapterFactory {
        return HTTPAdapterFactory(host: server, port: port, auth: authObject())
    }
    
    func authObject() -> Authentication? {
        if authentication {
            return  Authentication(username: username, password: password)
        } else {
            return nil
        }
    }
}

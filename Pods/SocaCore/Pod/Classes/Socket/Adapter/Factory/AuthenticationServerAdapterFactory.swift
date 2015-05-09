//
//  AuthenticationAdapterFactory.swift
//  soca
//
//  Created by Zhuhao Wang on 3/18/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation

class AuthenticationAdapterFactory : ServerAdapterFactory {
    let auth: Authentication?
    
    init(host: String, port: Int, auth: Authentication?) {
        self.auth = auth
        super.init(host: host, port: port)
    }
}
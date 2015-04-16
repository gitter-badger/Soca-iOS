//
//  AuthenticationServerAdapterConfig.swift
//  soca
//
//  Created by Zhuhao Wang on 3/12/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(AuthenticationServerAdapterConfig)
public class AuthenticationServerAdapterConfig: ServerAdapterConfig {

    @NSManaged public var authentication: Bool
    @NSManaged public var username: String!
    @NSManaged public var password: String!

}

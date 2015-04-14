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

    @NSManaged var authentication: Bool
    @NSManaged var username: String!
    @NSManaged var password: String!

}

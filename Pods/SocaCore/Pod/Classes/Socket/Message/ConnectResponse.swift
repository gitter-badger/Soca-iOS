//
//  ConnectResponse.swift
//  SocaCore
//
//  Created by Zhuhao Wang on 5/4/15.
//
//

import Foundation

class ConnectResponse : ConnectMessage {
    var removeHTTPProxyHeader = true
    var rewritePath = true
    var headerToAdd: [(String, String)] = []
}
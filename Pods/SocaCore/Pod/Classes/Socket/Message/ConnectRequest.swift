//
//  ConnectRequest.swift
//  SocaCore
//
//  Created by Zhuhao Wang on 5/4/15.
//
//

import Foundation

class ConnectRequest : ConnectMessage {
    var httpRequest: HTTPRequest?
    
    func getResponse() -> ConnectResponse {
        return ConnectResponse(host: host, port: port, method: method)
    }
}
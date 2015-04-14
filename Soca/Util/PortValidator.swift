//
//  PortValidator.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import XLForm

class PortValidator : NSObject, XLFormValidatorProtocol {
    let min, max: Int
    
    init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
    
    func isValid(row: XLFormRowDescriptor!) -> XLFormValidationStatus! {
        if let port = row.value as? Int {
            if port > min && port < max {
                return XLFormValidationStatus(msg: nil, status: true, rowDescriptor: row)
            }
        }
        return XLFormValidationStatus(msg: "Invalid port number", status: false, rowDescriptor: row)
    }
}
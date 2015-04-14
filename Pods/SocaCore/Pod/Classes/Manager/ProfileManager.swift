//
//  ProfileManager.swift
//  soca
//
//  Created by Zhuhao Wang on 4/3/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import MagicalRecord

class ProfileManager {
    lazy var configs: [ProfileConfig] = {
        ProfileConfig.MR_findAll() as! [ProfileConfig]
    }()
    
    lazy var profiles: [Profile] = {[unowned self] in
        self.configs.map() {
            $0.profile()
        }
    }()

    
}
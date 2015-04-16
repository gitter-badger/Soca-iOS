//
//  Setup.swift
//  Pods
//
//  Created by Zhuhao Wang on 4/14/15.
//
//

import Foundation
import CoreData
import MagicalRecord
import XCGLogger

public class Setup {
    public class func setupCoreData() {
        let location = NSBundle(forClass: DirectAdapterConfig.self)
        let model = NSManagedObjectModel.mergedModelFromBundles([location])!
        NSManagedObjectModel.MR_setDefaultManagedObjectModel(model)
        MagicalRecord.setupAutoMigratingCoreDataStack()
        checkAndFixAdapters()
    }
    
    public class func cleanUpCoreData() {
        MagicalRecord.cleanUp()
    }
    
    public class func getLogger() -> XCGLogger {
        return XCGLogger.defaultInstance()
    }
    
    class func checkAndFixAdapters() {
        // Add a direct adapter if there isn't one
        if DirectAdapterConfig.MR_countOfEntities() == 0 {
            let adapter = DirectAdapterConfig.MR_createEntity() as! DirectAdapterConfig
            adapter.name = "Direct Adapter"
            adapter.managedObjectContext!.MR_saveToPersistentStoreAndWait()
        }
    }
}
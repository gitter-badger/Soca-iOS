//
//  ProfileManager.swift
//  SocaCore
//
//  Created by Zhuhao Wang on 4/3/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import MagicalRecord

/**
 *  Use Manager to run and stop profiles and show profiles in TableView.
*/
public class ProfileManager: NSObject, NSFetchedResultsControllerDelegate {
    static let manager = ProfileManager()
    public class func getManager() -> ProfileManager {
        return manager
    }
    
    var currentProfile: Profile?
    public var currentRunningIndex: NSIndexPath? {
        if currentProfile == nil || currentProfile!.running == false {
            return nil
        } else {
            return fetchedResultsController.indexPathForObject(currentProfile!.config)
        }
    }
    public weak var delegate: NSFetchedResultsControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        [unowned self] in
        ProfileConfig.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: nil, ascending: true, delegate: self)
    }()
    
    public var sections: [NSFetchedResultsSectionInfo] {
        return fetchedResultsController.sections! as! [NSFetchedResultsSectionInfo]
    }
    
    public subscript(indexPath: NSIndexPath) -> ProfileConfig {
        return fetchedResultsController.objectAtIndexPath(indexPath) as! ProfileConfig
    }
    
    private override init() {
        super.init()
    }
    
    func startProfileAtIndex(indexPath: NSIndexPath) {
        fetchedResultsController.managedObjectContext 
        stopProfile()
        currentProfile = self[indexPath].profile()
        currentProfile!.start()
        controller(fetchedResultsController, didChangeObject: currentProfile!, atIndexPath: indexPath, forChangeType: .Update, newIndexPath: nil)
    }
    
    public func stopProfile() {
        if let currentProfile = currentProfile {
            currentProfile.stop()
            controller(fetchedResultsController, didChangeObject: currentProfile, atIndexPath: fetchedResultsController.indexPathForObject(currentProfile.config), forChangeType: .Update, newIndexPath: nil)
        }
    }
    
    public func toggleProfileAtIndex(indexPath: NSIndexPath) {
        if indexPath == currentRunningIndex {
            stopProfile()
        } else {
            startProfileAtIndex(indexPath)
        }
    }
    
    // MARK: Delegate methods for NSFetchedResultsControllerDelegate
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        delegate?.controllerWillChangeContent?(controller)
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        delegate?.controllerDidChangeContent?(controller)
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        delegate?.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        delegate?.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }
}
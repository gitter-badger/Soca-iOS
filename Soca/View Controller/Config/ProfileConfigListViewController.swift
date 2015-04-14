//
//  File.swift
//  soca
//
//  Created by Zhuhao Wang on 4/4/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import UIKit
import CoreData
import SocaCore

protocol ProfileConfigDelegate {
    func finishEditingConfig(config: ProfileConfig, save: Bool)
}

class ProfileConfigListViewController : UITableViewController, NSFetchedResultsControllerDelegate, ProfileConfigDelegate {
    lazy var fetchedResultsController: NSFetchedResultsController = {
        [unowned self] in
        ProfileConfig.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: nil, ascending: true, delegate: self)
        }()
    lazy var editContext: NSManagedObjectContext = {
        NSManagedObjectContext.MR_context()
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return (fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo).numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let profileConfig = fetchedResultsController.objectAtIndexPath(indexPath) as! ProfileConfig
        
        cell.textLabel!.text = profileConfig.name
        cell.detailTextLabel!.text = "Proxy: \(profileConfig.proxies.count)"
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        presentProfileConfigDetail(fetchedResultsController.objectAtIndexPath(indexPath) as! ProfileConfig)
    }
    
    @IBAction func addButtonTouched() {
        presentProfileConfigDetail(ProfileConfig.MR_createInContext(editContext) as! ProfileConfig)
    }
    
    func presentProfileConfigDetail(profileConfig: ProfileConfig) {
        let profileConfigViewController = ProfileConfigViewController(profileConfig: profileConfig)
        profileConfigViewController.delegate = self
        let navController = UINavigationController(rootViewController: profileConfigViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func finishEditingConfig(config: ProfileConfig, save: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

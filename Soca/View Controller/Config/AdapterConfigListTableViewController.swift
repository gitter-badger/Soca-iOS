//
//  AdapterListTableViewController.swift
//  soca
//
//  Created by Zhuhao Wang on 3/10/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import UIKit
import SocaCore
import CoreData

protocol AdapterConfigDelegate {
    func finishEditingConfig(config: AdapterConfig, save: Bool)
}

class AdapterConfigListTableViewController: UITableViewController, AdapterConfigDelegate, NSFetchedResultsControllerDelegate {
    lazy var fetchedResultsController: NSFetchedResultsController = {
        [unowned self] in
        AdapterConfig.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: nil, ascending: true, delegate: self)
    }()
    lazy var editContext: NSManagedObjectContext = {
        NSManagedObjectContext.MR_context()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAdapterDetail(adapterConfig: AdapterConfig) {
        var adapterViewController: AdapterConfigViewController!
        switch adapterConfig {
        case is SOCKS5AdapterConfig:
            adapterViewController = ServerAdapterConfigViewController(adapterConfig: adapterConfig)
        case is HTTPAdapterConfig, is SHTTPAdapterConfig:
            adapterViewController = AuthenticationServerAdapterConfigViewController(adapterConfig: adapterConfig)
        case is ShadowsocksAdapterConfig:
            adapterViewController = ShadowsocksAdapterConfigViewController(adapterConfig: adapterConfig)
        default:
            return
        }
        adapterViewController.delegate = self
        let navController = UINavigationController(rootViewController: adapterViewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }

    @IBAction func showAdapterTypeSheet(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Choose adapter type", message: nil, preferredStyle: .ActionSheet)
        
        
        let HTTPAction = UIAlertAction(title: "HTTP", style: .Default) {_ in
            self.presentAdapterDetail(HTTPAdapterConfig.MR_createInContext(self.editContext) as! AdapterConfig)
        }
        let SHTTPAction = UIAlertAction(title: "Secured HTTP", style: .Default) {_ in
            self.presentAdapterDetail(SHTTPAdapterConfig.MR_createInContext(self.editContext) as! AdapterConfig)
        }
        let SOCKS5Action = UIAlertAction(title: "SOCKS5", style: .Default) {_ in
            self.presentAdapterDetail(SOCKS5AdapterConfig.MR_createInContext(self.editContext) as! AdapterConfig)
        }
        let SSAction = UIAlertAction(title: "Shadowsocks", style: .Default) {_ in
            self.presentAdapterDetail(ShadowsocksAdapterConfig.MR_createInContext(self.editContext) as! AdapterConfig)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) {_ in }

        alertController.addAction(HTTPAction)
        alertController.addAction(SHTTPAction)
        alertController.addAction(SOCKS5Action)
        alertController.addAction(SSAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo).numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("adapterCell", forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let adapterConfig: AdapterConfig = fetchedResultsController.objectAtIndexPath(indexPath) as! AdapterConfig
        cell.textLabel!.text = adapterConfig.name
        cell.detailTextLabel!.text = adapterConfig.type
        
        if adapterConfig is DirectAdapterConfig || adapterConfig is BlackHoleAdapterConfig {
            cell.selectionStyle = .None
            cell.accessoryType = .None
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var configToEdit = fetchedResultsController.objectAtIndexPath(indexPath).MR_inContext(editContext) as! AdapterConfig
        presentAdapterDetail(configToEdit as AdapterConfig)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let adapter: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        if adapter is DirectAdapterConfig || adapter is BlackHoleAdapterConfig {
            return false
        }
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let config = fetchedResultsController.objectAtIndexPath(indexPath) as! AdapterConfig
            config.MR_deleteEntity()
            config.managedObjectContext?.MR_saveToPersistentStoreAndWait()
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
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

    // MARK: - AdapterConfigDelegate
    
    func finishEditingConfig(config: AdapterConfig, save: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

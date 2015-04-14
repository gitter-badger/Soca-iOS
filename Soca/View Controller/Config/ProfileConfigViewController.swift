//
//  ProfileConfigViewController.swift
//  soca
//
//  Created by Zhuhao Wang on 4/4/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import UIKit
import XLForm
import SocaCore
import CoreData

protocol RuleConfigDelegate {
    func finishEditingRule(config: RuleConfig, save: Bool)
}

class ProfileConfigViewController : XLFormViewController, RuleConfigDelegate {
    let kNameRow = "name"
    let kAddProxyRow = "addProxy"
    
    let kRuleRow = "rule"
    let kAddRuleRow = "addRule"
    
    var nameRow, addProxyRow, typeRow, ruleRow, addRuleRow: XLFormRowDescriptor!
    
    var profileConfig: ProfileConfig!
    var editContext: NSManagedObjectContext!
    func refreshContext() {
        editContext = NSManagedObjectContext.MR_contextWithParent(self.profileConfig.managedObjectContext)
    }
    
    var delegate: ProfileConfigDelegate!
    
    convenience init(profileConfig: ProfileConfig) {
        self.init()
        self.profileConfig = profileConfig
        refreshContext()
        initializeForm()
    }
    
    func initializeForm() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancel"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("save"))
        
        initializeRows()
        
        let form = XLFormDescriptor()
        form.delegate = self
        
        var section = XLFormSectionDescriptor()
        section.title = "Profile Detail"
        section.addFormRow(nameRow)
        form.addFormSection(section)
        
        for proxyConfig in profileConfig.proxies {
            section = ProxyConfigSectionDescriptor(proxyConfig: proxyConfig as! ProxyConfig)
            form.addFormSection(section)
        }
        
        section = XLFormSectionDescriptor()
        section.addFormRow(addProxyRow)
        form.addFormSection(section)
        
        self.form = form
        
        if profileConfig.objectID.temporaryID {
            self.title = "Add Profile"
        } else {
            self.title = "Edit \(profileConfig.name)"
            loadConfig()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: false)
    }
    
    func initializeRows() {
        nameRow = XLFormRowDescriptor(tag: kNameRow, rowType: XLFormRowDescriptorTypeText, title: "Name")
        nameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        nameRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        nameRow.required = true
        addProxyRow = XLFormRowDescriptor(tag: kAddProxyRow, rowType: XLFormRowDescriptorTypeButton, title: "Add New Proxy")
        addProxyRow.action.formSelector = "didTouchAddProxyButton:"
        addProxyRow.cellConfig["textLabel.textColor"] = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        addProxyRow.cellConfig["textLabel.font"] = UIFont.boldSystemFontOfSize(16)
    }
    
    func save() {
        if validateFormAndSave() {
            profileConfig.managedObjectContext?.MR_saveToPersistentStoreAndWait()
            delegate?.finishEditingConfig(profileConfig, save: true)
        }
    }
    
    func cancel() {
        profileConfig.managedObjectContext?.reset()
        delegate?.finishEditingConfig(profileConfig, save: false)
    }
    
    func validateFormAndSave() -> Bool {
        let errors = formValidationErrors()
        if (errors.count > 0) {
            showFormValidationError(errors[0] as! NSError)
            return false
        }
        saveConfig()
        return true
    }
    
    func saveConfig() {
        profileConfig.name = nameRow.value as! String
        for section in form.formSections {
            if let section = section as? ProxyConfigSectionDescriptor {
                section.proxyConfig.port = (section.formRows[0] as! XLFormRowDescriptor).value as! Int
            }
        }
    }
    
    func loadConfig() {
        nameRow.value = profileConfig.name
        for section in form.formSections {
            if let section = section as? ProxyConfigSectionDescriptor {
                (section.formRows[0] as! XLFormRowDescriptor).value = section.proxyConfig.port
            }
        }
    }
    
    func didTouchAddProxyButton(sender: XLFormRowDescriptor) {
        deselectFormRow(sender)
        
        let alertController = UIAlertController(title: "Choose proxy type", message: nil, preferredStyle: .ActionSheet)
        let HTTPAction = UIAlertAction(title: "HTTP", style: .Default) {_ in
            let proxyConfig = HTTPProxyConfig.createWithDefaultRule(self.profileConfig.managedObjectContext)
            proxyConfig.profile = self.profileConfig
//            self.refreshContext()
            self.form.addFormSection(ProxyConfigSectionDescriptor(proxyConfig: proxyConfig), atIndex: UInt(self.form.formSections.count - 1))
        }
        let SOCKS5Action = UIAlertAction(title: "SOCKS5", style: .Default) {_ in
            let proxyConfig = SOCKS5ProxyConfig.createWithDefaultRule(self.profileConfig.managedObjectContext)
            proxyConfig.profile = self.profileConfig
//            self.refreshContext()
            self.form.addFormSection(ProxyConfigSectionDescriptor(proxyConfig: proxyConfig), atIndex: UInt(self.form.formSections.count - 1))
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) {_ in }
        
        alertController.addAction(HTTPAction)
        alertController.addAction(SOCKS5Action)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didTouchDeleteProxyButton(sender: XLFormRowDescriptor) {
        deselectFormRow(sender)
        let section = sender.sectionDescriptor as! ProxyConfigSectionDescriptor
        section.proxyConfig.MR_deleteEntity()
        form.removeFormSection(section)
    }
    
    func didTouchRuleButton(sender: XLFormRowDescriptor) {
        deselectFormRow(sender)
        if let row = sender as? RuleConfigRowDescriptor {
            presentRuleConfigViewController(row.ruleConfig.MR_inContext(editContext) as! RuleConfig)
        } else {
            let proxyConfig = self.editContext.objectWithID((sender.sectionDescriptor as! ProxyConfigSectionDescriptor).proxyConfig.objectID) as! ProxyConfig
            
            let alertController = UIAlertController(title: "Choose Rule Type", message: nil, preferredStyle: .ActionSheet)
            
            let allRule = UIAlertAction(title: "Match All", style: .Default) { _ in
                let rule = AllRuleConfig.MR_createInContext(self.editContext) as! RuleConfig
                let rules = proxyConfig.rules.mutableCopy() as! NSMutableOrderedSet
                rules.insertObject(rule, atIndex: rules.count - 1)
                proxyConfig.rules = rules.copy() as! NSOrderedSet
                self.presentRuleConfigViewController(rule)
            }
            let countryRule = UIAlertAction(title: "Country", style: .Default) { _ in
                let rule = CountryRuleConfig.MR_createInContext(self.editContext) as! RuleConfig
                let rules = proxyConfig.rules.mutableCopy() as! NSMutableOrderedSet
                rules.insertObject(rule, atIndex: rules.count - 1)
                proxyConfig.rules = rules.copy() as! NSOrderedSet
                self.presentRuleConfigViewController(rule)
            }
            let cancelAction = UIAlertAction(title: "cancle", style: .Cancel) { _ in }
            
            alertController.addAction(allRule)
            alertController.addAction(countryRule)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func presentRuleConfigViewController(ruleConfig: RuleConfig) {
        var ruleConfigViewController: RuleConfigViewController!
        switch ruleConfig {
        case is CountryRuleConfig:
            ruleConfigViewController = CountryRuleConfigViewController(ruleConfig: ruleConfig)
        case is AllRuleConfig:
            ruleConfigViewController = AllRuleConfigViewController(ruleConfig: ruleConfig)
        default:
            break
        }
        ruleConfigViewController.delegate = self
        let navController = UINavigationController(rootViewController: ruleConfigViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func finishEditingRule(config: RuleConfig, save: Bool) {
        if save {
            let section = _findSectionContainRule(config)
            section.reloadRules()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func _findSectionContainRule(ruleConfig: RuleConfig) -> ProxyConfigSectionDescriptor! {
        for section in form.formSections {
            if let section = section as? ProxyConfigSectionDescriptor {
                if section.proxyConfig.objectID == ruleConfig.proxy.objectID {
                    return section
                }
            }
        }
        return nil
    }
    
    // MARK: TableViewDelegate 
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == form.formSections.count - 1 {
            return false
        }
        if indexPath.row < 2 || indexPath.row > (form.formSections[indexPath.section] as! XLFormSectionDescriptor).formRows.count - 4 {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.section > sourceIndexPath.section {
            return NSIndexPath(forRow: (form.formSections[sourceIndexPath.section] as! XLFormSectionDescriptor).formRows.count - 4, inSection: sourceIndexPath.section)
        }
        if proposedDestinationIndexPath.section < sourceIndexPath.section {
            return NSIndexPath(forRow: 2, inSection: sourceIndexPath.section)
        }
        if proposedDestinationIndexPath.row < 2 {
            return NSIndexPath(forRow: 2, inSection: sourceIndexPath.section)
        }
        if proposedDestinationIndexPath.row > (form.formSections[sourceIndexPath.section] as! XLFormSectionDescriptor).formRows.count - 4 {
            return NSIndexPath(forRow: (form.formSections[sourceIndexPath.section] as! XLFormSectionDescriptor).formRows.count - 4, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let proxyConfig = (form.formSections[sourceIndexPath.section] as! ProxyConfigSectionDescriptor).proxyConfig as ProxyConfig
        let rules = proxyConfig.rules.mutableCopy() as! NSMutableOrderedSet
        let rule = rules[sourceIndexPath.row - 2] as! RuleConfig
        rules.removeObjectAtIndex(sourceIndexPath.row - 2)
        rules.insertObject(rule, atIndex: destinationIndexPath.row - 2)
        proxyConfig.rules = rules.copy() as! NSOrderedSet
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let section = form.formSections[indexPath.section] as! ProxyConfigSectionDescriptor
            let proxyConfig = section.proxyConfig
            let ruleConfig = proxyConfig.rules.objectAtIndex(indexPath.row - 2) as! RuleConfig
            ruleConfig.MR_deleteEntity()
            form.removeFormRow(form.formRowAtIndex(indexPath))
        }
    }
}

class ProxyConfigSectionDescriptor : XLFormSectionDescriptor {
    let kPortRow = "port"
    let kTypeRow = "type"
    let kDeleteRow = "delete"
    let kAddRuleRow = "addRule"
    var portRow, typeRow, deleteRow, addRuleRow: XLFormRowDescriptor!
    
    let proxyConfig: ProxyConfig
    
    init(proxyConfig: ProxyConfig) {
        self.proxyConfig = proxyConfig
        super.init()
        self.title = "Proxy Configuration"
        portRow = XLFormRowDescriptor(tag: kPortRow, rowType: XLFormRowDescriptorTypeInteger, title: "Port")
        portRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        portRow.required = true
        portRow.addValidator(PortValidator(min: 1024, max: 65535))
        typeRow = XLFormRowDescriptor(tag: kTypeRow, rowType: XLFormRowDescriptorTypeInfo, title: "Type")
        typeRow.value = proxyConfig.type
        addRuleRow = XLFormRowDescriptor(tag: kAddRuleRow, rowType: XLFormRowDescriptorTypeButton, title: "Add New Rule")
        addRuleRow.action.formSelector = "didTouchRuleButton:"
        addRuleRow.cellConfig["textLabel.textColor"] = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        addRuleRow.cellConfig["textLabel.font"] = UIFont.boldSystemFontOfSize(16)
        deleteRow = XLFormRowDescriptor(tag: kDeleteRow, rowType: XLFormRowDescriptorTypeButton, title: "Delete this proxy")
        deleteRow.action.formSelector = "didTouchDeleteProxyButton:"
        deleteRow.cellConfig["textLabel.textColor"] = UIColor.redColor()
        
        loadRules()
    }
    
    func loadRules() {
        self.addFormRow(portRow)
        self.addFormRow(typeRow)
        
        for rule in proxyConfig.rules.array {
            let rule = rule as! RuleConfig
            let ruleRow = RuleConfigRowDescriptor(ruleConfig: rule)
            if rule == proxyConfig.rules.lastObject! as! NSObject {
                ruleRow.disabled = true
                ruleRow.action.formSelector = nil
                ruleRow.tag = "directRule"
            }
            self.addFormRow(ruleRow)
        }
        
        self.addFormRow(addRuleRow)
        self.addFormRow(deleteRow)
    }
    
    func reloadRules() {
        while formRows.count > 0 {
            removeFormRowAtIndex(0)
        }
        loadRules()
    }
}

class RuleConfigRowDescriptor : XLFormRowDescriptor {
    var ruleConfig: RuleConfig!
    
    convenience init(ruleConfig: RuleConfig) {
        self.init(tag: "rule", rowType: XLFormRowDescriptorTypeButton, title: ruleConfig.name)
        self.ruleConfig = ruleConfig
        action.formSelector = "didTouchRuleButton:"
    }
}
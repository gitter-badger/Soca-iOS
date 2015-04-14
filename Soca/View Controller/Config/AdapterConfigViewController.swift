//
//  AddAdapterViewController.swift
//  soca
//
//  Created by Zhuhao Wang on 3/9/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import XLForm
import SocaCore

class AdapterConfigViewController: XLFormViewController {
    let kNameRow = "name"
    
    var adapterConfig: AdapterConfig!
    var nameRow: XLFormRowDescriptor!
    var delegate: AdapterConfigDelegate?
    
    convenience init(adapterConfig: AdapterConfig) {
        self.init()
        self.adapterConfig = adapterConfig
        initializeForm()
    }
    
    func initializeForm() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancel"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("save"))
        
        initializeRows()
        
        if adapterConfig.objectID.temporaryID {
            self.title = "Add \(adapterConfig.type) Adapter"
        } else {
            self.title = "Modify \(adapterConfig.name)"
            loadConfig()
        }
        
        let form = XLFormDescriptor()
        form.delegate = self
        
        let section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        self.form = form
        
        showForm()
    }
    
    func initializeRows() {
        nameRow = XLFormRowDescriptor(tag: kNameRow, rowType: XLFormRowDescriptorTypeName, title: "Name")
        nameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        nameRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        nameRow.required = true
    }
    
    func cancel() {
        adapterConfig.managedObjectContext?.reset()
        delegate?.finishEditingConfig(adapterConfig, save: false)
    }
    
    func save() {
        if validateFormAndSave() {
            adapterConfig.managedObjectContext?.MR_saveToPersistentStoreAndWait()
            delegate?.finishEditingConfig(adapterConfig, save: true)
        }
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
        adapterConfig.name = nameRow.value as! String
    }
    
    func loadConfig() {
        nameRow.value = adapterConfig.name
    }
    
    func showForm() {
        form.formSectionAtIndex(0).addFormRow(nameRow)
    }
}

class ServerAdapterConfigViewController: AdapterConfigViewController {
    let kServerRow = "server"
    let kPortRow = "port"
    var serverRow, portRow: XLFormRowDescriptor!
    
    override func initializeRows() {
        super.initializeRows()
        serverRow = XLFormRowDescriptor(tag: kServerRow, rowType: XLFormRowDescriptorTypeURL, title: "Server")
        //        serverRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        serverRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        serverRow.required = true
        portRow = XLFormRowDescriptor(tag: kPortRow, rowType: XLFormRowDescriptorTypeInteger, title: "Port")
        //        portRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        portRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        portRow.required = true
        portRow.addValidator(PortValidator(min: 0, max: 65535))
    }
    
    override func loadConfig() {
        super.loadConfig()
        serverRow.value = (adapterConfig as! ServerAdapterConfig).server
        portRow.value = (adapterConfig as! ServerAdapterConfig).port
    }
    
    override func saveConfig() {
        super.saveConfig()
        let config = adapterConfig as! ServerAdapterConfig
        config.server = serverRow.value as! String
        config.port = portRow.value as! Int
    }
    
    override func showForm() {
        super.showForm()
        form.addFormRow(serverRow, afterRowTag: kNameRow)
        form.addFormRow(portRow, afterRowTag: kServerRow)
    }
    
}

class AuthenticationServerAdapterConfigViewController: ServerAdapterConfigViewController {
    let kAuthenticationRow = "auth"
    let kUsernameRow = "username"
    let kPasswordRow = "password"
    var authenticationRow, usernameRow, passwordRow: XLFormRowDescriptor!
    
    override func initializeRows() {
        super.initializeRows()
        
        authenticationRow = XLFormRowDescriptor(tag: kAuthenticationRow, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Authentication")
        authenticationRow.value = false
        usernameRow = XLFormRowDescriptor(tag: kUsernameRow, rowType: XLFormRowDescriptorTypeAccount, title: "Username")
        usernameRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        usernameRow.required = true
        passwordRow = XLFormRowDescriptor(tag: kPasswordRow, rowType: XLFormRowDescriptorTypePassword, title: "Password")
        passwordRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        passwordRow.required = true

    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, var oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == kAuthenticationRow {
            // the oldValue might be nil
            if oldValue == nil || oldValue as! NSObject == kCFNull {
                oldValue = false
            }
            if (oldValue as! Bool) && !(newValue as! Bool) {
                // from auth to non-auth
                form.removeFormRow(usernameRow)
                form.removeFormRow(passwordRow)
            } else if !(oldValue as! Bool) && (newValue as! Bool) {
                // form non-auth to auth
                form.addFormRow(usernameRow, afterRowTag: kAuthenticationRow)
                form.addFormRow(passwordRow, afterRowTag: kUsernameRow)
            }
        }
    }
    
    override func loadConfig() {
        super.loadConfig()
        authenticationRow.value = (adapterConfig as! AuthenticationServerAdapterConfig).authentication
        if authenticationRow.value as! Bool {
            usernameRow.value = (adapterConfig as! AuthenticationServerAdapterConfig).username
            passwordRow.value = (adapterConfig as! AuthenticationServerAdapterConfig).password
        }
    }
    
    override func saveConfig() {
        super.saveConfig()
        let config = adapterConfig as! AuthenticationServerAdapterConfig
        config.authentication = authenticationRow.value as! Bool
        if config.authentication {
            config.username = usernameRow.value as! String
            config.password = passwordRow.value as! String
        }
    }
    
    override func showForm() {
        super.showForm()
        form.addFormRow(authenticationRow, afterRowTag: kPortRow)
        if (adapterConfig as! AuthenticationServerAdapterConfig).authentication {
            form.addFormRow(usernameRow, afterRowTag: kAuthenticationRow)
            form.addFormRow(passwordRow, afterRowTag: kUsernameRow)
        }
    }
}

class ShadowsocksAdapterConfigViewController : ServerAdapterConfigViewController {
    let kPasswordRow = "password"
    let kMethodRow = "method"
    var passwordRow, methodRow: XLFormRowDescriptor!
    
    override func initializeRows() {
        super.initializeRows()
        
        passwordRow = XLFormRowDescriptor(tag: kPasswordRow, rowType: XLFormRowDescriptorTypeAccount, title: "Password")
        passwordRow.required = true
        passwordRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        methodRow = XLFormRowDescriptor(tag: kMethodRow, rowType: XLFormRowDescriptorTypeSelectorPush, title: "Method")
        methodRow.required = true
        methodRow.selectorOptions = ShadowsocksAdapterConfig.allEncryptMethod()
    }
    
    override func showForm() {
        super.showForm()
        form.addFormRow(passwordRow, afterRowTag: kPortRow)
        form.addFormRow(methodRow, afterRowTag: kPasswordRow)
    }
    
    override func loadConfig() {
        super.loadConfig()
        let config = adapterConfig as! ShadowsocksAdapterConfig
        passwordRow.value = config.password
        methodRow.value = config.method
    }
    
    override func saveConfig() {
        super.saveConfig()
        let config = adapterConfig as! ShadowsocksAdapterConfig
        config.password = passwordRow.value as! String
        config.method = methodRow.value as! String
    }
}
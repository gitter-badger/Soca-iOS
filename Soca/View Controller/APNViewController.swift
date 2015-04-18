//
//  APNViewController.swift
//  Soca
//
//  Created by Zhuhao Wang on 15/4/18.
//  Copyright (c) 2015年 Zhuhao Wang. All rights reserved.
//

import UIKit
import MessageUI
import XLForm
import SocaCore

class APNViewController: XLFormViewController, MFMailComposeViewControllerDelegate {

    @IBAction func cancelButtonTouched(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneButtonTouched(sender: UIBarButtonItem) {
        if (validateForm()) {
            let apn = APN()
            let port = form.formRowWithTag("port").value as! Int
            let apnName = form.formRowWithTag("apn").value as! String
            apn.setAPN(port, andAPN: apnName)
            
            let mailTitle = "Soca APN config"
            let mailBody = "The configuration file is attched to this email, please send it to yourself and open it in Mail app on your iOS device."
            
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setSubject(mailTitle)
            mailController.setMessageBody(mailBody, isHTML: false)
            
            mailController.addAttachmentData(apn.configString()!.dataUsingEncoding(NSUTF8StringEncoding), mimeType: "application/x-apple-aspen-config", fileName: "soca.mobileconfig")
            
            presentViewController(mailController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
        
        switch result.value {
        case MFMailComposeResultSaved.value, MFMailComposeResultSent.value:
            dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
    func validateForm() -> Bool {
        let errors = formValidationErrors()
        if (errors.count > 0) {
            showFormValidationError(errors[0] as! NSError)
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let form = XLFormDescriptor()
        let section = XLFormSectionDescriptor()
        section.footerTitle = "You need to set the correct APN name, e.g., for Unicom, it's 3gnet."
        let portRow = XLFormRowDescriptor(tag: "port", rowType: XLFormRowDescriptorTypeInteger, title: "Proxy port")
        portRow.required = true
        portRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        portRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        let apnRow = XLFormRowDescriptor(tag: "apn", rowType: XLFormRowDescriptorTypeName, title: "APN name")
        apnRow.required = true
        apnRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        apnRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        section.addFormRow(portRow)
        section.addFormRow(apnRow)
        form.addFormSection(section)
        form.delegate = self
        
        self.form = form
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

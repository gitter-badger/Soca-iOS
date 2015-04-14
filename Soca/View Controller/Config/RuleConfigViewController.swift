//
//  RuleConfigViewController.swift
//  soca
//
//  Created by Zhuhao Wang on 3/14/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import UIKit
import SocaCore
import XLForm

class RuleConfigViewController: XLFormViewController {
    let kNameRow = "name"
    let kAdapterRow = "adapter"
    
    var ruleConfig: RuleConfig!
    lazy var adapters: [AdapterConfig] = {
        [unowned self] in
        AdapterConfig.MR_findAllInContext(self.ruleConfig.managedObjectContext) as! [AdapterConfig]
    }()
    var delegate: RuleConfigDelegate?
    var nameRow, adapterRow: XLFormRowDescriptor!
    
    convenience init(ruleConfig: RuleConfig) {
        self.init()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancel"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("done"))
        self.ruleConfig = ruleConfig

        initializeForm()
    }
    
    func initializeForm() {
        initializeRows()
        
        if ruleConfig.objectID.temporaryID {
            self.title = "Add \(ruleConfig.type) Rule"
        } else {
            self.title = "Modify \(ruleConfig.name)"
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
        nameRow.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        nameRow.required = true
        adapterRow = XLFormRowDescriptor(tag: kAdapterRow, rowType: XLFormRowDescriptorTypeSelectorPush, title: "Adapter")
        let options = adapters.map() { adapter in
            XLFormOptionsObject(value: adapter, displayText: adapter.name)
        }
        adapterRow.selectorOptions = options
        adapterRow.required = true
        // set a default value for adapter
        adapterRow.value = options.last
    }
    
    func cancel() {
        ruleConfig.managedObjectContext?.reset()
        delegate?.finishEditingRule(ruleConfig, save: false)
    }
    
    func done() {
        if validateFormAndSave() {
            ruleConfig.managedObjectContext?.MR_saveOnlySelfAndWait()
            delegate?.finishEditingRule(ruleConfig, save: true)
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
        ruleConfig.name = nameRow.value as! String
        ruleConfig.adapter = (adapterRow.value as! XLFormOptionsObject).formValue() as! AdapterConfig
    }
    
    func loadConfig() {
        nameRow.value = ruleConfig.name
        if let adapter = _findAdapterOptions(ruleConfig.adapter) {
            adapterRow.value = adapter
        }
    }
    
    func showForm() {
        form.formSectionAtIndex(0).addFormRow(nameRow)
        form.addFormRow(adapterRow, afterRowTag: kNameRow)
    }

    func _findAdapterOptions(adapter: AdapterConfig?) -> XLFormOptionsObject? {
        if let adapter = adapter {
            for option in adapterRow.selectorOptions as! [XLFormOptionsObject] {
                if option.formValue() as! AdapterConfig == adapter {
                    return option
                }
            }
        }
        return nil
    }
}

class AllRuleConfigViewController : RuleConfigViewController {
    
}

class CountryRuleConfigViewController : RuleConfigViewController {
    let kCountryRow = "country"
    let kMatchRow = "match"
    
    var countryRow, matchRow: XLFormRowDescriptor!
    let countryCode = ["--", "AP", "EU", "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AN", "AO", "AQ", "AR", "AS", "AT", "AU", "AW", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BM", "BN", "BO", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN", "CO", "CR", "CU", "CV", "CX", "CY", "CZ", "DE", "DJ", "DK", "DM", "DO", "DZ", "EC", "EE", "EG", "EH", "ER", "ES", "ET", "FI", "FJ", "FK", "FM", "FO", "FR", "FX", "GA", "GB", "GD", "GE", "GF", "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN", "HR", "HT", "HU", "ID", "IE", "IL", "IN", "IO", "IQ", "IR", "IS", "IT", "JM", "JO", "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI", "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD", "MG", "MH", "MK", "ML", "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ", "NA", "NC", "NE", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "PA", "PE", "PF", "PG", "PH", "PK", "PL", "PM", "PN", "PR", "PS", "PT", "PW", "PY", "QA", "RE", "RO", "RU", "RW", "SA", "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "ST", "SV", "SY", "SZ", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TM", "TN", "TO", "TL", "TR", "TT", "TV", "TW", "TZ", "UA", "UG", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU", "WF", "WS", "YE", "YT", "RS", "ZA", "ZM", "ME", "ZW", "A1", "A2", "O1", "AX", "GG", "IM", "JE", "BL", "MF"]
    let countryName = ["Local", "Asia/Pacific Region", "Europe", "Andorra", "United Arab Emirates", "Afghanistan", "Antigua and Barbuda", "Anguilla", "Albania", "Armenia", "Netherlands Antilles", "Angola", "Antarctica", "Argentina", "American Samoa", "Austria", "Australia", "Aruba", "Azerbaijan", "Bosnia and Herzegovina", "Barbados", "Bangladesh", "Belgium", "Burkina Faso", "Bulgaria", "Bahrain", "Burundi", "Benin", "Bermuda", "Brunei Darussalam", "Bolivia", "Brazil", "Bahamas", "Bhutan", "Bouvet Island", "Botswana", "Belarus", "Belize", "Canada", "Cocos (Keeling) Islands", "Congo, The Democratic Republic of the", "Central African Republic", "Congo", "Switzerland", "Cote D'Ivoire", "Cook Islands", "Chile", "Cameroon", "China", "Colombia", "Costa Rica", "Cuba", "Cape Verde", "Christmas Island", "Cyprus", "Czech Republic", "Germany", "Djibouti", "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ecuador", "Estonia", "Egypt", "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji", "Falkland Islands (Malvinas)", "Micronesia, Federated States of", "Faroe Islands", "France", "France, Metropolitan", "Gabon", "United Kingdom", "Grenada", "Georgia", "French Guiana", "Ghana", "Gibraltar", "Greenland", "Gambia", "Guinea", "Guadeloupe", "Equatorial Guinea", "Greece", "South Georgia and the South Sandwich Islands", "Guatemala", "Guam", "Guinea-Bissau", "Guyana", "Hong Kong", "Heard Island and McDonald Islands", "Honduras", "Croatia", "Haiti", "Hungary", "Indonesia", "Ireland", "Israel", "India", "British Indian Ocean Territory", "Iraq", "Iran, Islamic Republic of", "Iceland", "Italy", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "Kiribati", "Comoros", "Saint Kitts and Nevis", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Cayman Islands", "Kazakhstan", "Lao People's Democratic Republic", "Lebanon", "Saint Lucia", "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania", "Luxembourg", "Latvia", "Libyan Arab Jamahiriya", "Morocco", "Monaco", "Moldova, Republic of", "Madagascar", "Marshall Islands", "Macedonia", "Mali", "Myanmar", "Mongolia", "Macau", "Northern Mariana Islands", "Martinique", "Mauritania", "Montserrat", "Malta", "Mauritius", "Maldives", "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "New Caledonia", "Niger", "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal", "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru", "French Polynesia", "Papua New Guinea", "Philippines", "Pakistan", "Poland", "Saint Pierre and Miquelon", "Pitcairn Islands", "Puerto Rico", "Palestinian Territory", "Portugal", "Palau", "Paraguay", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saudi Arabia", "Solomon Islands", "Seychelles", "Sudan", "Sweden", "Singapore", "Saint Helena", "Slovenia", "Svalbard and Jan Mayen", "Slovakia", "Sierra Leone", "San Marino", "Senegal", "Somalia", "Suriname", "Sao Tome and Principe", "El Salvador", "Syrian Arab Republic", "Swaziland", "Turks and Caicos Islands", "Chad", "French Southern Territories", "Togo", "Thailand", "Tajikistan", "Tokelau", "Turkmenistan", "Tunisia", "Tonga", "Timor-Leste", "Turkey", "Trinidad and Tobago", "Tuvalu", "Taiwan", "Tanzania, United Republic of", "Ukraine", "Uganda", "United States Minor Outlying Islands", "United States", "Uruguay", "Uzbekistan", "Holy See (Vatican City State)", "Saint Vincent and the Grenadines", "Venezuela", "Virgin Islands, British", "Virgin Islands, U.S.", "Vietnam", "Vanuatu", "Wallis and Futuna", "Samoa", "Yemen", "Mayotte", "Serbia", "South Africa", "Zambia", "Montenegro", "Zimbabwe", "Anonymous Proxy", "Satellite Provider", "Other", "Aland Islands", "Guernsey", "Isle of Man", "Jersey", "Saint Barthelemy", "Saint Martin"]
    
    override func initializeRows() {
        super.initializeRows()
        
        countryRow = XLFormRowDescriptor(tag: kCountryRow, rowType: XLFormRowDescriptorTypeSelectorPush, title: "Country")
        countryRow.required = true
        matchRow = XLFormRowDescriptor(tag: kMatchRow, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Apply to match")
        matchRow.value = false
        matchRow.required = true
    
        countryRow.selectorOptions = map(enumerate(countryCode)) {
            XLFormOptionsObject(value: $1, displayText: self.countryName[$0])
        }
        countryRow.value = _findCountryOptions("CN")
    }
    
    override func loadConfig() {
        super.loadConfig()
        let config = ruleConfig as! CountryRuleConfig
        matchRow.value = config.match
        if let option = _findCountryOptions(config.country) {
            countryRow.value = option
        }
    }
    
    override func saveConfig() {
        super.saveConfig()
        let config = ruleConfig as! CountryRuleConfig
        config.match = matchRow.value as! Bool
        config.country = (countryRow.value as! XLFormOptionObject).formValue() as! String
    }
    
    override func showForm() {
        super.showForm()
        form.addFormRow(matchRow, afterRowTag: kNameRow)
        form.addFormRow(countryRow, afterRowTag: kMatchRow)
    }
    
    func _findCountryOptions(countryCode: String?) -> XLFormOptionsObject? {
        if let countryCode = countryCode {
            for option in countryRow.selectorOptions as! [XLFormOptionsObject] {
                if option.formValue() as! String == countryCode {
                    return option
                }
            }
        }
        return nil
    }
    
}
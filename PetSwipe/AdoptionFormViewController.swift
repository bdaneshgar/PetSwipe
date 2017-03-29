//
//  FormViewController.swift
//  PetSwipe
//
//  Created by Brian Daneshgar on 3/25/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit
import Eureka

class AdoptionFormViewController: FormViewController {
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lobster-Regular", size: 24)!,  NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 24)!,  NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backItem?.title = "Back"

        self.title = "Adoption Form"
        
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }

        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
            
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        form =
                
            Section() {
                $0.header = HeaderFooterView<PetSwipeLogoView>(.class)
            }
            
            +++ Section("Basic")
            <<< TextRow(){
                $0.title = "Name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            <<< DateRow(){
                $0.title = "Date"
                $0.value = Date()
            }
            +++ Section("Home")
            <<< TextRow(){
                $0.title = "Address"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            <<< TextRow(){
                $0.title = "City"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            <<< TextRow(){
                $0.title = "State"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            <<< ZipCodeRow() {
                $0.title = "ZIP"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 5))
                $0.add(rule: RuleMaxLength(maxLength: 5))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            +++ Section("Contact")
            <<< PhoneRow(){
                $0.title = "Phone"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 10))
                $0.add(rule: RuleMaxLength(maxLength: 10))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< TextRow() {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            
            +++ Section("Are you 21+?")
            <<< SegmentedRow<String>("21"){
                $0.options = ["No", "Yes"]
                $0.value = "No"
            }
        
            +++ Section("Employment")
            <<< PickerInputRow<String>("Employed"){
                $0.title = "Employed"
                $0.options = ["Full Time", "Part Time", "Unemployed", "Student", "Retired", "Other"]
                $0.value = $0.options.first
            }
            <<< TextAreaRow() {
                $0.placeholder = "If other please explain"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            +++ Section("If currently employed")
            <<< TextRow(){ row in
                row.title = "Employer"
            }
            <<< TextRow(){ row in
                row.title = "Job Title"
            }
            <<< DateRow(){
                $0.title = "Date Began"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
        
            +++ Section("If student")
            <<< TextRow(){ row in
                row.title = "Where"
            }
            +++ Section("If Spouse / Partner, Employment info")
            <<< TextRow(){ row in
                row.title = "Partner Employer"
            }
            <<< TextRow(){ row in
                row.title = "Partner Occupation"
            }
            <<< DateRow(){
                $0.title = "Date Began"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            
            +++ Section("How many adults live in your home other than yourself")
            <<< StepperRow() {
                $0.title = "Adults"
                $0.value = 0
            }
            <<< TextAreaRow() {
                $0.placeholder = "Names and Ages"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
        
            +++ Section("How many children live in your home")
            <<< StepperRow() {
                $0.title = "Children"
                $0.value = 0
            }
            <<< TextAreaRow() {
                $0.placeholder = "Names and Ages"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            +++ Section("Are ALL members of your household aware of and in agreement with this adoption?")
            <<< SegmentedRow<String>("Aware"){
                $0.options = ["No", "Yes"]
                $0.value = "No"
            }
            <<< TextAreaRow() {
                $0.disabled = "$Aware = 'Yes'"
                $0.placeholder = "If not, please list who is not in favor of the adoption and the nature of their concern or objection"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
        
            +++ Section("Current Address")
            <<< PickerInputRow<String>("Own or Rent"){
                $0.title = "Own or Rent"
                $0.options = ["Own", "Rent"]
                $0.value = $0.options.first
            }
            <<< PickerInputRow<String>("Address Type"){
                $0.title = "Address Type"
                $0.options = ["Home", "Condo", "Mobile", "Apartment"]
                $0.value = $0.options.first
            }
            <<< DateRow(){
                $0.title = "Date Moved In"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("Previous Address")
            <<< TextAreaRow() {
                $0.placeholder = "If less than two years what was your previous address?"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            +++ Section("If you rent:")
            <<< PickerInputRow<String>("Pets Allowed"){
                $0.title = "Pets Allowed"
                $0.options = ["Yes", "No", "Don't Know"]
                $0.value = $0.options.first
            }
            <<< StepperRow() {
                $0.title = "# of Pets Allowed"
                $0.value = 0
            }
            <<< TextRow(){ row in
                row.title = "Landlord Name"
                row.placeholder = "Full Name"
            }
            <<< PhoneRow(){
                $0.title = "Landlord Phone"
                $0.placeholder = "##########"
            }
            +++ Section("Future Housing")
            <<< TextAreaRow() {
                $0.placeholder = "Do you plan on moving in the foreseeable future? If so, where will you move, and why?"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            
            +++ Section("Why do you want to adopt a pet?")
            <<< PickerInputRow<String>("Why"){
                $0.title = "Why"
                $0.options = ["House Pet", "Guard Dog", "Gift", "Barn Cat", "Companion", "For another pet"]
                $0.value = $0.options.first
            }
            <<< TextAreaRow() {
                $0.placeholder = "If gift, for whom?"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            
            +++ Section("Types of pet interested in")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Types"
                $0.options = ["Friendly", "Shy or timid", "High-energy", "Pet that needs training", "Pet with special medical needs", "Senior pet", "Physically challenged or handicapped"]
                $0.value = []
                }
            
            +++ Section("Preferred level of exercise with pet")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Exercise"
                $0.options = ["Couch potato",
                              "Yard exercise",
                              "Short walks",
                              "Vigorous walks",
                              "Hiking/jogging"]

                $0.value = []
            }
        
            +++ Section("Strong preferences in a pet")
            <<< CheckRow() {
                $0.title = "Female"
                $0.value = false
            }
            <<< CheckRow() {
                $0.title = "Male"
                $0.value = false
            }
            <<< CheckRow() {
                $0.title = "Long Hair"
                $0.value = false
            }
            <<< CheckRow() {
                $0.title = "Short Hair"
                $0.value = false
            }
            <<< CheckRow() {
                $0.title = "Non-shed or hypoallergenic"
                $0.value = false
            }
            <<< CheckRow() {
                $0.title = "Female"
                $0.value = false
            }
        
    }
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}


class CustomCellsController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++
            Section() {
                var header = HeaderFooterView<PetSwipeLogoViewNib>(.nibFile(name: "PetSwipeSectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                $0.header = header
        }
    }
}

class PetSwipeLogoViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class PetSwipeLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "paw-png"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

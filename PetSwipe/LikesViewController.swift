//
//  LikesViewController.swift
//  PetSwipe
//
//  Created by Brian Daneshgar on 2/28/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import SCLAlertView

class LikesTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet var petImageView: UIImageView!
}


class LikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    
    @IBOutlet var menuButton: UIBarButtonItem!

    @IBOutlet var tableView: UITableView!
    
    var pets: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "PetCD")
        
        //3
        do {
            pets = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        
        tableView.delegate = self
        tableView.dataSource = self


        // Do any additional setup after loading the view.
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            menuButton.tintColor = UIColor.white
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            navigationController?.navigationBar.barTintColor = UIColor.orange
            self.title = "PetSwipe"
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lobster-Regular", size: 24)!,  NSForegroundColorAttributeName: UIColor.white]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pets.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LikesTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! LikesTableViewCell
        let pet =  pets[indexPath.row]
        cell.label?.text = pet.value(forKeyPath: "name") as? String
        
        let url = URL(string: pet.value(forKeyPath: "photoURL") as! String)!
        
        let data = NSData(contentsOf:url)
        if data != nil {
            cell.petImageView.image = UIImage(data:data! as Data)
             cell.petImageView.layer.borderWidth = 1.0
             cell.petImageView.layer.masksToBounds = false
             cell.petImageView.layer.borderColor = UIColor.white.cgColor
             cell.petImageView.layer.cornerRadius = ( cell.petImageView.layer.frame.size.width)/2
             cell.petImageView.clipsToBounds = true
        }
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            //remove object from core data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(self.pets[indexPath.row])
            
            do {
                try context.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
            }
            
            //update UI methods
            tableView.beginUpdates()
            pets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            appDelegate.saveContext()
        }
    }
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        
        let name = self.pets[indexPath.row].value(forKeyPath: "name")! as! String
        let photo = self.pets[indexPath.row].value(forKeyPath: "photoURL")!
        let photoURL = URL(string: photo as! String)
        let data = NSData(contentsOf:photoURL!)
        let image = UIImage(data:data! as Data)

        var info = self.pets[indexPath.row].value(forKeyPath: "info")! as! String
        let tag = self.pets[indexPath.row].value(forKeyPath: "tag")!
        let email = self.pets[indexPath.row].value(forKeyPath: "email")!
        var phone = self.pets[indexPath.row].value(forKeyPath: "phone")! as! String
        phone = phone.digits
        
        
        let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
        let alert = SCLAlertView(appearance: appearance)

        
        alert.addButton("Call") {
            print("phone: \(phone)")
            
            
            if(phone == ""){

                let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
                let callAlert = SCLAlertView(appearance: appearance)
                let icon = UIImage(named:"paw")
                let color = UIColor.orange

            
                _ = callAlert.showCustom("Oh no!", subTitle: "No phone number provided!", color: color, icon: icon!)

            } else {
                
                let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
                let callAlert = SCLAlertView(appearance: appearance)
                callAlert.addButton("Call") {
                    self.callNumber(phoneNumber: phone)
                }
                
                let icon = UIImage(named:"paw")
                let color = UIColor.orange
                
                _ = callAlert.showCustom("Call the shelter?", subTitle: "", color: color, icon: icon!)
                
            }
        }
        alert.addButton("Message") {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["\(email)"])
            composeVC.setCcRecipients(["brian@petswipeapp.com"])
            composeVC.setSubject("Hello (\(name))!")
            composeVC.setMessageBody("Hi!\n\nI am interested in learning more about \(name)!\n\nAttached is a photo.\n\nCan you send some information about this pet along with a time and place to meet?\n\nThanks!\n\nSent via PetSwipe\npetswipeapp.com", isHTML: false)
            
            let imageData: NSData = UIImagePNGRepresentation(image!)! as NSData
            composeVC.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName")
            
            // Present the view controller modally.
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
                let mailAlert = SCLAlertView(appearance: appearance)
                let icon = UIImage(named:"paw")
                let color = UIColor.orange
                
                _ = mailAlert.showCustom("Mail services are not available!", subTitle: "", color: color, icon: icon!)
                
                
                return
            } else{
                self.present(composeVC, animated: true, completion: nil)
            }
        }
        
        let icon = UIImage(named:"paw")
        let color = UIColor.orange
        
        _ = alert.showCustom(name, subTitle: info, color: color, icon: icon!)
        
        

        /*
        
        print("You selected cell with tag: \(tag)!")

        let max = 600
        let length = info.characters.count
        if(length > max){
            let endIndex = info.index(info.endIndex, offsetBy: (max - length))
            info = info.substring(to: endIndex)
            info = "\(info)..."
        }

        let alertController = UIAlertController(title: "\(name)", message: "\(info)", preferredStyle: UIAlertControllerStyle.alert)

        
        let OKAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        let profileAction = UIAlertAction(title: "View Profile", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            let url = URL(string: "https://www.petfinder.com/petdetail/\(tag)")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }

            print("View Profile")
        }
        
        let phoneAction = UIAlertAction(title: "Call", style: .default) {
            (result : UIAlertAction) -> Void in
            

            print("phone: \(phone)")
            if(phone == ""){
                let callAlert = UIAlertController(title: "Oh no!", message: "No number was provided! Try sending a message instead!", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "Cancel", style: .cancel) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                callAlert.addAction(ok)
                self.present(callAlert, animated: true, completion: nil)

            } else{
                let callAlert = UIAlertController(title: "Contact Shelter?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
                    (result : UIAlertAction) -> Void in
                    print("Cancel")
                }
                let call = UIAlertAction(title: "Call", style: .default) {
                    (result : UIAlertAction) -> Void in
                    self.callNumber(phoneNumber: phone)
                }
                callAlert.addAction(cancel)
                callAlert.addAction(call)

                self.present(callAlert, animated: true, completion: nil)
            }
        }
        
        
        let messageAction = UIAlertAction(title: "Message", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            

            let url = "https://www.petfinder.com/petdetail/\(tag)"
            print(url)
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["\(email)"])
            composeVC.setCcRecipients(["brian@petswipeapp.com"])
            composeVC.setSubject("Hello (\(name))!")
            
            
            //composeVC.setMessageBody("Hi!\n\nI am interested in learning more about \(name):\n\n\(url)\n\nCan you send more information along with a time and place to meet?\n\nThanks!\n\nSent via PetSwipe\npetswipeapp.com", isHTML: false)
            
            composeVC.setMessageBody("Hi!\n\nI am interested in learning more about \(name)!\n\nAttached is a photo.\n\nCan you send some information about this pet along with a time and place to meet?\n\nThanks!\n\nSent via PetSwipe\npetswipeapp.com", isHTML: false)

            let imageData: NSData = UIImagePNGRepresentation(image!)! as NSData
            composeVC.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName")
            
            // Present the view controller modally.
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            } else{
                self.present(composeVC, animated: true, completion: nil)
            }
            
        }
        
        
        alertController.addAction(phoneAction)
        alertController.addAction(messageAction)
        
//        alertController.addAction(profileAction)
//        alertController.addAction(DestructiveAction)
        alertController.addAction(OKAction)

        
        self.present(alertController, animated: true, completion: nil)
 
 */
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "detail" ,
            let nextScene = segue.destination as? PetDetailViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedPet = self.pets[indexPath.row]
            nextScene.currentPet = selectedPet
        }
        
    }
    
    
    
    @available(iOS 4.0, *)
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("done")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

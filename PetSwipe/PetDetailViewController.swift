//
//  PetDetailViewController.swift
//  PetSwipe
//
//  Created by Brian Daneshgar on 3/24/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit

class PetDetailViewController: UIViewController {
    
    var currentPet = NSObject()
    
    var name = String()
    var photo = String()
    var image = UIImage()
    var tag = String()
    var email = String()
    var phone = String()

    @IBOutlet var tableView: UITableView!
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.barTintColor = .orange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backItem?.title = "Back"
        
        name = currentPet.value(forKey: "name") as! String
        photo = currentPet.value(forKey: "photoURL") as! String
        let photoURL = URL(string: photo)
        let data = NSData(contentsOf: photoURL!)
        image = UIImage(data: data as! Data)!
        tag = currentPet.value(forKey: "tag") as! String
        email = currentPet.value(forKey: "email") as! String
        phone = currentPet.value(forKey: "phone") as! String
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

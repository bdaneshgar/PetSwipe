//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Edited by Brian Daneshgar on 2/18/17.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MessageUI
import SAConfettiView
import CoreData
import SCLAlertView


class DraggableViewBackground: UIView, DraggableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    /*!
     @method     messageComposeViewController:didFinishWithResult:
     @abstract   Delegate callback which is called upon user's completion of message composition.
     @discussion This delegate callback will be called when the user completes the message composition.
     How the user chose to complete this task will be given as one of the parameters to the
     callback.  Upon this call, the client should remove the view associated with the controller,
     typically by dismissing modally.
     @param      controller   The MFMessageComposeViewController instance which is returning the result.
     @param      result       MessageComposeResult indicating how the user chose to complete the composition process.
     */
    @available(iOS 4.0, *)
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("done")
    }

    var exampleCardLabels: [String]!
    var allCards: [DraggableView]!

    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 290

    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    
    var detailView: UIView!
    var detailTextView: UITextView!
    var initDragView: UIView!
    
    var petDict = [String: Pet]()
    
    var currentPet: Pet!
    var pets = [Pet]()
    
    var delegate : ParentProtocol?

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        exampleCardLabels = []
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
        self.getPets { (bool) in
            print("completed")
//            self.setupTapGesture()
            self.loadCards()
            
//            print(self.petDict)

        }
        
    }
    
    
    func getPets(completion:@escaping (Bool) -> ()) {
        //get pets
        let zip = UserDefaults.standard.value(forKey: "zip") as! String
        print(zip)
        let suffix = UserDefaults.standard.value(forKey: "suffix") as! String
        print("suffix: \(suffix)")

        let count = 50
        
        
        let taskUrl = "https://api.petfinder.com/pet.find?format=json&key=78bfafe0cb78056b9af33b0ffcb17c7b&location=\(zip)&count=\(count)\(suffix)"
        
        
        Alamofire.request(taskUrl).responseJSON { response in
//            print(response.request!)  // original URL request
//            print(response.response!) // HTTP URL response
//            print(response.data!)     // server data
//            print(response.result)   // result of response serialization
            
            
            if let JSON = response.result.value as? [String: Any] {
                
                
                let petList = ((JSON["petfinder"] as? [String: Any])?["pets"] as? [String:Any])?["pet"] as! [[String: Any]]
                
                print(petList.count)
                
                for _ in 0 ..< petList.count {
                    
                    let pet = Pet()

                    
                    
                    /* Repeated three times */
                    var randomPet = petList[Int(arc4random_uniform(UInt32(count)))]
                    if let tag = (randomPet["id"] as? [String:Any])?["$t"] as? String {
                        pet.tag = tag 
                    }
                    if let photoURL = ((((randomPet["media"] as? [String: Any])?["photos"] as? [String:Any])?["photo"] as? [[String:Any]])?[2])?["$t"] as? String{
                        pet.photoURL = photoURL
                    }
                    if let name = (randomPet["name"] as? [String:Any])?["$t"] as? String{
                        pet.name = name
                    }
                    if let age = (randomPet["age"] as? [String:Any])?["$t"] as? String {
                        pet.age = age
                    }
                    if let gender = (randomPet["sex"] as? [String:Any])?["$t"] as? String {
                        pet.gender = gender
                    }
                    if let city = ((randomPet["contact"] as? [String: Any])?["city"] as? [String:Any])?["$t"] as? String {
                        pet.city = city
                    }
                    if let email = ((randomPet["contact"] as? [String: Any])?["email"] as? [String:Any])?["$t"] as? String {
                        pet.email = email
                    }
                    if let description = (randomPet["description"] as? [String:Any])?["$t"] as? String {
                        pet.information = description
                    }
                    if let phone = ((randomPet["contact"] as? [String: Any])?["phone"] as? [String:Any])?["$t"] as? String {
                        pet.phone = phone
                    }

        

//                    self.exampleCardLabels.append(photoURL)
                    
                    self.pets.append(pet)
                    
                }
                completion(true)
            }
        }
        
        
        
        
    }
    
    func dismiss(){
        self.removeFromSuperview()
        delegate?.removeOverlay()
        
    }
    

    func setupView() -> Void {
    
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 0)
        
        detailView = UIView(frame: CGRect(x: CGFloat((self.frame.size.width - CARD_WIDTH) / 2), y: CGFloat((self.frame.size.height - CARD_HEIGHT) / 2), width: CGFloat(CARD_WIDTH), height: CGFloat(CARD_HEIGHT)))
        detailView.backgroundColor = UIColor.white
        
        
        detailTextView = UITextView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(CARD_WIDTH), height: CGFloat(CARD_HEIGHT)))
        detailTextView.isEditable = false
        detailTextView.font = UIFont(name: "HelveticaNeue-Light", size: CGFloat(16))
        detailTextView.backgroundColor = UIColor.clear
//        detailTextView.text = currentPet.information
        detailView.addSubview(detailTextView)
        
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBack(sender:)))
        detailTextView.addGestureRecognizer(tapBack)
        
    }
    
    
    
//    func setupBtns(){
//        xButton = UIButton(frame: CGRect(x: 0, y: self.frame.size.height - 100, width: self.frame.size.width/2, height: 100))
//        xButton.setImage(UIImage(named: "xButton"), for: UIControlState())
//        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)
//        
//        checkButton = UIButton(frame: CGRect(x: self.frame.size.width, y: self.frame.size.height - 100, width: self.frame.size.width/2, height: 100))
//        checkButton.setImage(UIImage(named: "checkButton"), for: UIControlState())
//        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
//        
//        self.addSubview(xButton)
//        self.addSubview(checkButton)
//    }
    

    func createDraggableViewWithDataAtIndex(_ index: NSInteger) -> DraggableView {
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        
        draggableView.pet = pets[index]
        
        currentPet = pets[index]
        
        if(currentPet.photoURL != nil){
            let url = URL(string: currentPet.photoURL!)
            let data = try? Data(contentsOf: url!)
            if(data != nil){
                draggableView.imageView.image = UIImage(data: data!)
            } else{
                let url = URL(string: "http://petswipeapp.com/img/paw.jpg")
                currentPet.photoURL = "http://petswipeapp.com/img/paw.jpg"
                let data = try? Data(contentsOf: url!)
                draggableView.imageView.image = UIImage(data: data!)
            }
        } else {
            let url = URL(string: "http://petswipeapp.com/img/paw.jpg")
            currentPet.photoURL = "http://petswipeapp.com/img/paw.jpg"
            let data = try? Data(contentsOf: url!)
            draggableView.imageView.image = UIImage(data: data!)
        }
        
        draggableView.information.text = currentPet.name! + ", " + currentPet.gender!
        draggableView.information2.text = currentPet.city!

        draggableView.delegate = self

        
        
        return draggableView
    }

    func loadCards() -> Void {
        if pets.count > 0 {
            let numLoadedCardsCap = pets.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : pets.count
            for i in 0 ..< pets.count {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
                newCard.addGestureRecognizer(tap)
                newCard.isUserInteractionEnabled = true
                
                let tapOut = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOut(sender:)))
                self.addGestureRecognizer(tapOut)
                self.isUserInteractionEnabled = true

                
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }

            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }
    
    func handleTapOut(sender: UITapGestureRecognizer? = nil) {
        print("tap out")
        dismiss()
    }

    
    func handleTapBack(sender: UITapGestureRecognizer? = nil) {
        
        UIView.transition(from: detailView, to: loadedCards[0], duration: 0.5, options: .transitionFlipFromLeft, completion: { _ in })
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        
        if let desc = loadedCards[0].pet.information {
            detailTextView.text = desc
        } else{
            detailTextView.text = "No description provided!"
        }
        UIView.transition(from: loadedCards[0], to: detailView, duration: 0.5, options: .transitionFlipFromRight, completion: { _ in })

        
//        if let topController = UIApplication.topViewController() {
//            let name = loadedCards[0].pet.name!
//
//            
//            if let desc = loadedCards[0].pet.information {
//                let alertController = UIAlertController(title: "\(name)", message: "\(desc)", preferredStyle: UIAlertControllerStyle.alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                    (result : UIAlertAction) -> Void in
//                }
//                alertController.addAction(okAction)
//                topController.present(alertController, animated: true, completion: nil)
//
//                
//            } else{
//                let alertController = UIAlertController(title: "\(name)", message: "No description provided!", preferredStyle: UIAlertControllerStyle.alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                    (result : UIAlertAction) -> Void in
//                }
//                alertController.addAction(okAction)
//                topController.present(alertController, animated: true, completion: nil)
//            }
//        }
    }

    func cardSwipedLeft(_ card: UIView) -> Void {
        if loadedCards.count <= 1 {
            dismiss()
            return
        }
        currentPet = loadedCards[1].pet
        loadedCards.remove(at: 0)
    
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    func save(tag: String, name: String, email: String, photoURL: String, info: String, gender: String, phone: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "PetCD",
                                       in: managedContext)!
        
        let pet = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        pet.setValue(tag, forKeyPath: "tag")
        pet.setValue(name, forKeyPath: "name")
        pet.setValue(email, forKeyPath: "email")
        pet.setValue(photoURL, forKeyPath: "photoURL")
        pet.setValue(info, forKeyPath: "info")
        pet.setValue(gender, forKeyPath: "gender")
        pet.setValue(phone, forKey: "phone")

        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    // todo: add to core data
    func cardSwipedRight(_ card: UIView) -> Void {
        if loadedCards.count <= 1 {
            dismiss()
            return
        }
        currentPet = loadedCards[1].pet
        
        
        //save or send email of interest
        print(loadedCards[0].pet.name ?? "pet")
        
        let tag = loadedCards[0].pet.tag!
        let email = loadedCards[0].pet.email!
        let name = loadedCards[0].pet.name!
        let photoURL = loadedCards[0].pet.photoURL!
        let info = loadedCards[0].pet.information ?? "No Description Provided!"
        let gender = loadedCards[0].pet.gender!
        let phone = loadedCards[0].pet.phone ?? ""
        
        self.loadedCards.remove(at: 0)

        
        //save
        self.save(tag: tag, name: name, email: email, photoURL: photoURL, info: info, gender: gender, phone: phone)

        
        //if first time swiping right then show confetti and match
        let first = UserDefaults.standard.value(forKey: "first") as? Bool
        
        if(first == nil || first == false){
            if let topController = UIApplication.topViewController() {
                
                let confettiView = SAConfettiView(frame: topController.view.bounds)
                topController.view.addSubview(confettiView)
                confettiView.startConfetti()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    confettiView.stopConfetti()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        confettiView.removeFromSuperview()
                        
                    })
                })
                
                let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
                let alert = SCLAlertView(appearance: appearance)
                let icon = UIImage(named:"paw")
                let color = UIColor.orange
                
                _ = alert.showCustom("It's a Match🐱🐶!", subTitle: "Find \(name) and other pets you swipe right on in your Likes!", color: color, icon: icon!)
                
                /*
                
                let alertController = UIAlertController(title: "It's a Match🐱🐶!", message: "Find \(name) and other pets you swipe right on in your Likes!", preferredStyle: UIAlertControllerStyle.alert)

                
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                
                
                alertController.addAction(cancelAction)
                topController.present(alertController, animated: true, completion: nil)
 
                 */
                
            }
        }
        
        UserDefaults.standard.set(true, forKey: "first")
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

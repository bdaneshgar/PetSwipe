//
//  ViewController.swift
//  PetSwipe
//
//  Created by Brian Daneshgar on 2/15/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData
import SCLAlertView


protocol ParentProtocol{
    
    func removeOverlay()
}

class ViewController: UIViewController, CLLocationManagerDelegate, AKPickerViewDataSource, AKPickerViewDelegate {
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var overlay = UIView()
    
    @IBOutlet var pickerView: AKPickerView!
    let titles = ["All", "Dogs", "Cats"]
    var suffix = ""
    
    @IBOutlet var map: MKMapView!
    let manager = CLLocationManager()
    var start: UIButton!
    
    var draggableBackground: DraggableViewBackground!

    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else{
            enableLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
        map.isUserInteractionEnabled = false

        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                UserDefaults.standard.set(pm.postalCode, forKey: "zip")
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        self.startStartBtn()
    }
    
    func startStartBtn(){
        start.isUserInteractionEnabled = true
        //animate to orange color
        
        UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: {

            self.start.backgroundColor = .orange
        
        }, completion: nil)
    }
    
    func enableLocation(){
        let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
        let alert = SCLAlertView(appearance: appearance)
        let icon = UIImage(named:"paw")
        let color = UIColor.orange
        
        _ = alert.showCustom("Please enable location services to find nearby pets!", subTitle: "Enable in Settings > PetSwipe > Location.", color: color, icon: icon!)
        
        /*
        
        
        
        
        let alertController = UIAlertController(title: "Please enable location services to find nearby pets!", message: "Enable in Settings > PetSwipe > Location.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
 
         */
    }
    
    func checkConnection(){
        
        let appearance =  SCLAlertView.SCLAppearance( kCircleIconHeight: 55.0, showCircularIcon: true )
        let alert = SCLAlertView(appearance: appearance)
        let icon = UIImage(named:"paw")
        let color = UIColor.orange
        
        _ = alert.showCustom("Oops!", subTitle: "Something went wrong. Please check your connection and try again.", color: color, icon: icon!)
        
        /*
        let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
         */
    }
    
    func setOverlay(){
        self.view.addSubview(overlay)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        overlay.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 0.6)
        
        UserDefaults.standard.set(false, forKey: "first")
        UserDefaults.standard.set(suffix, forKey: "suffix")

        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "HelveticaNeue", size: 20)!
        self.pickerView.backgroundColor = .orange
        self.pickerView.alpha = 0.6
        self.pickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.pickerView.pickerViewStyle = .wheel
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()

        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        map.isUserInteractionEnabled = false
        
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            menuButton.tintColor = UIColor.white
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            navigationController?.navigationBar.barTintColor = UIColor.orange
            self.title = "PetSwipe"
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lobster-Regular", size: 24)!,  NSForegroundColorAttributeName: UIColor.white]
        }
        



        
        start = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 100, width: self.view.frame.size.width, height: 100))
        start.backgroundColor = .lightGray
        start.alpha = 0.6
        start.setTitle("SEARCH", for: .normal)
        start.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 50.0)
        start.setTitleColor(UIColor.white, for: .normal)
        start.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        start.isUserInteractionEnabled = false
        
        self.view.addSubview(start)
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)

    }
    
    func buttonAction(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
                enableLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                
                if(UserDefaults.standard.value(forKey: "zip") != nil){
                    setOverlay()
                    
                    draggableBackground = DraggableViewBackground(frame: self.view.frame)
                    
                    draggableBackground.delegate = self
                    
                    self.view.addSubview(draggableBackground)
                } else{
                    checkConnection()
                }
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func appMovedToBackground() {
        print("App moved to background!")
        if(draggableBackground != nil){
            draggableBackground.dismiss()
        }
    }
    
    
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.titles.count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.titles[item]
    }
    
    
    // MARK: - AKPickerViewDelegate
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        let selected = self.titles[item].lowercased()
        
        if(selected == "all"){
            suffix = ""
        }
        if(selected == "dogs"){
            suffix = "&animal=dog"
        }
        if(selected == "cats"){
            suffix = "&animal=cat"
        }
        
        UserDefaults.standard.set(suffix, forKey: "suffix")

        
        print("suffix: \(suffix)")
    }
    
    

    
}

extension ViewController : ParentProtocol {
    func removeOverlay(){
        overlay.removeFromSuperview()
    }
}

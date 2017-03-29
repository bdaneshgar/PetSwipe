//
//  Pet.swift
//  PetSwipe
//
//  Created by Brian Daneshgar on 2/18/17.
//  Copyright © 2017 Brian Daneshgar. All rights reserved.
//

import UIKit

class Pet: NSObject {
    
    var tag: String?
    var photoURL: String?
    var name: String?
    var age: String?
    var gender: String?
    var city: String?
    var email: String?
    var information: String?
    var phone: String?

    init(tag: String,
         photoURL: String,
         name: String,
         age: String,
         gender: String,
         city: String,
         email: String,
         description: String,
         phone: String) {
        
        self.tag = tag
        self.photoURL = photoURL
        self.name = name
        self.age = age
        self.gender = gender
        self.city = city
        self.email = email
        self.information = description
        self.phone = phone
    }
    
    override init(){
        
    }
}

//
//  User.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

class User {
    
    private var id:String
    private var email:String
    private var pass:String
    private var firstName:String
    private var lastName:String
    private var dob:String
    private var gender:String
    private var numOfRelIds:String
    private var relIds:[String]
    
    init(id:String, email:String, pass:String, firstName:String, lastName:String, gender:String, dob:String, numOfRelIds:String, relIds:[String]) {
        self.id = id
        self.email = email
        self.pass = pass
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.dob = dob
        self.numOfRelIds = numOfRelIds
        self.relIds = relIds
        
        print("User: "+firstName+" "+lastName+" "+id)
    }
    
    func getRelIds() -> [String] {
        return relIds
    }
    
    func getNumOfRelIds() -> String {
        return numOfRelIds
    }
    
    func getId() -> String {
        return id
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func getGender() -> Int {
        return Int(gender)!
    }
    
    func getDob() -> Int {
        return Int(dob)!
    }
    
}

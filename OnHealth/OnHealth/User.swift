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
    
    init(id:String, email:String, pass:String, firstName:String, lastName:String) {
        self.id = id
        self.email = email
        self.pass = pass
        self.firstName = firstName
        self.lastName = lastName
        
        print("User: "+firstName+" "+lastName+" "+id)
        
        if let care = self as? CareTaker {
            print(care.getPatientTestData(care.getPatientIds[0]))
        }
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
    
}

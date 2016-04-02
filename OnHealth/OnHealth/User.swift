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
    private var pastTests:[TestData] = []
    
    init(id:String, email:String, pass:String, firstName:String, lastName:String, pastTests:[TestData]) {
        self.id = id
        self.email = email
        self.pass = pass
        self.firstName = firstName
        self.lastName = lastName
        self.pastTests = pastTests
    }
    
    func convToDict() -> [String:AnyObject] {
        return [
            "firstName" : firstName,
            "lastName" : lastName,
            "pastTests" : pastTests
        ]
    }
    
    func setPastTests(pastTests:[TestData]) {
        self.pastTests = pastTests
    }
    
    func getPastTests() -> [TestData] {
        return pastTests
    }
    
}

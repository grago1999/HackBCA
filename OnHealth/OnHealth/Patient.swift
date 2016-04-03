//
//  Patient.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class Patient: User {
    
    private var numOfTests:Int = 0
    private var pastTests:[TestData] = []
    
    func updatePatientAfterNewTest(newTest:TestData) {
        pastTests.append(newTest)
        numOfTests+=1
        let userDict = [
            "type" : "0",
            "numOfTests" : String(numOfTests),
            "numOfRelIds" : String(self.getNumOfRelIds()),
            "firstName" : self.getFirstName(),
            "lastName" : self.getLastName(),
            "dob" : String(self.getDob()),
            "gender" : String(self.getGender())
        ]
        UserHandler.updateUser(userDict, id:self.getId())
    }
    
    func setNumOfTests(numOfTests:Int) {
        self.numOfTests = numOfTests
    }
    
    func getNumOfPastTests() -> Int {
        return numOfTests
    }
    
    func setPastTests(pastTests:[TestData]) {
        self.pastTests = pastTests
    }
    
    func getPastTests() -> [TestData] {
        return pastTests
    }
    
}
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
    private var careTakerIds:[String] = []
    
    func updatePatientAfterNewTest(newTest:TestData) {
        pastTests.append(newTest)
        numOfTests+=1
        let userDict = [
            "type" : "0",
            "numOfTests" : String(numOfTests),
            "firstName" : self.getFirstName(),
            "lastName" : self.getLastName()
        ]
        UserHandler.updateUser(userDict, id:self.getId())
    }
    
    func setCareTakerIds(careTakerIds:[String]) {
        self.careTakerIds = careTakerIds
    }
    
    func getCareTakerIds() -> [String] {
        return careTakerIds
    }
    
    func setNumOfTests(numOfTests:Int) {
        self.numOfTests = numOfTests
    }
    
    func setPastTests(pastTests:[TestData]) {
        self.pastTests = pastTests
    }
    
    func getPastTests() -> [TestData] {
        return pastTests
    }
    
}

/*
 let date = NSDate()
 let timestamp = Int(date.timeIntervalSince1970*1000)
 let tempTest = TestData(score:9, date:timestamp, type:1)
 if let patient = currentUser as? Patient {
 patient.updatePatientAfterNewTest(tempTest)
 }
 */
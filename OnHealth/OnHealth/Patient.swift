//
//  Patient.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class Patient: User {
    
    private var pastTests:[TestData] = []
    private var careTakerIds:[String] = []
    
    func updatePatientAfterNewTest(newTest:TestData) {
        var newPastTests:[[String:Int]] = []
        if self.getPastTests().count >= 0 {
            for previousTest in self.getPastTests() {
                let previousTestDict = [
                    "score" : previousTest.getScore(),
                    "date" : previousTest.getDate(),
                    "type" : previousTest.getType()
                ]
                newPastTests.append(previousTestDict)
            }
        }
        
        let newTestDict = [
            "score" : newTest.getScore(),
            "date" : newTest.getDate(),
            "type" : newTest.getType()
        ]
        newPastTests.append(newTestDict)
        let userDict = [
            "pastTests" : newPastTests,
            "careTakerIds" : self.getCareTakerIds()
        ]
        UserHandler.updateUser(userDict as! [String : AnyObject], id:self.getId())
    }
    
    func setCareTakerIds(careTakerIds:[String]) {
        self.careTakerIds = careTakerIds
    }
    
    func getCareTakerIds() -> [String] {
        return careTakerIds
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
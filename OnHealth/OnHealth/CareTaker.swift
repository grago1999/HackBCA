//
//  CareTaker.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class CareTaker: User {
    
    func getPatientTestData(patientId:String) {
        var tempTestDatas:[TestData] = []
        UserHandler.getUserRef(patientId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value != nil {
                let numOfTestsStr = snapshot.value.objectForKey("numOfTests") as! String
                let numOfTests:Int? = Int(numOfTestsStr)
                if numOfTests! > 0 {
                    for testId in 0...(numOfTests!-1) {
                        UserHandler.getPastTestRef(patientId, testId:testId).observeSingleEventOfType(.Value, withBlock: { snapshot in
                            let testData = TestData(score:snapshot.value.objectForKey("score") as! Int, date:snapshot.value.objectForKey("date") as! Int, type:snapshot.value.objectForKey("type") as! Int)
                            tempTestDatas.append(testData)
                        }, withCancelBlock: { error in
                            print(error.description)
                        })
                    }
                }
            }
        }, withCancelBlock: { error in
            print(error.description)
        })
    }
    
}

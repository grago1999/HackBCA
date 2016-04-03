//
//  CareTaker.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class CareTaker: User {
    
    private var patientIds:[String] = ["25e2d7b3-27c6-48d7-90b5-cc80d7e76d9d"]
    
    func getPatientTestData(patientId:String) {//-> [TestData] {
        UserHandler.getUserRef(patientId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let numOfTestsStr = snapshot.value.objectForKey("numOfTests") as! String
            let numOfTests:Int? = Int(numOfTestsStr)
            for testId in 0...(numOfTests!) {
                UserHandler.getPastTestRef(patientId, testId:testId).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    print(snapshot.value)
                }, withCancelBlock: { error in
                    print(error.description)
                })
            }
        }, withCancelBlock: { error in
            print(error.description)
        })
    }
    
    func getPatientIds() -> [String] {
        return patientIds
    }
    
}

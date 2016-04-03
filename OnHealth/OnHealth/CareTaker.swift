//
//  CareTaker.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class CareTaker: User {
    
    private var patientIds:[String] = ["792142c1-a13b-4f9e-ab17-d11a0621554c"]
    
    func getPatientTestData(patientId:String) {//-> [TestData] {
        UserHandler.getUserRef(patientId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("==========")
            print(snapshot.value)
        }, withCancelBlock: { error in
            print(error.description)
        })
    }
    
    func getPatientIds() -> [String] {
        return patientIds
    }
    
}

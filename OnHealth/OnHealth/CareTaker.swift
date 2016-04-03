//
//  CareTaker.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class CareTaker: User {
    
    private var patientIds:[String] = []
    
    func getPatientTestData(patientId:String) {//-> [TestData] {
        UserHandler.getUserRef(patientId).observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value.objectForKey("TestData"))
        }, withCancelBlock: { error in
            print(error.description)
        })
    }
    
}

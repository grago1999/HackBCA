//
//  UserHandler.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class UserHandler {
    
    static let ref = Firebase(url:"https://hackbca-health.firebaseio.com")
    static var currentUser:User?
    
    static func attemptLogin(email:String, pass:String) {
        ref.authUser(email, password:pass) {
            error, authData in
            if error != nil {
                print("Error logging in")
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .UserDoesNotExist:
                        print("Handle invalid user")
                    case .InvalidEmail:
                        print("Handle invalid email")
                    case .InvalidPassword:
                        print("Handle invalid password")
                    default:
                        print("Handle default situation")
                    }
                }
            } else {
                print("Logged in")
                let date = NSDate()
                let timestamp = Int(date.timeIntervalSince1970*1000)
                let tempTest = TestData(score:1, date:timestamp, type:1)
                UserHandler.updateUserAfterTest(tempTest)
            }
        }
    }
    
    static func registerUser(email:String, pass:String) {
        ref.createUser(email, password:pass, withValueCompletionBlock: { error, result in
            if error != nil {
                print("Account was unable to be created.")
            } else {
                let uid = result["uid"] as? String
                print("Successfully created user account with uid: \(uid)")
                self.attemptLogin(email, pass:pass)
            }
        })
    }
    
    static func updateUserAfterTest(newTest:TestData) {
        var newPastTests:[[String:Int]] = []
        if currentUser?.getPastTests().count >= 0 {
            for previousTest in (currentUser?.getPastTests())! {
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
            "pastTests" : newPastTests
        ]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            ref.childByAppendingPath("users").childByAppendingPath(ref.authData.uid).setValue(userDict)
            print("Updated user")
        })
    }
    
}

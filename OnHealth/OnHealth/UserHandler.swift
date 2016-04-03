//
//  UserHandler.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class UserHandler {
    
    static let urlStr = "https://hackbca-health.firebaseio.com"
    static let ref = Firebase(url:urlStr)
    static var currentUser:User?
    static var isRegistering = false
    
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
                let userRef = Firebase(url:"\(urlStr)/users/\(authData.uid)")
                var firstName:String = ""
                var lastName:String = ""
                userRef.observeEventType(.Value, withBlock: { snapshot in
                    firstName = snapshot.value.objectForKey("firstName") as! String
                    lastName = snapshot.value.objectForKey("lastName") as! String
                }, withCancelBlock: { error in
                    print(error.description)
                })
                currentUser = User(id:authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName)
                let date = NSDate()
                let timestamp = Int(date.timeIntervalSince1970*1000)
                let tempTest = TestData(score:9, date:timestamp, type:1)
                if let patient = currentUser as? Patient {
                    patient.updatePatientAfterNewTest(tempTest)
                }
            }
        }
    }
    
    static func registerUser(email:String, pass:String, firstName:String, lastName:String) {
        isRegistering = true
        ref.createUser(email, password:pass, withValueCompletionBlock: { error, result in
            if error != nil {
                print("Account was unable to be created")
            } else {
                let uid = result["uid"] as? String
                print("Successfully created user account with uid: \(uid)")
                let userDict = [
                    "firstName" : firstName,
                    "lastName" : lastName
                ]
                updateUser(userDict, id:uid!)
                self.attemptLogin(email, pass:pass)
            }
        })
    }
    
    static func updateUser(userDict:[String:AnyObject], id:String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let userRef = Firebase(url:"\(urlStr)/users/\(id)")
            userRef.childByAppendingPath("users").childByAppendingPath(ref.authData.uid).setValue(userDict)
            print("Updated user")
        })
    }
    
}

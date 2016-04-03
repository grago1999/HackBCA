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
                var type:String = ""
                var firstName:String = ""
                var lastName:String = ""
                getUserRef(authData.uid).observeEventType(.Value, withBlock: { snapshot in
                    if let user = currentUser {
                        firstName = user.getFirstName()
                        lastName = user.getLastName()
                    } else {
                        type = snapshot.value.objectForKey("type") as! String
                        firstName = snapshot.value.objectForKey("firstName") as! String
                        lastName = snapshot.value.objectForKey("lastName") as! String
                    }
                }, withCancelBlock: { error in
                    print(error.description)
                })
                if type == "0" {
                    currentUser = Patient(id:authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName)
                } else {
                    currentUser = CareTaker(id:authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName)
                }
            }
        }
    }
    
    static func registerUser(email:String, pass:String, firstName:String, lastName:String, type:Int) {
        ref.createUser(email, password:pass, withValueCompletionBlock: { error, result in
            if error != nil {
                print("Account was unable to be created")
            } else {
                let uid = result["uid"] as? String
                print("Successfully created user account with uid: \(uid)")
                let userDict = [
                    "type" : String(type),
                    "firstName" : firstName,
                    "lastName" : lastName
                ]
                currentUser = User(id:uid!, email:email, pass:pass, firstName:firstName, lastName:lastName)
                updateUser(userDict, id:uid!)
                self.attemptLogin(email, pass:pass)
            }
        })
    }
    
    static func updateUser(userDict:[String:AnyObject], id:String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            ref.childByAppendingPath("users").childByAppendingPath(ref.authData.uid).setValue(userDict)
            print("Updated user")
        })
    }
    
    static func getUserRef(id:String) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)")
    }
    
}

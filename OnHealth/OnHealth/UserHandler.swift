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
    static var hasSetUser = false
    
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
                var numOfRelIds:String = ""
                var relIds:[String] = []
                getUserRef(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if hasSetUser {
                        firstName = (currentUser?.getFirstName())!
                        lastName = (currentUser?.getLastName())!
                        numOfRelIds = "0"
                        continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                    } else {
                        type = snapshot.value.objectForKey("type") as! String
                        firstName = snapshot.value.objectForKey("firstName") as! String
                        lastName = snapshot.value.objectForKey("lastName") as! String
                        numOfRelIds = snapshot.value.objectForKey("numOfRelIds") as! String
                        if numOfRelIds != "0" {
                            for i in 0...(Int(numOfRelIds)!-1) {
                                UserHandler.getRelId(authData.uid, index:i).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                    relIds.append(snapshot.value.objectForKey("relId") as! String)
                                    continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                                }, withCancelBlock: { error in
                                    print(error.description)
                                })
                            }
                        } else {
                            continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                        }
                    }
                }, withCancelBlock: { error in
                    print(error.description)
                })
            }
        }
    }
    
    static func continueUserSetup(id:String, email:String, pass:String, firstName:String, lastName:String, numOfRelIds:String, relIds:[String], type:String) {
        hasSetUser = true
        if type == "0" {
            currentUser = Patient(id:id, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:numOfRelIds, relIds:relIds)
            UserHandler.getUserRef(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let patient = currentUser as? Patient {
                    let numOfTestsStr = snapshot.value.objectForKey("numOfTests") as! String
                    let numOfTests:Int? = Int(numOfTestsStr)
                    patient.setNumOfTests(numOfTests!)
                }
            }, withCancelBlock: { error in
                print(error.description)
            })
        } else {
            currentUser = CareTaker(id:id, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:numOfRelIds, relIds:relIds)
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
                    "numOfTests" : "0",
                    "numOfRelIds" : "0",
                    "firstName" : firstName,
                    "lastName" : lastName
                ]
                currentUser = User(id:uid!, email:email, pass:pass, firstName:firstName, lastName:lastName, numOfRelIds:"0", relIds:[])
                hasSetUser = true
                updateUser(userDict, id:uid!)
                self.attemptLogin(email, pass:pass)
            }
        })
    }
    
    static func updateUser(userDict:[String:AnyObject], id:String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            getUserRef(id).setValue(userDict)
            if let patient = currentUser as? Patient {
                let newTestDict = [
                    "score" : (patient.getPastTests().last?.getScore())! as Int,
                    "date" : (patient.getPastTests().last?.getDate())! as Int,
                    "type" : (patient.getPastTests().last?.getType())! as Int
                ]
                setNewPastTestRef(id).setValue(newTestDict)
            }
            if let careTaker = currentUser as? CareTaker {
                
            }
            print("Updated user")
        })
    }
    
    static func getUserRef(id:String) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)")
    }
    
    static func setNewPastTestRef(id:String) -> Firebase {
        var testId:Int = 0
        if let patient = currentUser as? Patient {
            testId = patient.getPastTests().count-1
        }
        return Firebase(url:"\(urlStr)/users/\(id)/PastTests/\(testId))")
    }
    
    static func getPastTestRef(id:String, testId:Int) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)/PastTests/\(testId))")
    }
    
    static func getRelId(id:String, index:Int) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)/RelIds/\(index))")
    }
    
}

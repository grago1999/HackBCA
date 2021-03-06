//
//  UserHandler.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit
import Firebase
import SwiftRequest

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
                var gender:String = ""
                var dob:String = ""
                var relIds:[String] = []
                getUserRef(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if hasSetUser {
                        firstName = (currentUser?.getFirstName())!
                        lastName = (currentUser?.getLastName())!
                        numOfRelIds = "0"
                        continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                    } else {
                        type = snapshot.value.objectForKey("type") as! String
                        firstName = snapshot.value.objectForKey("firstName") as! String
                        lastName = snapshot.value.objectForKey("lastName") as! String
                        gender = snapshot.value.objectForKey("gender") as! String
                        dob = snapshot.value.objectForKey("dob") as! String
                        numOfRelIds = snapshot.value.objectForKey("numOfRelIds") as! String
                        if numOfRelIds != "0" && type == "1" {
                            for i in 0...(Int(numOfRelIds)!-1) {
                                UserHandler.getRelId(authData.uid, index:i).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                    relIds.append(snapshot.value.objectForKey("id") as! String)
                                    continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                                    }, withCancelBlock: { error in
                                        print(error.description)
                                })
                            }
                        } else {
                            continueUserSetup(authData.uid, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:relIds, type:type)
                        }
                    }
                }, withCancelBlock: { error in
                    print(error.description)
                })
            }
        }
    }
    
    static func continueUserSetup(id:String, email:String, pass:String, firstName:String, lastName:String, gender:String, dob:String, numOfRelIds:String, relIds:[String], type:String) {
        hasSetUser = true
        if type == "0" {
            currentUser = Patient(id:id, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:relIds)
            UserHandler.getUserRef(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let patient = currentUser as? Patient {
                    var testDatas:[TestData] = []
                    let numOfTestsStr = snapshot.value.objectForKey("numOfTests") as! String
                    let numOfTests:Int? = Int(numOfTestsStr)
                    patient.setNumOfTests(numOfTests!)
                    if patient.getNumOfPastTests() > 0 {
                        for testId in 0...patient.getNumOfPastTests()-1 {
                            UserHandler.getPastTestRef(id, testId:testId).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                let score = snapshot.value.objectForKey("score") as! Int
                                let date = snapshot.value.objectForKey("date") as! Int
                                let type = snapshot.value.objectForKey("type") as! Int
                                let testData = TestData(score:score, date:date, type:type)
                                testDatas.append(testData)
                                patient.setPastTests(testDatas)
                            }, withCancelBlock: { error in
                                print(error.description)
                            })
                        }
                    }
                }
                print(type)
            }, withCancelBlock: { error in
                print(error.description)
            })
        } else {
            currentUser = CareTaker(id:id, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:relIds)
        }
    }
    
    static func registerUser(email:String, pass:String, firstName:String, lastName:String, dob:Int, gender:Int, type:Int) {
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
                    "lastName" : lastName,
                    "gender" : String(gender),
                    "dob" : String(dob)
                ]
                currentUser = User(id:uid!, email:email, pass:pass, firstName:firstName, lastName:lastName, gender:String(gender), dob:String(dob), numOfRelIds:"0", relIds:[])
                hasSetUser = true
                getEmailId(alterEmail(email)).setValue(["id" : uid!])
                updateUser(userDict, id:uid!)
                self.attemptLogin(email, pass:pass)
            }
        })
    }
    
    static func updateUser(userDict:[String:AnyObject], id:String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            getUserRef(id).setValue(userDict)
            if let patient = currentUser as? Patient {
                var testArray: [[String : Int]] = []
                for i in 0..<patient.getPastTests().count {
                    let testDict = [
                        "score" : patient.getPastTests()[i].getScore() as Int,
                        "date" : patient.getPastTests()[i].getDate() as Int,
                        "type" : patient.getPastTests()[i].getType() as Int
                    ]
                    testArray.append(testDict)
                }
                getUserRef(id).childByAppendingPath("PastTests").setValue(testArray)
            }
            print("Updated user")
        })
    }
    
    static func getPatientInfo(id:String) {
        UserHandler.getUserRef(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let firstName = snapshot.value.objectForKey("firstName") as! String
            let lastName = snapshot.value.objectForKey("lastName") as! String
            let numOfRelIds = snapshot.value.objectForKey("numOfRelIds") as! String
            let numOfTests = snapshot.value.objectForKey("numOfTests") as! String
            let gender = snapshot.value.objectForKey("gender") as! String
            let dob = snapshot.value.objectForKey("dob") as! String
            let patient = Patient(id:id, email:"", pass:"", firstName:firstName, lastName:lastName, gender:gender, dob:dob, numOfRelIds:numOfRelIds, relIds:[])
            patient.setNumOfTests(Int(numOfTests)!)
            var testDatas:[TestData] = []
            for testId in 0...patient.getNumOfPastTests() {
                getPastTestRef(id, testId:testId).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let score = snapshot.value.objectForKey("score") as! Int
                    let date = snapshot.value.objectForKey("date") as! Int
                    let type = snapshot.value.objectForKey("type") as! Int
                    let testData = TestData(score:score, date:date, type:type)
                    testDatas.append(testData)
                    patient.setPastTests(testDatas)
                }, withCancelBlock: { error in
                    print(error.description)
                })
            }
        }, withCancelBlock: { error in
            print(error.description)
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
        return Firebase(url:"\(urlStr)/users/\(id)/PastTests/\(testId)")
    }
    
    static func getPastTestRef(id:String, testId:Int) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)/PastTests/\(testId)")
    }
    
    static func getRelId(id:String, index:Int) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)/RelIds/\(index)")
    }
    
    static func setNewRelId(id:String, index:Int) -> Firebase {
        return Firebase(url:"\(urlStr)/users/\(id)/RelIds/\(index)")
    }
    
    static func getEmailId(email:String) -> Firebase {
        return Firebase(url:"\(urlStr)/emails/\(email)")
    }
    
    static func addRelIdByEmail(email:String) {
        UserHandler.getEmailId(email).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let id = snapshot.value.objectForKey("id") as! String
            UserHandler.getUserRef(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
                let numOfRelIdsStr = snapshot.value.objectForKey("numOfRelIds") as! String
                let relDict = ["id" : (currentUser?.getId())! as String]
                let userDict = [
                    "firstName" : snapshot.value.objectForKey("firstName") as! String,
                    "lastName" : snapshot.value.objectForKey("lastName") as! String,
                    "numOfRelIds" : String(Int(numOfRelIdsStr)!+1) as String,
                    "numOfTests" : snapshot.value.objectForKey("lastName") as! String,
                    "type" : snapshot.value.objectForKey("type") as! String,
                    "dob" : snapshot.value.objectForKey("dob") as! String,
                    "gender" : snapshot.value.objectForKey("gender") as! String
                ]
                setNewRelId(id, index:Int(numOfRelIdsStr)!+1).setValue(relDict)
                setNewRelId((currentUser?.getId())!, index:Int((currentUser?.getNumOfRelIds())!)!)
                getUserRef(id).setValue(userDict)
            }, withCancelBlock: { error in
                print(error.description)
            })
        }, withCancelBlock: { error in
            print(error.description)
        })
    }
    
    static func alterEmail(email:String) -> String {
        var searchEmail = email.stringByReplacingOccurrencesOfString("@", withString: " ", options:NSStringCompareOptions.LiteralSearch, range:nil)
        searchEmail = searchEmail.stringByReplacingOccurrencesOfString(".", withString: " ", options:NSStringCompareOptions.LiteralSearch, range:nil)
        return searchEmail
    }
    
    static func sendTwillioAlert(toPhone:String) {
        let swiftRequest = SwiftRequest();
        
        let data = [
            "To" : toPhone,
            "From" : "+16094512077",
            "Body" : "Hello World"
        ];
        
        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/SK0d8575b1db7cc3f7fedf784dc6e9d922/Messages",
            auth: ["username" : "M3xiBJcE8G8U1tAcL0gVeHc6XRnWQRIm", "password" : "6ec5035e600ce0ccc596b98b94baeb02"],
            data: data,
            callback: {err, response, body in
                if err == nil {
                    print("Success: \(response)")
                } else {
                    print("Error: \(err)")
                }
        });
    }
    
}

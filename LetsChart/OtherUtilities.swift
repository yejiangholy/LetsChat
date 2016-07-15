//
//  OtherUtilities.swift
//  LetsChart
//
//  Created by JiangYe on 7/1/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

func TimeElipsed(seconds: NSTimeInterval) -> String {
    let elapsed: String?
    
    if seconds < 60 {
        elapsed = "Just Now"
    } else if (seconds < 60 * 60){
        let minutes = Int(seconds / 60)
        var minText = "min"
        if minutes > 1 {
            minText = "mins"
        }
        elapsed = "\(minutes) \(minText)"
    }else if (seconds < 24 * 60 * 60){
        let hours = Int(seconds / (60 * 60))
        var hourText = "hour"
        if hours > 1 {
            hourText = "hours"
        }
        elapsed = "\(hours) \(hourText)"
    } else {
        let days = Int(seconds / (24 * 60 * 60))
        var dayText = "day"
        if days > 1 {
            dayText = "days"
        }
        elapsed = "\(days) \(dayText)"
    }
    return elapsed!
}


func isValidEmail(input: String) -> Bool {
    
    let emailRegExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegExpression)
    
    return emailTest.evaluateWithObject(input) 
}

func emailHasBeenRegistered(email: String, result: (result: Bool) -> Void)
{
    
    let whereClause = "email = '\(email)'"
    let dataQuery = BackendlessDataQuery()
    dataQuery.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    dataStore.find(dataQuery, response: {(users:BackendlessCollection!)-> Void in
        
        if (users.data.first as? BackendlessUser) != nil {
            
            result(result: true)
            
        } else {
            
            result(result: false)
        }
        
        
    }){(fault:Fault!)-> Void in
        
       result(result: true)
    }
}

func letThemBecomeFriends(user1Id: String,  user2Id: String, result: (result: Bool)-> Void)
{
    let whereClause = "objectId = '\(user1Id)' or objectId = '\(user2Id)'"
    let dataQuery = BackendlessDataQuery()
    dataQuery.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    
    dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
        let user1 = users.data[0] as! BackendlessUser
        let user2 = users.data[1] as! BackendlessUser
        
        let user1FriendsList = user1.getProperty("FriendsList")
        let user2FriendsList = user2.getProperty("FriendsList")
        var updatedList1 : String
        var updatedList2 : String
        
        if  let user1currentFriends = user1FriendsList as? String{
            
            if !(user1currentFriends.containsString(user2.objectId)){
                updatedList1 = user1currentFriends.stringByAppendingString(" \(user2.objectId)")
            } else {
                updatedList1 = user1currentFriends
            }
            
        } else{
            updatedList1 = (user2.objectId as String).stringByAppendingString(" ")
        }
        
        
        if  let user2currentFriends = user2FriendsList as? String{
            
            if !(user2currentFriends.containsString(user1.objectId)){
                updatedList2 = user2currentFriends.stringByAppendingString(" \(user1.objectId)")
            } else {
                updatedList2 = user2currentFriends
            }
            
        } else{
            updatedList2 = (user1.objectId as String).stringByAppendingString(" ")
        }
        
        let property1 = ["FriendsList" : updatedList1]
        let property2 = ["FriendsList" : updatedList2]
        
        user1.updateProperties(property1)
        user2.updateProperties(property2)
        backendless.userService.update(user1)
        backendless.userService.update(user2)
        result(result: true)
        
    }) { (fault : Fault!) in
        result(result: false)
        print("Server error when adding friend:\(fault)")
    }
}

//
//  Notification.swift
//  LetsChart
//
//  Created by JiangYe on 7/6/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation



func sendRequestNotification(requester: BackendlessUser, friend: BackendlessUser)
{
    
    let requesterId = requester.objectId
    let friendId = friend.objectId
    
   let notificationId = requesterId.stringByAppendingString(friendId)
    
 
    CreateRequestNotification(requesterId, friendId: friendId, notificationId: notificationId, requesterName: requester.name, friendName: friend.name, type: "Request") { (result) in
        
        if result == true {
            PushRequestNotification(requester, friend: friend)
        }
    }
}


func CreateRequestNotification( requesterId: String, friendId: String , notificationId: String, requesterName: String , friendName: String , type : String, result: (result: Bool)-> Void ){
    firebase.child("Notification").queryOrderedByChild("notificationId").queryEqualToValue(notificationId).observeSingleEventOfType(.Value, withBlock: { snapshot in
        var create = true
        
        //check if we have a result
        if snapshot.exists(){
            for notification in snapshot.value!.allValues{
                if notification["type"] as! String == "Request"{
                    create = false
                    result(result: false)
                }
            }
        }
        if create {
            // go ahead and crete it ! ( with type) 
            let date = dataFormatter().stringFromDate(NSDate())
            let ref = firebase.child("Notification").childByAutoId()
            let autoId = ref.key
            
            let notification = ["autoId": autoId , "notificationId" : notificationId ,"requesterId" : requesterId , "friendId" : friendId , "requesterName" : requesterName , "friendName" : friendName, "type" : type, "date": date]
            
            ref.setValue(notification)
             result(result: true)
        }
    })
}

func SendConfirmation(notification: NSDictionary)
{
    
    let date = dataFormatter().stringFromDate(NSDate())
    let ref = firebase.child("Confirmation").childByAutoId()
    let autoId = ref.key
    let confirmationId = notification["notificationId"] as! String
    let requesterId = notification["requesterId"] as! String
    let requesterName = notification["requesterName"] as! String
    let friendId = notification["friendId"] as! String
    let friendName =  notification["friendName"] as! String
    let type = "Confirmation"
    
    let confirmation = ["autoId": autoId , "confirmationId": confirmationId, "requesterId" : requesterId , "friendId" : friendId , "requesterName" : requesterName , "friendName" : friendName, "type" : type, "date": date]
    
    ref.setValue(confirmation)
    
    
    // sending confirm push notification 
    
    let whereClause = "objectId = '\(requesterId)'"
    
    let queryData = BackendlessDataQuery()
    
    queryData.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    
    dataStore.find(queryData, response: { (users) in
        
        let requester = users.data[0] as! BackendlessUser
        
     PushConfirmNotification(requester, friendName: friendName)
        
    }) { (fault: Fault!) in
        
        print("Error can not get from users table")
    }

}

func DeleteConfirmationItem(confirmation: NSDictionary)
{
    
    firebase.child("Confirmation").child((confirmation["autoId"] as? String)!).removeValueWithCompletionBlock { (error, ref) -> Void in
        if error != nil {
            print("Error deleting confirmation item: \(error)")
        }
    }
    
}


func DeleteNotificationItem(notification: NSDictionary)
{
    firebase.child("Notification").child((notification["autoId"] as? String)!).removeValueWithCompletionBlock { (error, ref) -> Void in
        if error != nil {
            print("Error deleting notification item: \(error)")
        }
    }
}

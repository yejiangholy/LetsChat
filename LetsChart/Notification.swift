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
    
 
    CreateRequestNotification(requesterId, friendId: friendId, notificationId: notificationId, requesterName: requester.name, friendName: friend.name, type: "Request")
    
}


func CreateRequestNotification( requesterId: String, friendId: String , notificationId: String, requesterName: String , friendName: String , type : String){
    firebase.child("Notification").queryOrderedByChild("notificationId").queryEqualToValue(notificationId).observeSingleEventOfType(.Value, withBlock: { snapshot in
        var create = true
        
        //check if we have a result
        if snapshot.exists(){
            for notification in snapshot.value!.allValues{
                if notification["type"] as! String == "Request"{
                    create = false
                    
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
        }
    })
}


func DeleteNotificationItem(notification: NSDictionary)
{
    firebase.child("Notification").child((notification["autoId"] as? String)!).removeValueWithCompletionBlock { (error, ref) -> Void in
        if error != nil {
            print("Error deleting notification item: \(error)")
        }
    }
}

//
//  PushNotifications.swift
//  LetsChart
//
//  Created by JiangYe on 6/21/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation


public func SendPushNotification(chatRoomID: String, message: String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value ,withBlock :{ snapshot in
        
        if snapshot.exists(){
            let recents = snapshot.value!.allValues
            let recent = recents[0]
            SendPushHelper((recent["members"] as? [String])!, message: message)
        }
    })
}
 


func SendPushHelper(members: [String], message: String)
{
    let message = backendless.userService.currentUser.name + ": " + message
    
    let withUserId = withUserIdFromArray(members)!
    
    let whereClause = "objectId = '\(withUserId)'"
    
    let queryData = BackendlessDataQuery()
    
    queryData.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
  
    dataStore.find(queryData, response: { (users) in
        
        let withUser = users.data[0] as! BackendlessUser
        
        SendPushMessage(withUser, message: message)
        
    }) { (fault: Fault!) in
        
        print("Error can not get from users table")
    }
}

func SendPushMessage(toUser: BackendlessUser , message: String)
{
    let deviceId = toUser.getProperty("deviceId") as! String
    
    let deliveryOptions = DeliveryOptions()
    
    deliveryOptions.pushSinglecast = [deviceId]
    
    deliveryOptions.pushPolicy(PUSH_ONLY)
    
    let publishOptions = PublishOptions()
   
    publishOptions.assignHeaders(["ios-alert" : "New message from \(backendless.userService.currentUser.name)", "ios-badge" : 1 , "ios-sound" : "default"])
    
    backendless.messagingService.publish("default", message: message, deliveryOptions: deliveryOptions)
}

func withUserIdFromArray(usersId: [String])-> String? {
    
    var id: String?
    
    for userId in usersId {
        
        if userId != backendless.userService.currentUser.objectId {
            id = userId
        }
    }
    return id
}

public func PushUserResign() {
    
// unregister user's device from push notification 
    
    backendless.messagingService.unregisterDeviceAsync({ (result) in
        
        print("unregistered device")
        
    }) { (fault : Fault!) in
        
        print("error could't unregister device :\(fault)")
    }
    
}

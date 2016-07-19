//
//  RegisterFBUser.swift
//  LetsChart
//
//  Created by JiangYe on 6/20/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

public func registerUserDeviceId() {
    
    if (backendless.messagingService.getRegistration().deviceId != nil) {
        
        let deviceId = backendless.messagingService.getRegistration().deviceId
        
        let properties = ["deviceId" : deviceId]
        
        backendless.userService.currentUser!.updateProperties(properties)
        backendless.userService.update(backendless.userService.currentUser)
    }
}


public func updateBackendlessUser(facebookId: String, avatarUrl: String){
    
    let properties : [String : String]!
    
    if backendless.messagingService.getRegistration().deviceId != nil {
        
   let deviceId = backendless.messagingService.getRegistration().deviceId
    
    properties = ["Avatar" : avatarUrl , "deviceId" : deviceId]
        
    } else {
        properties = ["Avatar" : avatarUrl]
    }
    
    backendless.userService.currentUser.updateProperties(properties)
    
    backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser: BackendlessUser!) in
        print("updated user is :\(updatedUser)")
        
    }) { (fault : Fault!) in
        print("Error could't update the devices id: \(fault)")
    }
 
    
    
    /*let whereClause = "facebookId = '\(facebookId)'"
    
    let dataQuery = BackendlessDataQuery()
    
    dataQuery.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    
    dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
        let user = users.data[0] as! BackendlessUser
        
        let proerties = ["Avatar" : avatarUrl]
        
        user.updateProperties(proerties)
        
        backendless.userService.update(user)
        
    }) { (fault: Fault!) in
        
        print("Server error :\(fault)")
    }*/
}


func removeDeviceIdFromUser(){
    
    let properties = ["deviceId" : ""]
    
    backendless.userService.currentUser!.updateProperties(properties)
    backendless.userService.update(backendless.userService.currentUser)
}



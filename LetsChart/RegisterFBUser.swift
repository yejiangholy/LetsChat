//
//  RegisterFBUser.swift
//  LetsChart
//
//  Created by JiangYe on 6/20/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

public func updateBackendlessUser(facebookId: String, avatarUrl: String){
    
    let whereClause = "facebookId = '\(facebookId)'"
    
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
    }
}

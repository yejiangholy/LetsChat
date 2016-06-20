//
//  Recent.swift
//  LetsChart
//
//  Created by JiangYe on 6/13/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

//--------Constants---------\\ 
public let KAVATARSTATE = "avatarState"
public let KFIRSTRUN = "firstRun"

//-----------------------\\

let firebase  =  Firebase(url: "https://letschart.firebaseio.com/")
let backendless = Backendless.sharedInstance()
let currentUser = backendless.userService.currentUser

//MARK: Create Chatroom 

func startChatId(user1:BackendlessUser , user2:BackendlessUser) -> String {
    //user 1 is current user 
    let userID1 = user1.objectId
    let userID2 = user2.objectId
    
    var chatRoomId : String = ""
    let value = userID1.compare(userID2).rawValue
    if value < 0 {
        chatRoomId = userID1.stringByAppendingString(userID2)
    }else {
        chatRoomId = userID2.stringByAppendingString(userID1)
    }
    
    let members :[String] = [userID1 , userID2]
    //create recent
    CreateRecent(userID1, ChatRoomId: chatRoomId, members: members, withUsername: user2.name!, withUseruserId: userID2)
    CreateRecent(userID2, ChatRoomId: chatRoomId, members: members, withUsername: user1.name!, withUseruserId: userID1)
    
    return chatRoomId
}

//MARK: Create RecentItem 

func CreateRecent(userId: String, ChatRoomId: String, members:[String] , withUsername: String, withUseruserId: String)
{
    
    firebase.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(ChatRoomId).observeSingleEventOfType(.Value, withBlock: { snapshot in
        var createRecent = true
        
        //check if we have a result
        if snapshot.exists(){
            for recent in snapshot.value.allValues{
                if recent["userId"] as! String == userId {
                    createRecent = false
                }
            }
        }
        if createRecent {
            
            CreateRecentItem(userId, chatRoomID: ChatRoomId, members: members, withUserName: withUsername, withUserId: withUseruserId)
        }
    })
}

func CreateRecentItem(userId:String , chatRoomID: String, members: [String], withUserName:String, withUserId:String)
{
    let ref = firebase.childByAppendingPath("Recent").childByAutoId()
    
    let recentId = ref.key
    
    let date = dataFormatter().stringFromDate(NSDate())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomID" : chatRoomID, "members": members, "withUsaerUsername" : withUserName , "lastMessage" :"", "counter": 0 , "date": date ,"withUserUserId": withUserId]
    
    //save to firebase 
    ref.setValue(recent) { (error, ref) -> Void in
        if error != nil{
            print("error creating recent \(error)")
        }
    }
}

//MARK: Update Recent 

func UpdateRecents(chatRoomID: String, lastMessage: String)
{
    //first query firebase get back two recents that need to be updated 
    firebase.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: { snapshot in
        
        if snapshot.exists(){
            for recent in snapshot.value.allValues{
                UpdateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
    })
    
}

func UpdateRecentItem(recent: NSDictionary, lastMessage: String )
{
    let date = dataFormatter().stringFromDate(NSDate())
    
    var counter = recent["counter"] as! Int
    
    if recent["userId"] as? String != currentUser.objectId{
        counter += 1
    }
    let values = ["lastMessage": lastMessage , "counter": counter , "date":date]
    
    firebase.childByAppendingPath("Recent").childByAppendingPath(recent["recentId"] as? String).updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: {(error, ref)->Void in
        if error != nil{
            print("Error could't update recent item")
        }
    })
    
}

//MARK: Restart Recent Chat 
func RestartRecentChat(recent:NSDictionary)
{
    for userId in recent["members"] as! [String]
    {
        if userId != currentUser.objectId{
            CreateRecent(userId, ChatRoomId: (recent["chatRoomID"] as? String)! , members: recent["members"] as! [String], withUsername: currentUser.name, withUseruserId: currentUser.objectId)
        }
    }
}

//MARK: Delete Recent function in firebase

func DeleteRecentItem(recent : NSDictionary)
{
    firebase.childByAppendingPath("Recent").childByAppendingPath(recent["recentId"] as? String).removeValueWithCompletionBlock { (error, ref) -> Void in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
}

//MARK: Clear recent counter function 

func ClearRecentCounter(chatRoomID: String)
{
    firebase.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) in
        
        if snapshot.exists(){
            for recent in snapshot.value.allValues{
                if recent.objectForKey("userId") as? String == currentUser.objectId {
                    
                    ClearRecentCounter((recent as? NSDictionary)!)
                }
            }
        }
        
    }
}

func ClearRecentCounter(recent: NSDictionary)
{
    firebase.childByAppendingPath("Recent").childByAppendingPath(recent["recentId"] as? String).updateChildValues(["counter" : 0]) { (error, ref) in
        if error != nil {
            print("Error could't update rencents counter: \(error.localizedDescription)")
        }
    }
}

//MARK: Helper golbal functions 

private let dateFormat = "yyyyMMddHHmmss"

func dataFormatter() -> NSDateFormatter{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}
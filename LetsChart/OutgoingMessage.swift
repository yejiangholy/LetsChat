//
//  OutgoingMessage.swift
//  LetsChart
//
//  Created by JiangYe on 6/16/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    
     let ref = firebase.child("Message")
    
    let messageDictionary : NSMutableDictionary

    
    init (message: String, senderId:String, senderName: String, date: NSDate, status: String, type:
        String)
    {
        messageDictionary = NSMutableDictionary(objects: [message,senderId,senderName, dataFormatter().stringFromDate(date),status,type], forKeys: ["message" , "senderId" , "senderName", "date" , "status", "type"])
    }
    init(message:String, latitude: NSNumber , longitude:NSNumber,senderId:String, senderName:String,date:NSDate,status:String, type: String) {
        
         messageDictionary = NSMutableDictionary(objects: [message,latitude, longitude, senderId,senderName, dataFormatter().stringFromDate(date),status,type], forKeys: ["message" , "latitude" , "longitude", "senderId" , "senderName", "date" , "status", "type"])
    }
    init (message: String, pictureData: NSData,  senderId:String, senderName: String, date: NSDate, status: String, type:
        String)
    {
        // convert picture to a stirng
        let pic  = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message,pic, senderId,senderName, dataFormatter().stringFromDate(date),status,type], forKeys: ["message" ,"picture", "senderId" , "senderName", "date" , "status", "type"])
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary)
    {
        let reference = ref.child(chatRoomID).childByAutoId()
        
        // add a key value pair to our item dictionary
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) ->Void in
            if error != nil {
                print("Error, could't send message \(error)")
            }
        }
        // send push notification
        
       // SendPushNotification(chatRoomID, message: (item["message"] as? String)!)
        
        // update recents here
       UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
    }
}


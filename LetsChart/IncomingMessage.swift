//
//  IncomingMessage.swift
//  LetsChart
//
//  Created by JiangYe on 6/16/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_ : JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        if type == "text"{
            //create text message
            
            message = createTextMessage(dictionary)
            
        }
        if type == "location" {
            
            message = createLocationMessage(dictionary)
            
        }
        if type == "picture"{
            
            message = createPictureMessage(dictionary)
        }
        
        return message
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dataFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
    func createLocationMessage(item:NSDictionary)-> JSQMessage{
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dataFormatter().dateFromString((item["date"] as? String)!)
        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        
        let mediaItem = JSQLocationMediaItem(location: nil)

        if userId == currentUser.objectId
        {
             mediaItem.appliesMediaViewMaskAsOutgoing = true
        }else {
            mediaItem.appliesMediaViewMaskAsOutgoing = false
        }
        

        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem.setLocation(location, withCompletionHandler: {
            // update collectionView
            
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId , senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    func createPictureMessage(item: NSDictionary)-> JSQMessage
    {
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dataFormatter().dateFromString((item["date"] as? String)!)

        
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem.appliesMediaViewMaskAsOutgoing = (userId == currentUser.objectId)
        
        imageFromString(item) { (image: UIImage?) -> Void in
            mediaItem.image = image
            
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func imageFromString(item: NSDictionary, result: (image: UIImage?)->Void)
    {
        var image: UIImage?
        
        let decodedData = NSData(base64EncodedString: (item["picture"] as? String)! , options:NSDataBase64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image: image)
    }
    
    
    
    
    
}
//
//  NotificationTableViewCell.swift
//  LetsChart
//
//  Created by JiangYe on 7/6/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var typeLable: UILabel!
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bindData(notification : NSDictionary)
    {
        let type = notification["type"] as! String
            
    
          if type == "Request" {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")

        let requesterId = notification.objectForKey("requesterId") as! String
        
        let whereClause = "objectId = '\(requesterId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users) in
            
            let requester = users.data.first as! BackendlessUser
            
            if let avatarURL = requester.getProperty("Avatar"){
                
                getImageFromURL(avatarURL as! String, result: { (image) in
                    
                    self.avatarImageView.image = image
                })
            }
            
        }) { (fault) in
            print("error, cound't get user image: \(fault)")
        }
        nameLable.text = (notification["requesterName"] as! String)
            
        let date = dataFormatter().dateFromString(notification["date"] as! String)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLable.text = TimeElipsed(seconds)
            
        typeLable.text = "Friend Request"
      }
        
        if type == "Confirmation" {
            
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
            avatarImageView.layer.masksToBounds = true
            
            self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
            
            let friendId = notification.objectForKey("friendId") as! String
            
            let whereClause = "objectId = '\(friendId)'"
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = whereClause
            let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
            
            dataStore.find(dataQuery, response: { (users) in
                
                let requester = users.data.first as! BackendlessUser
                
                if let avatarURL = requester.getProperty("Avatar"){
                    
                    getImageFromURL(avatarURL as! String, result: { (image) in
                        
                        self.avatarImageView.image = image
                    })
                }
                
            }) { (fault) in
                print("error, cound't get user image: \(fault)")
            }
            nameLable.text = (notification["friendName"] as! String).stringByAppendingString(" is friend now ! ")
            
            let date = dataFormatter().dateFromString(notification["date"] as! String)
            let seconds = NSDate().timeIntervalSinceDate(date!)
            dateLable.text = TimeElipsed(seconds)
            typeLable.text = "Confirmation"
        }
        
    }
    
}

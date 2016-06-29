//
//  RecentTableViewCell.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var lastMessageLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func bindData(recent:NSDictionary){
        
        let chatRoomIdLength = (recent.objectForKey("chatRoomID")as! String).characters.count
        if chatRoomIdLength > 100 {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
            avatarImageView.layer.masksToBounds = true
            
            let withUsersId = recent.objectForKey("withUserUserId") as! [String]
            
            var images:[UIImage] = []
            print("withUserId count = '\(withUsersId.count)'")
            //1. put all withUser's image into images array && name into names
            for i in 0..<withUsersId.count {
                
                let withUserId = withUsersId[i]
                
                let whereClause = "objectId = '\(withUserId)'"
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                
                let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
                
                dataStore.find(dataQuery, response: { (users : BackendlessCollection!) ->Void in
                    
                    let withUser = users.data[0] as! BackendlessUser
                    
                    if let avatarURL = withUser.getProperty("Avatar") {
                        getImageFromURL(avatarURL as! String, result: { (image) in
                            print("append one image")
                            images.append(image!)
                        })
                    }else {
                        print("append place holder")
                         images.append(UIImage(named: "avatarPlaceholder")!)
                    }
                    
                    if (i == withUsersId.count - 1 )
                    {
                        print("i = '\(i)'")
                        print("when call method images counter = '\(images.count)'")
                         self.avatarImageView.image = self.imageFromImages(images)
                    }
                    
                }) {(fault:Fault!)-> Void in
                    print("error, cound't get user image: \(fault)")
                }
            }
        
            let names = recent.objectForKey("withUserUserName") as! [String]
         
            nameLable.text = nameFromNames(names)
            
            lastMessageLable.text = recent["lastMessage"] as? String
            counterLabel.text = ""
            
            if(recent["counter"] as? Int)! != 0 {
                counterLabel.text = "\(recent["counter"]!) New"
            }
            
            let date = dataFormatter().dateFromString((recent["date"] as? String)!)
            let seconds = NSDate().timeIntervalSinceDate(date!)
            dateLabel.text = TimeElipsed(seconds)

            
        }
        else {
       avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        let withUserId = (recent.objectForKey("withUserUserId") as? String)
        
        //get the backendless user and download profile image 
        
        let whereClause = "objectId = '\(withUserId!)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) ->Void in
            
            let withUser = users.data[0] as! BackendlessUser
            
            if let avatarURL = withUser.getProperty("Avatar") {
                getImageFromURL(avatarURL as! String, result: { (image) in
                    
                    self.avatarImageView.image = image
                })
            }
            
            
        }) {(fault:Fault!)-> Void in
            print("error, cound't get user image: \(fault)")
        }
        nameLable.text = recent["withUserUserName"]as? String
        lastMessageLable.text = recent["lastMessage"] as? String
        counterLabel.text = ""
        
        if(recent["counter"] as? Int)! != 0 {
            counterLabel.text = "\(recent["counter"]!) New"
        }
        
        let date = dataFormatter().dateFromString((recent["date"] as? String)!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLabel.text = TimeElipsed(seconds)
        }
        
    }
    
    func getMixedImg(image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSizeMake(image1.size.width, image1.size.height + image2.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.drawInRect(CGRectMake(0,0,size.width, image1.size.height))
        image2.drawInRect(CGRectMake(0,image1.size.height,size.width, image2.size.height))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }/*
         CGSize size = CGSizeMake(image1.size.width, image1.size.height + image2.size.height);
         
         UIGraphicsBeginImageContextWithOptions(size, false, 0.0) // Use this call
         
         [image1 drawInRect:CGRectMake(0,0,size.width, image1.size.height)];
     
         [image2 drawInRect:CGRectMake(0,image1.size.height,size.width, image2.size.height)];
         
         UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
         
         UIGraphicsEndImageContext();
         
         //Add image to view
         UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, finalImage.size.width, finalImage.size.height)];
         imageView.image = finalImage;
         [self.view addSubview:imageView];
        }*/
        
    func imageFromImages(images: [UIImage] )-> UIImage
    {
        
        var totalWidth:CGFloat = 0.0
        for i in 0..<images.count {
            print("add one = '\(images[i].size.width)'")
            totalWidth += images[i].size.width
        }
        
        let num : CGFloat = CGFloat(images.count)
        
        let widthOffSet = totalWidth/num
        
        print("images number = '\(images.count)'")
        print("total width = '\(totalWidth)'")
        print("first height = '\(images[0].size.height)'")
        let size = CGSizeMake(totalWidth, images[0].size.height)
        
       UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        for i in 0..<images.count{
            
            images[i].drawInRect(CGRectMake(CGFloat(i) * widthOffSet, 0 , widthOffSet, size.height))
        }
        
         let finalImage = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()
        
        return finalImage
    }

    
    func nameFromNames(names: [String]) -> String
    {
        
        var name : String = ""
        
        for i in 0..<names.count{
            name = name.stringByAppendingString(names[i])
        }
        
        return name
    }
    
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
    }

//
//  Avatar.swift
//  LetsChart
//
//  Created by JiangYe on 6/19/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

func uploadAvatar(image: UIImage, result: (imageLink: String?)->Void)
    
{
   let imageData = UIImageJPEGRepresentation(image, 1.0)
    
    let dateString = dataFormatter().stringFromDate(NSDate())
    
    let fileName = "Img/" + dateString + ".jped"
    
    backendless.fileService.upload(fileName, content: imageData, response: { (file:BackendlessFile!) in
        //success
        result(imageLink: file.fileURL)
        
    }) { (fault:Fault!) in
        
        print("eror uploading avatar image: \(fault)")
    }
}

func getImageFromURL(url:String, result:(image: UIImage?) -> Void)
{
    let URL = NSURL(string: url)
    let downloadQueue = dispatch_queue_create("imageDownloadQueue", nil) // crate this thread to get image from url
    
    dispatch_async(downloadQueue){ () -> Void in
        let data = NSData(contentsOfURL: URL!)
        
        let image:UIImage!
        if data != nil{
            
            image = UIImage(data: data!)
            
            dispatch_async(dispatch_get_main_queue()){  // call main queue get image
                result(image: image)
            }
        }
        
    }

}


 func getImagesFromId(usersId: [String], images: (images: [UIImage]) -> Void )
{
    
    var UIimages:[UIImage] = []
    
    var whereClause = "objectId = '\(usersId[0])'"
    if usersId.count > 1 {
        
        for i in 0..<usersId.count {
            
            whereClause += " or objectId = '\(usersId[i])'"
        }
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) ->Void in
            
            let withUsers = users.data as! [BackendlessUser]
            
            for user in withUsers {
                var willAppend = false
                if let avatarURL = user.getProperty("Avatar"){
                    willAppend = true
                    getImageFromURL(avatarURL as! String, result: { (image) in
                        UIimages.append(image!)
                        if(UIimages.count == withUsers.count)
                        {
                            images(images: UIimages)
                        }
                    })
                }
                if !(willAppend){
                    UIimages.append(UIImage(named: "avatarPlaceholder")!)
                    if(UIimages.count == withUsers.count)
                    {
                        images(images: UIimages)
                    }
                }
            }
        }) {(fault:Fault!)-> Void in
            print("error, cound't get user image: \(fault)")
        }
        
    }
}

func imageFromImages(images: [UIImage] )-> UIImage
{
    
    var totalWidth:CGFloat = 0.0
    for i in 0..<images.count {
        
        totalWidth += images[i].size.width
        
    }
    
    let num : CGFloat = CGFloat(images.count)
    
    let widthOffSet = totalWidth/num
    
    let size = CGSizeMake(totalWidth, images[0].size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    
    for i in 0..<images.count{
        
        images[i].drawInRect(CGRectMake(CGFloat(i) * widthOffSet, 0 , widthOffSet, size.height))
    }
    
    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return finalImage
}


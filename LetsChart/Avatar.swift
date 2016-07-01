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
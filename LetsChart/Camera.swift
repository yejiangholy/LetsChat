//
//  Camera.swift
//  LetsChart
//
//  Created by JiangYe on 6/17/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation
import MobileCoreServices

class Camera {
    
    var delegate: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>?
    
    init(delegate_: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>? )
    {
        delegate = delegate_
    }
    
     func PresentPhotoLibrary(target: UIViewController, canEdit:Bool)
    {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) &&
           !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePicker.sourceType = .PhotoLibrary
            
            if let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary){
                if (availableTypes as NSArray).containsObject(type){
                    
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum){
            imagePicker.sourceType = .SavedPhotosAlbum
            
            if let availableType = UIImagePickerController.availableMediaTypesForSourceType(.SavedPhotosAlbum){
                if(availableType as NSArray).containsObject(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.presentViewController(imagePicker, animated: true , completion: nil)
        
    
}
     func PresentPhoteCamera(target: UIViewController, canEdit: Bool ) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            return
        }
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            if let availableType = UIImagePickerController.availableMediaTypesForSourceType(.Camera){
                if (availableType as NSArray).containsObject(type) {
                    imagePicker.mediaTypes = [type]
                    imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.Rear){
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.Front){
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
        } else {
            // show alert no camera is available
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.presentViewController(imagePicker, animated: true, completion:  nil)
        
    }
    
}
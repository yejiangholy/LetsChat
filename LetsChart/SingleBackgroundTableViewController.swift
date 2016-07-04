//
//  SingleBackgroundTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 7/4/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class SingleBackgroundTableViewController: UITableViewController ,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var chatRoomId : String!
    
    @IBOutlet weak var chooseDefaultCell: UITableViewCell!
    @IBOutlet weak var choosePhotoCell: UITableViewCell!
    @IBOutlet weak var takePhotoCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        } else if section == 1 {
            
            return 2
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) && (indexPath.row == 0) {
            return  chooseDefaultCell
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            return choosePhotoCell
        }
        if (indexPath.section == 1) && (indexPath.row == 1){
            return takePhotoCell
        }
        else {
            return UITableViewCell()
        }
        
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 30
        } else {
            return 40
        }
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            chooseDefaultBackgroundPressed()
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            choosePhotoPressed()
            
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            
            takePhotoPressed()
        }
    }
    
    func chooseDefaultBackgroundPressed()
    {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let defaultOne = UIAlertAction(title: "Default WallPaper 1", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            
            //set user defalt this room to this picture
            var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
            if backgroundDictionary == nil {
                let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(UIImage(named: "Background_1")!)!]
                self.userDefaults.setObject(backgroundDic, forKey: "background" )
                
            }else {
                
                backgroundDictionary?.updateValue(UIImagePNGRepresentation(UIImage(named: "Background_1")!)!, forKey: self.chatRoomId)
                
                self.userDefaults.setObject(backgroundDictionary, forKey: "background")
                
            }
            
            
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            
        }
        let defaultTwo = UIAlertAction(title: " Default WallPaper 2", style: .Default) { (alert :UIAlertAction!) -> Void in
            
            
            //set user defalt this room to this picture
            var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
            if backgroundDictionary == nil {
                
                let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(UIImage(named: "Background_2")!)!]
                
                self.userDefaults.setObject(backgroundDic, forKey: "background" )
              
                
                
            }else {
                
                backgroundDictionary?.updateValue(UIImagePNGRepresentation(UIImage(named: "Background_2")!)!, forKey: self.chatRoomId)
                self.userDefaults.setObject(backgroundDictionary, forKey: "background")
                
            }
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
        }
        optionMenu.addAction(defaultOne)
        optionMenu.addAction(defaultTwo)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    func choosePhotoPressed()
    {
        
        let camera = Camera(delegate_: self)
        
        camera.PresentPhotoLibrary(self, canEdit: true)
    }
    
    
    
    func takePhotoPressed()
    {
        let camera = Camera(delegate_: self)
        
        camera.PresentPhoteCamera(self, canEdit: true)
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        //set user defalt this room to this picture
        var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
        if backgroundDictionary == nil {
            let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(image!)!]
            self.userDefaults.setObject(backgroundDic, forKey: "background" )
            
        }else {
            
            backgroundDictionary?.updateValue(UIImagePNGRepresentation(image!)!, forKey: self.chatRoomId)
            self.userDefaults.setObject(backgroundDictionary, forKey: "background")
            
        }
        // segua back to groupChatVC
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
  
}

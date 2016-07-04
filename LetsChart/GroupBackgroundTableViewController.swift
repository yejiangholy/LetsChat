//
//  GroupBackgroundTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 7/3/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class GroupBackgroundTableViewController: UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var chatRoomId : String!
    var groupChatVC :GroupChatViewController!
    var recent: NSDictionary!
    var background : UIImage?
    
    @IBOutlet weak var ChooseDefaultCell: UITableViewCell!
    @IBOutlet weak var ChoosePhotosCell: UITableViewCell!
    @IBOutlet weak var TakePhotoCell: UITableViewCell!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
            return  ChooseDefaultCell
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            return ChoosePhotosCell
        }
        if (indexPath.section == 1) && (indexPath.row == 1){
            return TakePhotoCell
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
           
            
            self.background = UIImage(named: "Background_1")
            //set user defalt this room to this picture 
            var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
            if backgroundDictionary == nil {
                let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(UIImage(named: "Background_1")!)!]
             self.userDefaults.setObject(backgroundDic, forKey: "background" )
                
            }else {
                
                backgroundDictionary?.updateValue(UIImagePNGRepresentation(UIImage(named: "Background_1")!)!, forKey: self.chatRoomId)
                
                }
            
            // change groupChatVC's background image ( may be you can delete this line of code)
            
            self.groupChatVC.backGround = UIImage(named: "Background_1")!
            
            // segua back to groupChatVC
            
            self.performSegueWithIdentifier("wallPaperBackToGroupChat", sender: self)
            
            
        }
        let defaultTwo = UIAlertAction(title: " Default WallPaper 2", style: .Default) { (alert :UIAlertAction!) -> Void in
            
            self.background = UIImage(named: "Background_2")
            
            //set user defalt this room to this picture
            var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
            if backgroundDictionary == nil {
                let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(UIImage(named: "Background_2")!)!]
                self.userDefaults.setObject(backgroundDic, forKey: "background" )
                
            }else {
                
                backgroundDictionary?.updateValue(UIImagePNGRepresentation(UIImage(named: "Background_2")!)!, forKey: self.chatRoomId)
                
            }
            
            // change groupChatVC's background image ( may be you can delete this line of code)
            
             self.groupChatVC.backGround = UIImage(named: "Background_2")!
            // segua back to groupChatVC
            
            //self.performSegueWithIdentifier("wallPaperBackToGroupChat", sender: self)
          self.navigationController?.popViewControllerAnimated(true)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
        }
        optionMenu.addAction(defaultOne)
        optionMenu.addAction(defaultTwo)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "wallPaperBackToGroupChat" {
            
            let chatView = segue.destinationViewController as! GroupChatViewController
            chatView.recent = self.recent
            chatView.chatRoomId = self.chatRoomId
            chatView.backGround = self.background
        }
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
        
        self.background = image
        //set user defalt this room to this picture
        var backgroundDictionary  = self.userDefaults.dictionaryForKey("background")
        if backgroundDictionary == nil {
            let backgroundDic : NSMutableDictionary = [self.chatRoomId: UIImagePNGRepresentation(image!)!]
            self.userDefaults.setObject(backgroundDic, forKey: "background" )
            
        }else {
            
            backgroundDictionary?.updateValue(UIImagePNGRepresentation(image!)!, forKey: self.chatRoomId)
            
        }
        
        // change groupChatVC's background image ( may be you can delete this line of code)
        
        self.groupChatVC.backGround = image!
        
        // segua back to groupChatVC
        
        self.performSegueWithIdentifier("wallPaperBackToGroupChat", sender: self)
        
             picker.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    
    
    
}

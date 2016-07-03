//
//  GroupEditingTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 7/1/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class GroupEditingTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var changeNameCell: UITableViewCell!
    @IBOutlet weak var changePictureCell: UITableViewCell!
    @IBOutlet weak var addFriendsCell: UITableViewCell!
    @IBOutlet weak var leaveGroupCell: UITableViewCell!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupNameLable: UILabel!
    
    var groupChatViewController: GroupChatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getImageFromURL(groupChatViewController.recent!["image"] as! String) { (image) in
            
            self.groupImage.image = image
            
            self.groupChatViewController.groupImage = image
            
        }
            self.tableView.tableHeaderView = headerView
            
            groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
            groupImage.layer.masksToBounds = true
            
            groupNameLable.text = groupChatViewController.groupName
        
    }
    
    
    @IBAction func didClickGroupImage(sender: UIButton) {
        
        changePhoto()
    }
    
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 0
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // if first section first cell
        if (indexPath.section == 0) && (indexPath.row == 0) {
            return changeNameCell
        }
        if (indexPath.section == 0) && (indexPath.row == 1) {
            return changePictureCell
        }
        if (indexPath.section == 0) && (indexPath.row == 2) {
            return addFriendsCell
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            return leaveGroupCell
        } else
        {
            return UITableViewCell()
        }

    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        } else {
            return 25
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
    }
    
    
    //MARK: Tableview Delegate functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            leaveGroupCellPressed()
            
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            changeGroupNamePressed()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            changePhoto()
            
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            
            //addFriendsCellPressed()
        }
        
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.groupChatViewController.groupImage = image
        
        uploadAvatar(image!) { (imageLink) in
            
           UpdateRecentsWithImage(self.groupChatViewController.chatRoomId, imageLink: imageLink!)
            
        }
        
         self.groupImage.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    
    func leaveGroupCellPressed()
    {
        //3. segue to recent view controller
        //2. remove current user from all the this groups recnts member 
        //1. (do this in prepare for segue)delete current user's this recent, then let recentViewController reloadData()
        
        DeleteUserFromGroupRecents(self.groupChatViewController.chatRoomId, user: backendless.userService.currentUser)
        
        self.performSegueWithIdentifier("LeaveGroupToRecentSeg", sender: groupChatViewController.recent)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LeaveGroupToRecentSeg" {
            
            let recentVC = segue.destinationViewController as! RecentViewController
            
            let recent = sender as! NSDictionary

            
            print(recentVC.recents)
            
            //recentVC.recents.removeAtIndex(recentVC.recents.indexOf(recent)!)
            DeleteRecentItem(recent)
            
            recentVC.tableView.reloadData()
            
        }
        
    }
    
    
    func changeGroupNamePressed(){
    
        var inputTextField: UITextField?
        let groupNamePrompt = UIAlertController(title: "Enter group name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        groupNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        groupNamePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            if inputTextField!.text != ""
            {
                self.groupChatViewController.groupName = inputTextField?.text
                self.groupNameLable.text = inputTextField?.text
                
               UpdateRecentsWitName(self.groupChatViewController.chatRoomId, name: (inputTextField?.text)!)
                
            }
            
        }))
        groupNamePrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "group name"
            textField.secureTextEntry = false
            inputTextField = textField
        })
        
        presentViewController(groupNamePrompt, animated: true, completion: nil)
        
        
    }
    
    
    // MARK : change photo
    
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            camera.PresentPhoteCamera(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert :UIAlertAction!) -> Void in
            
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
            print("Cancel")
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    

}

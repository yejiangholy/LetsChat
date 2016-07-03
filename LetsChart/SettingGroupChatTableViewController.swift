//
//  SettingGroupChatTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/28/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

protocol ChooseGroupUserDelegate{
    
    func createGroupChatRoom(users: [BackendlessUser], title: String?, image: UIImage?)
    
}
class SettingGroupChatTableViewController: UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    var friends: [BackendlessUser] = []
    var otherMembers : [BackendlessUser] = []
    var delegate: ChooseGroupUserDelegate!
    var groupImage: UIImage?
    
   
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //MARK: UITableView dataSrouce 
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedRow = tableView.cellForRowAtIndexPath(indexPath)!
         let user = friends[indexPath.row]
        
        if selectedRow.accessoryType == UITableViewCellAccessoryType.None {
            selectedRow.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedRow.tintColor = UIColor.greenColor()
            self.otherMembers.append(user)
            
        } else {
            selectedRow.accessoryType = UITableViewCellAccessoryType.None
            let index = otherMembers.indexOf(user)
            self.otherMembers.removeAtIndex(index!)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let user = friends[indexPath.row]
        cell.textLabel?.text = user.name
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFriends()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    @IBAction func cameraButtonPressed(sender: UIBarButtonItem) {
        
            setGroupChatImage()
    }
    
    
    
   
    @IBAction func CreateButtonPressed(sender: UIButton) {
        
        
        if groupNameTextField!.text == "" {
            //show alert
            
            let nameAlert = UIAlertController(title: "Name This Group", message: "Anyone in the group can change the name later ~", preferredStyle: .Alert)
            
        
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            nameAlert.addAction(cancel)
            
            self.presentViewController(nameAlert, animated: true, completion: nil)
            
        } else {
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            self.otherMembers.append(backendless.userService.currentUser)
            
            delegate.createGroupChatRoom(otherMembers, title: groupNameTextField.text!,image: groupImage)
        }
    }
    
    
    
    func setGroupChatImage()
    {
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
    
    //MARK: UIImagePickerControllerDelegate functions 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        groupImage = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    
    //MARK: Load currentUser's friends
    func loadFriends(){
        ProgressHUD.show("Loading")
        // 1. get current user's friends list
        let whereClause = "objectId = '\(backendless.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            let currentUser = users.data.first as! BackendlessUser
            
            let friendsList = currentUser.getProperty("FriendsList")
            if let friendIdList = friendsList as? String{
                
                let friendsIdArray = friendIdList.componentsSeparatedByString(" ")
                
                var whereClause = "objectId = '\(friendsIdArray[0])'"
                
                if friendsIdArray.count > 1 {
                    
                    for i in 1..<friendsIdArray.count {
                        
                        whereClause += " or objectId = '\(friendsIdArray[i])'"
                    }
                    
                    let dataQuery = BackendlessDataQuery()
                    dataQuery.whereClause = whereClause
                    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
                    
                    dataStore.find(dataQuery, response: { (users : BackendlessCollection!) in
                        
                        
                        self.friends = users.data as! [BackendlessUser]
                        
                        ProgressHUD.dismiss()
                        self.tableView.reloadData()//update table
                        
                        }, error: { (fault : Fault!) in
                            
                            ProgressHUD.showError("Error, couldn't retrive user's friends : \(fault)")
                    })
                    
                }else {
                    
                    let dataQuery = BackendlessDataQuery()
                    dataQuery.whereClause = whereClause
                    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
                    
                    dataStore.find(dataQuery, response: { (users : BackendlessCollection!) in
                        
                        
                        self.friends = users.data as! [BackendlessUser]
                        
                        self.tableView.reloadData()//update table
                        
                        }, error: { (fault : Fault!) in
                            
                            ProgressHUD.showError("Error, couldn't retrive user's friends")
                    })
                    
                }
            }else {
                // do not have any friends in current user's friends list
                ProgressHUD.showError("go add friends to chat !")
            }
            
        }){ (fault : Fault!) in
            ProgressHUD.showError("Server error \(fault)")
        }
        
    }

    
  
}

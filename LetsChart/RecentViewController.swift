//
//  RecentViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, ChooseUserDelegate, ChooseGroupUserDelegate {

    @IBOutlet weak var tableView: UITableView!
    var recents: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSource 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecentTableViewCell
        let recent = recents[indexPath.row]
        
        cell.bindData(recent)
        
        return cell 
    }
    
    //MARK: UITableviewDelegate functions 
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //create recent for both users  
        let recent = recents[indexPath.row]
        RestartRecentChat(recent)
        
        let members = recent.objectForKey("members") as! [String]
        
        if members.count == 2 {
            
        performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
            
        } else {
            
            performSegueWithIdentifier("recentToGroupChatSeg", sender: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    } // let user Edit our talbe view cell
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let recent = recents[indexPath.row]
        //remove it ..
        recents.removeAtIndex(indexPath.row)
        
        // then delete recent from firebase
        DeleteRecentItem(recent)
        
        tableView.reloadData()
        
    }
    
    //MARK: IBActions
    @IBAction func startNewChatBarButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
        
    }
    
    @IBAction func addSearchUserButtonPressed(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let searchUsers = UIAlertAction(title: "Search Users", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            self.performSegueWithIdentifier("RecentToSearchSeg", sender: self)
            
        }
        let formGroupChat = UIAlertAction(title: "Form a group chat", style: .Default) { (alert :UIAlertAction!) -> Void in
            
             self.performSegueWithIdentifier("recentToGroupSettingSeg", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
            print("Cancel")
        }
        optionMenu.addAction(searchUsers)
        optionMenu.addAction(formGroupChat)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recentToChooseUserVC"{
            let vc = segue.destinationViewController as! ChooseUserViewController
            vc.delegate = self
        }
        
        if segue.identifier == "recentToChatSeg"{
            let indexpath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! ChatViewController
            
            chatVC.hidesBottomBarWhenPushed = true
            
            let recent = recents[indexpath.row]
            
            //set chatVC recent to our recent
            chatVC.recent = recent
            chatVC.chatRoomId = recent["chatRoomID"] as? String
            
        }
        
        if segue.identifier == "recentToGroupChatSeg" {
            let indexpath = sender as! NSIndexPath
            let groupChatVC = segue.destinationViewController as! GroupChatViewController
            
            groupChatVC.hidesBottomBarWhenPushed = true
            
            let recent = recents[indexpath.row]
            
            groupChatVC.recent = recent
            groupChatVC.chatRoomId = recent["chatRoomID"] as? String
            groupChatVC.groupName = recent.objectForKey("name") as? String
        }
        
        
        if segue.identifier == "recentToGroupSettingSeg"{
            let navigation = segue.destinationViewController as! UINavigationController
            
            let groupSettingView = navigation.topViewController as! SettingGroupChatTableViewController
            
            groupSettingView.delegate = self
        }

    }
    
    
    //MARK: ChooseUserDelegate 
    func createChatroom(withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true // no button bar when chat 
        
        navigationController?.pushViewController(chatVC, animated: true)
        
        //set chatVC recent to our recent
        chatVC.withUser = withUser
        chatVC.chatRoomId = startChatId(backendless.userService.currentUser, user2: withUser)
        
    }
    
    //MARK : ChooseGroupUserDelegate
    func createGroupChatRoom(users: [BackendlessUser], title: String?, image: UIImage?)
    {
        let groupChatVC = GroupChatViewController()
        
        groupChatVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(groupChatVC, animated: true)
        
        groupChatVC.withUser = users.filter{ $0.objectId! != backendless.userService.currentUser.objectId }
        
        groupChatVC.chatRoomId = startGroupChatId(users, name: title!, Image: image)
        
        groupChatVC.title = title
        
    }
    
    //MARK: Load Recents from firebase
    
    func loadRecents(){
        firebase.child("Recent").queryOrderedByChild("userId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value, withBlock: { snapshot in
            self.recents.removeAll()
            
            if snapshot.exists(){
                
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key:"date",ascending: false)])
                
                for recent in sorted {
                    
                    self.recents.append(recent as! NSDictionary)
                    
                    //add function to have offline access as well
                    
                    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(recent["chatRoomID"]).observeEventType(.Value, withBlock: {
                        snapshot in
                        
                    })
                    
                }
            }
            self.tableView.reloadData()
        })
    }
}

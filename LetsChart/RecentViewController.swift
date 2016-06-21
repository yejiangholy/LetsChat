//
//  RecentViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, ChooseUserDelegate{

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
        
        
        performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
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
    
    //MARK: Load Recents from firebase 
    
    func loadRecents(){
        firebase.childByAppendingPath("Recent").queryOrderedByChild("userId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value, withBlock: { snapshot in
            self.recents.removeAll()
            
            if snapshot.exists(){
                
                let sorted = (snapshot.value.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key:"data",ascending: false)])
                
                for recent in sorted {
                    
                    self.recents.append(recent as! NSDictionary)
                    
                    //add function to have offline access as well
                    
                    firebase.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(recent["chatRoomId"]).observeEventType(.Value, withBlock: {
                        snapshot in
                        
                    })
                    
                }
            }
            self.tableView.reloadData()
        })
    }
        
    
   
}

//
//  NotificationsViewController.swift
//  LetsChart
//
//  Created by JiangYe on 7/6/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications:[NSDictionary] = []
    
    var confirmations:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadNotifications()
        
        loadConfirmations()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 //MARK: UITableViewDataSource 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0 )
        {
            return notifications.count
        }
        if(section == 1)
        {
            return confirmations.count
        }
        else {
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        as! NotificationTableViewCell
        
        if(indexPath.section == 0){
        let notification = notifications[indexPath.row]
        cell.bindData(notification)
        return cell
        }
        else{
            let confirmation = confirmations[indexPath.row]
            cell.bindData(confirmation)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if( indexPath.section == 0 ) {
        let notification = notifications[indexPath.row]
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let confirm = UIAlertAction(title: " Confirm ", style: .Default) { (alert: UIAlertAction!) -> Void in
            // do something when user confirmed this request
             self.confirmRequest(notification)
            
            
            // delte this notification from table
            self.notifications.removeAtIndex(indexPath.row)
            DeleteNotificationItem(notification)
            self.tableView.reloadData()
            
        }
        let reject = UIAlertAction(title: " Reject ", style: .Default) { (alert :UIAlertAction!) -> Void in
            
            // delte this notification from table
            self.notifications.removeAtIndex(indexPath.row)
            DeleteNotificationItem(notification)
            self.tableView.reloadData()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
              self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        optionMenu.addAction(confirm)
        optionMenu.addAction(reject)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        else if indexPath.section == 1  {
           // display action sheet, have two option, 1. go and say Hi ~  2 . cancel 
            // both of action will delete this confirmatin both in table view and in database 
            // go and say Hi --> do the same thing as create a chat room for them 
            // cancel just delete this confirmation 
            
            let confirmation = confirmations[indexPath.row]
            
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let sayHi = UIAlertAction(title: " go and say Hi ~  ", style: .Default) { (alert: UIAlertAction!) -> Void in
                
                // crate a chat room and segue to that single chat room
                let friendId = confirmation["friendId"] as! String
                let whereClause = "objectId = '\(friendId)'"
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
                
                dataStore.find(dataQuery, response: { (users) in
                    
                    let friend = users.data.first as! BackendlessUser
                    
                    self.CreateChatRoom(friend)
                    
                    }, error: { (fault) in
                        
                    ProgressHUD.showError("could find this User")
                })
                
                // delte this confirmation from table
                self.confirmations.removeAtIndex(indexPath.row)
                DeleteConfirmationItem(confirmation)
                self.tableView.reloadData()
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
                
                // delte this confirmation from table
                self.confirmations.removeAtIndex(indexPath.row)
                DeleteConfirmationItem(confirmation)
                self.tableView.reloadData()
                
            }
            optionMenu.addAction(sayHi)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    
    func CreateChatRoom( user: BackendlessUser)
    {
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true // no button bar when chat
        
        navigationController?.pushViewController(chatVC, animated: true)
        
        //set chatVC recent to our recent
        chatVC.withUser = user
        chatVC.chatRoomId = startChatId(backendless.userService.currentUser, user2: user)
        
    }
    
    func confirmRequest( request: NSDictionary)
    {
        
         ProgressHUD.show("Loading")
        
        let user1Id = request["requesterId"] as! String
        let user2Id = request["friendId"] as! String
        let requesterName = request["requesterName"] as! String
        
        letThemBecomeFriends(user1Id, user2Id: user2Id) { (result) in
            
            if result == true{
                
                // create a confirmation  ot requester 
                
                SendConfirmation(request)
                
             ProgressHUD.showSuccess("Your and'\(requesterName)' are friends now  !")
                
            } else {
        
                ProgressHUD.showError("server error when adding '\(requesterName)'")
            }
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    } // let user Edit our talbe view cell
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        //remove it ..
        notifications.removeAtIndex(indexPath.row)
        
        // then delete recent from firebase
         DeleteNotificationItem(notification)
        tableView.reloadData()
        
    }
    
    
    
    func loadNotifications()
    
    { firebase.child("Notification").queryOrderedByChild("friendId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value, withBlock: { snapshot in
            self.notifications.removeAll()
            
            if snapshot.exists(){
                
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key:"date",ascending: false)])
                
                for notification in sorted {
                    
                    self.notifications.append(notification as! NSDictionary)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func loadConfirmations()
    {
        firebase.child("Confirmation").queryOrderedByChild("requesterId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value, withBlock: { snapshot in
            self.confirmations.removeAll()
            
            if snapshot.exists(){
                
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key:"date",ascending: false)])
                
                for confirmation in sorted {
                    
                    self.confirmations.append(confirmation as! NSDictionary)
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
}



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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadNotifications()

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
        return notifications.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        as! NotificationTableViewCell
        
        let notification = notifications[indexPath.row]
        
        cell.bindData(notification)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
            
        }
        optionMenu.addAction(confirm)
        optionMenu.addAction(reject)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    func confirmRequest( request: NSDictionary)
    {
        
         ProgressHUD.show("Loading")
        
        let user1Id = request["requesterId"] as! String
        let user2Id = request["friendId"] as! String
        let requesterName = request["requesterName"] as! String
        
        letThemBecomeFriends(user1Id, user2Id: user2Id) { (result) in
            
            if result == true{
             ProgressHUD.dismiss()
             ProgressHUD.showSuccess("Your and'\(requesterName)' are friends now  !")
            } else {
                 ProgressHUD.dismiss()
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
    
}



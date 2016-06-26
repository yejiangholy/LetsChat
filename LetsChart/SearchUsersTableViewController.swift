//
//  SearchUsersTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/24/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class SearchUsersTableViewController: UITableViewController ,UISearchResultsUpdating {
    
    var AllUsers:[BackendlessUser] = []
    var filterUsers:[BackendlessUser] = []
    var resultSearchController = UISearchController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = true
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if self.resultSearchController.active
       {
         return self.filterUsers.count
       }else {
        return self.AllUsers.count
        }
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if self.resultSearchController.active
        {
            cell!.textLabel?.text = self.filterUsers[indexPath.row].name
        }
        else{
            cell!.textLabel?.text = self.AllUsers[indexPath.row].name
        }
        
        return cell!
    }
    
    // MARK : UISearchResultUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.filterUsers.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.AllUsers as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filterUsers = array as! [BackendlessUser]
        
        self.tableView.reloadData()
        
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Load Backendless Users
    func loadUsers(){
        
        let whereClause = "objectId != '\(backendless.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            
            self.AllUsers = users.data as! [BackendlessUser]
            
            self.tableView.reloadData()
            
        }) { (fault: Fault!) in
            
            print("Error, couldn't retrive users: \(fault)")

        }
    }
    // MARK : UITableviewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let user = AllUsers[indexPath.row]
        let userName = user.name
        
        // show alert to confirm do you really want to add this person as your friends ? 
        
        let optionMenu = UIAlertController(title: "Add '\(userName)' as you friend ?", message: nil, preferredStyle: .ActionSheet)
        
        let YesAction = UIAlertAction(title: "YES ! ", style: .Default) { (alert :UIAlertAction!) in
            
                self.userIsNotFriends(user, result: { (result) in
                if result == true {
                   
                    self.addUserToFriendsList(user, result: { (result) in
                        
                        if result == true {
                            
                            ProgressHUD.showSuccess("Your just add'\(userName)' as your friend !")
                        } else {
                            ProgressHUD.showError("Could't add'\(userName)' as your friends")
                            
                        }
                    })
                    
                }else {
                    ProgressHUD.showSuccess("'\(userName)' is already in your friend!")
                }
            })
        }
        
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) in
        }
        
        optionMenu.addAction(YesAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated:true , completion: nil)
        
        // in the positvie allert action call back function we add this user's objectId into current user's friends list and if it is the first time he add this user && add success we show message to tell them add successful and ow you could chat with this user , otherwise we show error message .
    }
    
    // MARK: Check weather the user is in current user's friends list 
    func userIsNotFriends(otherUser: BackendlessUser, result: (result: Bool)-> Void) {
        
        let whereClause = "objectId = '\(backendless.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
            
            dataStore.find(dataQuery, response: { (users:BackendlessCollection!) in
                let currentUser = users.data.first as! BackendlessUser
                
               
                if  let friendsList = currentUser.getProperty("FriendsList") as? String {
                    
                    if friendsList.containsString(otherUser.objectId as String)
                    {
                        result(result: false)
                    }else{
                        result(result:true)
                    }
                }else {
                     result(result:true)
                }
                
            }) { (fault : Fault!) in
                result(result:false)
                ProgressHUD.showError("Error when get current user")
            }
    }
    
    func addUserToFriendsList(friend: BackendlessUser, result: (result: Bool)-> Void)
    {
        let whereClause = "objectId = '\(backendless.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())

        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            let currentUser = users.data.first as! BackendlessUser
            let currentFriendsList = currentUser.getProperty("FriendsList")
            var updatedFriendsList : String
            
            if  let currentFriends = currentFriendsList as? String{
            let friendsId = (friend.objectId as String).stringByAppendingString(" ")
            updatedFriendsList = currentFriends.stringByAppendingString(friendsId)
            } else{
                updatedFriendsList = (friend.objectId as String).stringByAppendingString(" ")
            }
            let property = ["FriendsList" : updatedFriendsList]
            currentUser.updateProperties(property)
            backendless.userService.update(currentUser)
            print("updated users friendsList here ") 
            result(result: true)
            
        }) { (fault : Fault!) in
            result(result: false)
            print("Server error when adding friend:\(fault)")
        }
        
    }
    
    
    
    
    
    
    
    
    
    
}

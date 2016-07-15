//
//  SearchUsersTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/24/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class SearchUsersTableViewController: UITableViewController ,UISearchResultsUpdating {
    
    var resultSearchController : UISearchController? = nil
    var SearchUsers : [BackendlessUser] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController!.searchResultsUpdater = self
        
        self.resultSearchController!.dimsBackgroundDuringPresentation = true
        self.resultSearchController!.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController!.searchBar
        self.resultSearchController!.searchBar.placeholder = "Search user by their name"
        
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
       return SearchUsers.count
       }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SearchUserTableViewCell
        
        cell.bindData(SearchUsers[indexPath.row])
        
        return cell
    }
    
    // MARK : UISearchResultUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
        if let text = searchController.searchBar.text {
            
            if text != "" {
                self.SearchUsers.removeAll(keepCapacity: false)
                
                //let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
                let whereClause = "name = '\(text)'"
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                
                let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
                dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
                    
                    self.SearchUsers = (users.data as? [BackendlessUser])!
                    
                    self.tableView.reloadData()
                    
                }) { (fault: Fault!) in
                    
                    print("Error, couldn't find users: \(fault)")
                    
                }
            }
        }
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
       // MARK : UITableviewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let user = SearchUsers[indexPath.row]
        let userName = user.name
        
        
        // show alert to confirm do you really want to add this person as your friends ?
        
        let optionMenu = UIAlertController(title: "Add '\(userName)' as your friends ?", message: nil, preferredStyle: .ActionSheet)
        
        let YesAction = UIAlertAction(title: "YES ! ", style: .Default) { (alert :UIAlertAction!) in
            
                self.userIsNotFriends(user, result: { (result) in
                if result == true {
                   
                    if user.objectId == backendless.userService.currentUser.objectId {
                        
                        ProgressHUD.showError("Could't add youself as a friend")
                        
                        return 
                    }
                    
                    // create Notification send to firebase 
                   sendRequestNotification(backendless.userService.currentUser, friend: user)
                    
                    
                    ProgressHUD.showSuccess("Your request has been sent to'\(userName)' !")
                    
                }else {
                    ProgressHUD.showSuccess("'\(userName)' is already your friend!")
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
    
}

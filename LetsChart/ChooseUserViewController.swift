//
//  ChooseUserViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/14/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit
protocol ChooseUserDelegate {
    func createChatroom(withUser: BackendlessUser)
}

class ChooseUserViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating{
    
    var SingleDelegate: ChooseUserDelegate!
    var GroupDelegate : ChooseGroupUserDelegate!
    
    var friends:[BackendlessUser] = []
    var filterFriends:[BackendlessUser] = []
    var chatMembers :[BackendlessUser] = []
    var resultSearchController = UISearchController()
    
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()

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
    
    //MARK: UITableviewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.active
        {
            return self.filterFriends.count
        }else {
            return self.friends.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
          let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FriendsTableViewCell
        
        if self.resultSearchController.active
        {
            cell.bindData(self.filterFriends[indexPath.row])
        }else {
            
            cell.bindData(self.friends[indexPath.row])
        }
       return cell
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK : UISearchResultUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.filterFriends.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.friends as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filterFriends = array as! [BackendlessUser]
        
        self.tableView.reloadData()
        
    }

    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    @IBAction func chatButtonPressed(sender: UIBarButtonItem) {
        
        if self.chatMembers.count == 0 {
            // show alert please choose a friend to chat
            
            let Alert = UIAlertController(title: "Choose friends to Chat", message: "You could choose one or more friends to chat", preferredStyle: .Alert)
        
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            Alert.addAction(cancel)
            
            self.presentViewController(Alert, animated: true, completion: nil)
            
            
        } else if  chatMembers.count == 1 {
            
            // it is a single chat we do the same thing as previous didselectRowAtIndexPath
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let user = chatMembers.first
            
            SingleDelegate.createChatroom(user!)
            
            
        } else {
            // it is a group chat first. show alert let user input a goup name
            // then do the same thing as we did in previously groupchat
            
            var inputTextField: UITextField?
            let groupNamePrompt = UIAlertController(title: "Name your Group", message: "Anyone in the group can change the name later ~", preferredStyle: UIAlertControllerStyle.Alert)
            groupNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            groupNamePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                // Now do whatever you want with inputTextField (remember to unwrap the optional)
                if inputTextField!.text != ""
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.chatMembers.append(backendless.userService.currentUser)
                    
                    self.GroupDelegate.createGroupChatRoom(self.chatMembers, title: inputTextField!.text ,image: nil)
                    
                } else {
                    
                    
                    // if user did't input name, it will do nothing ?
                    
                    
                }
                
            }))
            groupNamePrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "group name"
                textField.secureTextEntry = false
                inputTextField = textField
            })
            
            presentViewController(groupNamePrompt, animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
       
        
        let friend = friends[indexPath.row]
        
        let LeaveAlert = UIAlertController(title: "Delete \(friend.name) ?", message: "This user will be remove from your Friends list", preferredStyle: .Alert)
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
             tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        LeaveAlert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            
            self.friends.removeAtIndex(indexPath.row)

            let currentUser = backendless.userService.currentUser
            
                let friendsList = currentUser.getProperty("FriendsList")
                if let friendIdList = friendsList as? String{
                    
                    var friendsIdArray = friendIdList.componentsSeparatedByString(" ")
                    let index = friendsIdArray.indexOf(friend.objectId)
                    friendsIdArray.removeAtIndex(index!)
                    var updatedList : String!
                    if friendsIdArray.count == 0 {
                        
                        updatedList = ""
                        
                    } else {
                        updatedList = friendsIdArray[0]
                        
                        for i in 1..<friendsIdArray.count
                        {
                            updatedList! += " "
                            updatedList! += friendsIdArray[i]
                        }
                    }
                    let property = ["FriendsList" : updatedList]

                    currentUser.updateProperties(property)
                    backendless.userService.update(currentUser)
                     self.tableView.reloadData()
            }
            
        }))
        
        LeaveAlert.addAction(cancel)
        
        self.presentViewController(LeaveAlert, animated: true, completion: nil)
    }

    
    
    //MARK: UITableviewDelegate 
    //this func being called everytime user touch our table view cell
    
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 1. we deselect it
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // 2. create chat room and a recent object to this selected user 
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let user = friends[indexPath.row]
        
        SingleDelegate.createChatroom(user)
        
    } */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedRow = tableView.cellForRowAtIndexPath(indexPath)!
        
        let user = friends[indexPath.row ]
        
        if selectedRow.accessoryType == UITableViewCellAccessoryType.None {
            
            selectedRow.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedRow.tintColor = UIColor.greenColor()
            self.chatMembers.append(user)
            
        } else {
            
            selectedRow.accessoryType = UITableViewCellAccessoryType.None
            let index = chatMembers.indexOf(user)
            self.chatMembers.removeAtIndex(index!)
            
        }
        
    }
    
    
    
    //MARK: Load currentUser's friends
    func loadFriends(){
        // 1. get current user's friends list
        let whereClause = "objectId = '\(backendless.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
            let currentUser = users.data.first as! BackendlessUser
            
        let friendsList = currentUser.getProperty("FriendsList")
            if let friendIdList = friendsList as? String{
                
                if friendIdList == "" {
                    
                    ProgressHUD.showSuccess("Go add more friends to chat !")
                    
                    return
                }
            
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
                ProgressHUD.showSuccess("go Add friends to chat !")
            }
            
        }){ (fault : Fault!) in
            ProgressHUD.showError("Server error \(fault)")
        }
        
    }
    
}


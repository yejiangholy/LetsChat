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

class ChooseUserViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    var delegate: ChooseUserDelegate!
    var users:[BackendlessUser] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFriends()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableviewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: IBactions
    @IBAction func cancelButtonPressed(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: UITableviewDelegate 
    //this func being called everytime user touch our table view cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 1. we deselect it
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // 2. create chat room and a recent object to this selected user 
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let user = users[indexPath.row]
        
        delegate.createChatroom(user)
        
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
                        
                        
                        self.users = users.data as! [BackendlessUser]
                        
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
                        
                        
                        self.users = users.data as! [BackendlessUser]
                        
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


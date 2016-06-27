//
//  GroupChatViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/26/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class GroupChatViewController: JSQMessagesViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    let firebaseRef = firebase.child("Message")
    
    var messages:[JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImageDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    var showAvatars:Bool = false
    var firstLoad: Bool?
    
    var withUser: [BackendlessUser]?
    var recent: NSDictionary?
    var groupName: String?
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())

    override func viewWillAppear(animated: Bool) {
        
        loadUserDefaults()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        ClearRecentCounter(chatRoomId)
        
        firebaseRef.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        if withUser?.count == 0 {
            
            getWithUsersFromRecent(recent!, result: { (withUsers) in
                self.withUser = withUsers
                self.getAvatar()
            })
        } else {
            self.getAvatar()
        }
        
        loadMessage()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
    }
    
    //MARK: JSQMessage dataSrouce functions 
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: loadUserDefaults
    
    func loadUserDefaults()
    {
        firstLoad = userDefaults.boolForKey(KFIRSTRUN)
        
        if !(firstLoad!) {
            userDefaults.setBool(true, forKey: KFIRSTRUN)
            userDefaults.setBool(showAvatars, forKey: KAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.boolForKey(KAVATARSTATE)
    }
    
  
    func getWithUsersFromRecent(recent: NSDictionary, result: (withUsers: [BackendlessUser])-> Void) {
        
        let withUserId = recent["withUserUserId"] as? [String]
        
        var whereClause = "objectId = '\(withUserId![0])'"
        
        for i in 1..<withUserId!.count {
            whereClause += "or objectId = '\(withUserId![i])'"
        }
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) -> Void in
            
            let withUsers = users.data as! [BackendlessUser]
            
            result(withUsers: withUsers)
            
        }) {(fault: Fault!) -> Void in
            
            print("Server report an error :\(fault)")
        }
    }
    
    
    
    func getAvatar()
    {
        if showAvatars {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
              avatarImageFromBackendlessUser(backendless.userService.currentUser)
            for i in 0..<withUser!.count {
                avatarImageFromBackendlessUser(withUser![i])
            }
            
            createAvatars(avatarImageDictionary)
        }
    }
    
    
    func avatarImageFromBackendlessUser(user: BackendlessUser) {
        
        if let imageLink = user.getProperty("Avatar"){
            
            getImageFromURL(imageLink as! String, result: { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                
                if self.avatarImageDictionary != nil {
                    self.avatarImageDictionary!.removeObjectForKey(user.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: user.objectId!)
                } else{
                    self.avatarImageDictionary = [user.objectId!: imageData!]
                }
                self.createAvatars(self.avatarImageDictionary)
            })
        }
        
    }
    
    func createAvatars(avatars: NSMutableDictionary?)
    {
        
        var users : [BackendlessUser] = []
        for i in 0..<withUser!.count{
            users.append(withUser![i])
        }
        users.append(backendless.userService.currentUser)
        
        
        for i in 0..<users.count{
            var userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
            if let images = avatars {
                if let withUserAvatarImage = images.objectForKey((users[i].objectId!)){
                    userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: (withUserAvatarImage as? NSData)!), diameter: 70)
                    
                    self.collectionView?.reloadData()
                }
            }
            let imageDitionary = [users[i].objectId : userImage]
            avatarDictionary?.addEntriesFromDictionary(imageDitionary)
        }
    }
    
    
    func loadMessage()
    {
        
        firebaseRef.child(chatRoomId).observeEventType(.ChildAdded, withBlock:  { snapshot in
            
            if snapshot.exists(){
                let item = (snapshot.value as? NSDictionary)!
                if self.initialLoadComplete {
                    
                    let incoming = self.insertSingleMessage(item)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    self.finishReceivingMessageAnimated(true)
                }else {
                    self.loaded.append(item)
                }
            }
            
        })
        
        firebaseRef.child(chatRoomId).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            //position for future need update messages
        })
        
        firebaseRef.child(chatRoomId).observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            // postion for future need delete messages
        })

        firebaseRef.child(chatRoomId).observeEventType(.Value, withBlock: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        })
    }
    
    func insertMessages(){
        
        for messsage in loaded {
            //create message
            insertSingleMessage(messsage)
        }
    }
    
    func insertSingleMessage(item : NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func incoming(item: NSDictionary)-> Bool {
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
}

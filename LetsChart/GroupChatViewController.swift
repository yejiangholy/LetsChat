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
    
    let ref = firebase.child("Message")
    
    var messages:[JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImageDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    var showAvatars:Bool = true
    var firstLoad: Bool?
    
    var withUser: [BackendlessUser]?
    var recent: NSDictionary?
    var groupName: String?
    var groupImage: UIImage?
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    override func viewWillAppear(animated: Bool) {
        
        loadUserDefaults()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        ClearRecentCounter(chatRoomId)
        
        ref.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        if withUser == nil {
            getWithUsersFromRecent(recent!, result: { (withUser) in
                self.withUser = withUser
               self.title = self.groupName
                self.getAvatar()
            })
        } else {
            self.title = self.groupName
            self.getAvatar()
        }
        
        loadMessage()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
    }
    
    //MARK: JSQMessage dataSrouce functions 
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId{
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == backendless.userService.currentUser.objectId{
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            
        }else {
            
            return nil
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        let status = message["status"] as! String
        
        if indexPath.row == (message.count - 1 ){
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if outgoing(objects[indexPath.row]){
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
            
        }else {
            
            return 0.0
        }
        
        
    }

    
    func outgoing(item: NSDictionary) ->Bool {
        if backendless.userService.currentUser.objectId == item["senderId"] as! String{
            return true
        }else {
            return false
        }
        
    }

    
    func getMessageAtIndex(messageArray:[JSQMessage], index: Int) -> JSQMessage
    {
        return messageArray[index]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar

    }
    
    
    // MARK: JSQMessage Delegate functions 
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        
        if text != "" {
            
            sendMessage(text, date: date, picture: nil, Location: nil)
            
        }
    }
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo" ,style: .Default) {(alert: UIAlertAction)->Void in
            
            camera.PresentPhoteCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Share Photo" ,style: .Default) {(alert: UIAlertAction)->Void in
            
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location" ,style: .Default) {(alert: UIAlertAction)->Void in
            
            if self.haveAccessToLocation(){
                self.sendMessage(nil, date: NSDate(), picture: nil, Location: "location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel" ,style: .Cancel) {(alert: UIAlertAction)->Void in
            print("Cancle")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true , completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func haveAccessToLocation() -> Bool{
        if (appDelegate?.coordinate?.latitude) != nil {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Send three different Messages 
    func sendMessage(text:String? , date: NSDate , picture: UIImage?, Location: String?){
        
        var outgoingMessage = OutgoingMessage?()
        
        if let textMessage = text {
            
            outgoingMessage = OutgoingMessage(message: textMessage, senderId: backendless.userService.currentUser.objectId, senderName: backendless.userService.currentUser.name, date: date , status: "Delivered", type: "text")
            
        }
        // if have picture message
        if let pic = picture {
            
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: backendless.userService.currentUser.objectId, senderName: backendless.userService.currentUser.name , date: date, status: "Delievered", type: "picture")
            
        }
        // if have location message
        if let location = Location{
            
            let latitude: NSNumber = NSNumber(double: (appDelegate?.coordinate?.latitude)!)
            let longitude: NSNumber = NSNumber(double: (appDelegate?.coordinate?.longitude)!)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: latitude, longitude:longitude, senderId: backendless.userService.currentUser.objectId, senderName: backendless.userService.currentUser.name, date: date, status: "Delivered", type: location)
        }
        
        //paly message sent sound 
       JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        
    }
    
    //MARK: JSQDelegate functions 
    //this function will be called when user tap our message 
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"] as? String == "picture" {
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        if object["type"] as? String == "location" {
            self.performSegueWithIdentifier("GroupChatToMapSeg", sender: indexPath)
        }
    }
    
    //MARK: UIIMagePickerController functions,(send image message here)
    //send image message
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, Location: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)

    }
    
    // MARK: prepareForSegue 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GroupChatToMapSeg" {
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            let mediaItem = message.media as? JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! MapViewController
            
            mapView.location = mediaItem?.location
        }
    }
    
// MARK: loadUserDefaults
    func loadUserDefaults() {
        
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
            if avatarDictionary == nil {
                avatarDictionary = [users[i].objectId : userImage]
            } else {
            avatarDictionary!.addEntriesFromDictionary(imageDitionary)
            }
           
        }
    }
    
    
    func loadMessage()
    {
        ref.child(chatRoomId).observeEventType(.ChildAdded, withBlock:  { snapshot in
            
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
        
        ref.child(chatRoomId).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            //position for future need update messages
        })
        
        ref.child(chatRoomId).observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            // postion for future need delete messages
        })

        ref.child(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        })
    }
    
    func insertMessages(){
        
        for item in loaded {
            //create message
            insertSingleMessage(item)
        }
    }
    
    func insertSingleMessage(item : NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(item)
        self.objects.append(item)
        self.messages.append(message!)
        
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

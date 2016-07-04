//
//  ChatViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/14/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    let ref = firebase.child("Message")

    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImageDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    var showAvatars:Bool = false
    var firstLoad: Bool?
    var backGround: UIImage?
    
    var withUser:BackendlessUser?
    var recent : NSDictionary?
    var chatRoomId: String!
    
    var initialloadComplete:Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    

    override func viewWillDisappear(animated: Bool) {
        
        //updateRecent
       ClearRecentCounter(chatRoomId)
        
        ref.removeAllObservers()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         loadUserDefaults()
        
        self.senderId = backendless.userService.currentUser.objectId
        self.senderDisplayName = backendless.userService.currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        if withUser?.objectId == nil {
            getWithUserFromRecent(recent!, result: { (withUser) in
                self.withUser = withUser
                self.title = withUser.name
                self.getAvatar()
            })
        } else {
            self.title = withUser!.name
            self.getAvatar()
        }
        
        //load firebase messages
        loadmessage()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
        if let image = backGround {
            
            self.collectionView.backgroundColor = UIColor(patternImage: image)
            
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    //MARK: JSQMessages dataSource functions 
    
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
        
        if data.senderId == backendless.userService.currentUser.objectId {
            
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        
        if indexPath.item % 3 == 0 {
            let message  = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }  else {
            return nil
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == (messages.count - 1){
            
            return NSAttributedString(string: status)
        }else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }  else {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //MARK: JSQMessages Delegate functions 
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if text != ""{
            
           sendMessage(text, date: date, picture: nil, Location: nil)
        }
            
    }
    
    
    
    @IBAction func EditBackgroundPressed(sender: UIBarButtonItem) {
        
         self.performSegueWithIdentifier("SingleChatToBackgound", sender: self)
    }
    
    
    @IBAction func BackgroundPressed(sender: UIButton) {
        
        self.performSegueWithIdentifier("SingleChatToBackgound", sender: self)
        
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
    
    // MARK: Send Message 
    func sendMessage(text:String?, date: NSDate, picture: UIImage? , Location: String? ) {
        //if text mesage 
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
        
        //play message sent sound 
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        
    }
    
    //MARK: Load Message 
    
    func loadmessage()
    {
        ref.child(chatRoomId).observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            if snapshot.exists(){
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialloadComplete {
                    
                    let incoming = self.insertSingleMessage(item)
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    self.finishReceivingMessageAnimated(true)
                    
                }else {
                    // add each dictionay to loaded array
                    self.loaded.append(item)
                }
            }
        })
        
        ref.child(chatRoomId).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            //update messages
        })
        
        ref.child(chatRoomId).observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            //delete messages
        })
        
        ref.child(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            //get dictionay
            // create JSQ mesages
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialloadComplete = true
        })


    }
    
    func  insertMessages() {
        for item in loaded {
            // create message
            insertSingleMessage(item)
            
        }
        
    }
    
    func insertSingleMessage(item: NSDictionary)-> Bool{
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        if backendless.userService.currentUser.objectId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) ->Bool {
        if backendless.userService.currentUser.objectId == item["senderId"] as! String{
            return true
        }else {
            return false
        }
        
    }
    //MARK: Helpers 
    
    func haveAccessToLocation()->Bool {
        if (appDelegate?.coordinate?.latitude) != nil {
            return true
        } else {
            return false
        }
        
    }
    
    func getAvatar() {
        
        if showAvatars{
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
            //download avatars 
            avatarImageFromBackendlessUser(backendless.userService.currentUser)
            avatarImageFromBackendlessUser(withUser!)
            
            //create avatars
            createAvatars(avatarImageDictionary)
        }
    }
    
    func getWithUserFromRecent(recent: NSDictionary, result: (withUser: BackendlessUser)-> Void){
        let withUserId = recent["withUserUserId"] as? String
        
        let whereClause = "objectId = '\(withUserId!)'"
        
        let dataQuery = BackendlessDataQuery()
        
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) -> Void in
            
            let withUser = users.data.first as! BackendlessUser
            
            result(withUser: withUser)
        }) {(fault: Fault!) -> Void in
            print("Server report an error :\(fault)")
        }
        
    }
    
    func createAvatars(avatars: NSMutableDictionary?){
        
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        
         var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if let images = avatars {
            if let currentUserAvatarImage = images.objectForKey(backendless.userService.currentUser.objectId){
                
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: (currentUserAvatarImage as? NSData)!), diameter: 70)
                
                self.collectionView?.reloadData()
                
            }
            
            if let withUserAvatarImage = images.objectForKey((withUser?.objectId!)!){
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: (withUserAvatarImage as? NSData)!), diameter: 70)
                
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [backendless.userService.currentUser.objectId : currentUserAvatar , (withUser?.objectId)! : withUserAvatar]
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
    
    //MARK: JSQDelegate funcitons 
    // this function will be called when user tap our message
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"]  as? String == "picture" {
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as? String == "location" {
            self.performSegueWithIdentifier("chatToMapSeg", sender: indexPath)
        }
        
    }
    
    //MARK: UIIMagePickerController functions 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, Location: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: Navigation 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            let mediaItem = message.media as? JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! MapViewController
            
            mapView.location = mediaItem?.location
        }
        
        if segue.identifier == "SingleChatToBackgound" {
            
            let singleBackground = segue.destinationViewController as! SingleBackgroundTableViewController
            
            singleBackground.chatRoomId = self.chatRoomId
        }
    }
    
    //MARK: userDefaults functions
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.boolForKey(KFIRSTRUN)
        
        if let imageDictionary  = userDefaults.dictionaryForKey("background"){
            
            let imageFromDefault = UIImage(data: imageDictionary[self.chatRoomId!] as! NSData, scale: 1.0)
            self.backGround =  imageFromDefault!
            self.collectionView.backgroundColor = UIColor(patternImage: imageFromDefault!)
            
        }

        
        if !(firstLoad!) {
            userDefaults.setBool(true, forKey: KFIRSTRUN)
            userDefaults.setBool(showAvatars, forKey: KAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.boolForKey(KAVATARSTATE)
    }

}
    
    



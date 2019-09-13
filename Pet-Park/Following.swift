/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Following: UIViewController,
GADInterstitialDelegate,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var streamsTableView: UITableView!
    var adMobInterstitial: GADInterstitial!
    
    
    
    /* Variables */
    var streamsArray = [PFObject]()
    var followArray = [PFObject]()


    
    
override func viewDidAppear(_ animated: Bool) {
    // Recall query in case something has been reported (either a User or a Stream)
    if mustRefresh {
        queryStreamsOfFollowing()
        mustRefresh = false
    }
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Call query
    if PFUser.current() != nil { queryStreamsOfFollowing() }
    
    // Layouts
    if UIDevice.current.userInterfaceIdiom == .pad {
        streamsTableView.frame.size.width = 500
        streamsTableView.center.x = view.center.x
    }
    
    
    // Call AdMob Interstitial
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_UNIT_ID)
    adMobInterstitial.load(GADRequest())
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        self.showInterstitial()
    })
}

   
    
    
// QUERY STREAMS FROM USERS YOU'RE FOLLOWING
func queryStreamsOfFollowing() {
    streamsArray.removeAll()
    followArray.removeAll()
    let currUser = PFUser.current()!
    showHUD("Please wait...")
    
    let query = PFQuery(className: FOLLOW_CLASS_NAME)
    query.whereKey(FOLLOW_CURR_USER, equalTo: currUser)
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.followArray = objects!
                
            // YOU'RE FOLLOWING SOMEONE
            if self.followArray.count != 0 {
                self.streamsTableView.isHidden = false
                
                for i in 0..<self.followArray.count {
                    DispatchQueue.main.async(execute: {
                            
                        var followObj = PFObject(className: FOLLOW_CLASS_NAME)
                        followObj = self.followArray[i]
                            
                        // Get userPointer
                        let userPointer = followObj[FOLLOW_IS_FOLLOWING] as! PFUser
                        userPointer.fetchIfNeededInBackground(block: { (user, error) in
                                
                            if userPointer[USER_IS_REPORTED] as! Bool == false {
                                let query = PFQuery(className: STREAMS_CLASS_NAME)
                                query.whereKey(STREAMS_USER_POINTER, equalTo: userPointer)
                                query.whereKey(STREAMS_REPORTED_BY, notContainedIn: [currUser.objectId!])
                                query.order(byDescending: "createdAt")
                                query.findObjectsInBackground { (objects, error)-> Void in
                                    if error == nil {
                                        if let objects = objects  {
                                            for post in objects {
                                                self.streamsArray.append(post)
                                        }}
                                            
                                        // Reload TableView (if there are some posts)
                                        self.streamsTableView.reloadData()
                                        self.hideHUD()
                                    }}
                                }
                            
                            })// end userPointer
                            
                        })// end DISPATCH_ASYNC
                        
                    }// end FOR LOOP
                    
                    
            // NO FOLLOWING YET
            } else {
                self.streamsTableView.isHidden = true
                self.hideHUD()
            }
                
                
        // Error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return streamsArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "StreamCell", for: indexPath) as! StreamCell
        
        // Get Parse Obj
        var sObj = PFObject(className: STREAMS_CLASS_NAME)
        sObj = streamsArray[indexPath.row]
        
        // Get User Pointer
        let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Stream image
                cell.thumbnailImg.layer.cornerRadius =  10
                if sObj[STREAMS_IMAGE] != nil {
                    getParseImage(sObj, imgView: cell.thumbnailImg, columnName: STREAMS_IMAGE)
                    cell.thumbnailImg.isHidden = false
                    cell.postlabel.frame.origin.y = 195
                    cell.postlabel.frame.size.height = 52
                    // No Stream image
                } else {
                    cell.thumbnailImg.isHidden = true
                    cell.postlabel.frame.origin.y = 68
                    cell.postlabel.frame.size.height = 174
                }
                
                // Get Stream text
                cell.postlabel.text = "\(sObj[STREAMS_TEXT]!)"
                
                // Get likes
                let likes = sObj[STREAMS_LIKES] as! Int
                cell.likesLabel.text = likes.abbreviated
                
                // Show liked icon
                let likedBy = sObj[STREAMS_LIKED_BY] as! [String]
                if likedBy.contains(PFUser.current()!.objectId!) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "liked_butt_small"), for: .normal)
                } else {
                    cell.likeButton.setBackgroundImage(UIImage(named: "like_butt_small"), for: .normal)
                }
                
                // Get nos
                let nos = sObj[STREAMS_NOS] as! Int
                cell.nosLabel.text = nos.abbreviated
                
                // Show nooed icon
                let nooedBy = sObj[STREAMS_NOOED_BY] as! [String]
                if nooedBy.contains(PFUser.current()!.objectId!) {
                    cell.noButton.setBackgroundImage(UIImage(named: "nooed_butt_small"), for: .normal)
                } else {
                    cell.noButton.setBackgroundImage(UIImage(named: "no_butt_small"), for: .normal)
                }
                
                // Get comments
                let comments = sObj[STREAMS_COMMENTS] as! Int
                cell.commentsLabel.text = comments.abbreviated
                
                
                
                // Get userPointer details
                cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
                cell.avatarImg.layer.borderWidth = 2
                cell.avatarImg.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
                getParseImage(userPointer, imgView: cell.avatarImg, columnName: USER_AVATAR)
                
                // Get verified badge if user got it
                let fullNameString = NSMutableAttributedString(string: "\(userPointer[USER_FULLNAME]!)  ")
                let image1Attachment = NSTextAttachment()
                image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullNameString.append(image1String)
                cell.fullnameLabel.attributedText = fullNameString
                
                
                if userPointer[USER_BADGE] != nil {
                    
                    cell.fullnameLabel.attributedText = fullNameString
                    //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
                    
                } else {  //get full name
                    cell.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                } //end verified badge
                
                let sDate = self.timeAgoSinceDate(sObj.createdAt!, currentDate: Date(), numericDates: true)
                cell.usernameTimeLabel.text = "@\(userPointer[USER_USERNAME]!) • \(sDate)"
                
                
                // Assign tags to the Buttons
                cell.avatarButton.tag = indexPath.row
                cell.likeButton.tag = indexPath.row
                cell.noButton.tag = indexPath.row
                cell.commentsButton.tag = indexPath.row
                cell.shareButton.tag = indexPath.row

                
            // error in userPointer
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }})// end userPointer
        
        return cell
    }
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 290
}
    
    
    
// MARK: - CELL TAPPED -> SHOW STREAM DETAILS
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Get Parse Obj
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[indexPath.row]
    let aVC = storyboard?.instantiateViewController(withIdentifier: "StreamDetails") as! StreamDetails
    aVC.sObj = sObj
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
    
    

    
// MARK: - LIKE BUTTON
@IBAction func likeButt(_ sender: UIButton) {
        // Get Parse Obj
        var sObj = PFObject(className: STREAMS_CLASS_NAME)
        sObj = streamsArray[sender.tag]
        let currUser = PFUser.current()!
        let indexP = IndexPath(row: sender.tag, section: 0)
        
        // Get likedBy
        var likedBy = sObj[STREAMS_LIKED_BY] as! [String]
        
        // UNLIKE THIS POST
        if likedBy.contains(currUser.objectId!) {
            likedBy = likedBy.filter{ $0 != currUser.objectId! }
            sObj[STREAMS_LIKED_BY] = likedBy
            sObj.incrementKey(STREAMS_LIKES, byAmount: -1)
            sObj.saveInBackground()
            
            sender.setBackgroundImage(UIImage(named:"like_butt_small"), for: .normal)
            let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
            let likes = sObj[STREAMS_LIKES] as! Int
            cell.likesLabel.text = likes.abbreviated
            
            
        // LIKE THIS POST
        } else {
            likedBy.append(currUser.objectId!)
            sObj[STREAMS_LIKED_BY] = likedBy
            sObj.incrementKey(STREAMS_LIKES, byAmount: 1)
            sObj.saveInBackground()
            
            sender.setBackgroundImage(UIImage(named:"liked_butt_small"), for: .normal)
            let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
            let likes = sObj[STREAMS_LIKES] as! Int
            cell.likesLabel.text = likes.abbreviated
            
            // Send push notification
            sendPushNotification(currentUser: currUser, pushMess: "liked your post: ", textColumn: STREAMS_TEXT, obj: sObj, userPointerColumn: STREAMS_USER_POINTER)
            
            // Save Activity
            saveActivity(currUser: currUser, streamObj: sObj, text: "liked your post: '\(sObj[STREAMS_TEXT]!)'")
        }
}
    
    // MARK: - NO BUTTON
    @IBAction func noButt(_ sender: UIButton) {
        // Get Parse Obj
        var sObj = PFObject(className: STREAMS_CLASS_NAME)
        sObj = streamsArray[sender.tag]
        let currUser = PFUser.current()!
        let indexP = IndexPath(row: sender.tag, section: 0)
        
        // Get nooedBy
        var nooedBy = sObj[STREAMS_NOOED_BY] as! [String]
        
        // UNLIKE THIS NO
        if nooedBy.contains(currUser.objectId!) {
            nooedBy = nooedBy.filter{ $0 != currUser.objectId! }
            sObj[STREAMS_NOOED_BY] = nooedBy
            sObj.incrementKey(STREAMS_NOS, byAmount: -1)
            sObj.saveInBackground()
            
            sender.setBackgroundImage(UIImage(named:"no_butt_small"), for: .normal)
            let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
            let nos = sObj[STREAMS_NOS] as! Int
            cell.nosLabel.text = nos.abbreviated
            
            
            // LIKE THIS NO
        } else {
            nooedBy.append(currUser.objectId!)
            sObj[STREAMS_NOOED_BY] = nooedBy
            sObj.incrementKey(STREAMS_NOS, byAmount: 1)
            sObj.saveInBackground()
            
            sender.setBackgroundImage(UIImage(named:"nooed_butt_small"), for: .normal)
            let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
            let nos = sObj[STREAMS_NOS] as! Int
            cell.nosLabel.text = nos.abbreviated
            
            // Send push notification
            sendPushNotification(currentUser: currUser, pushMess: "hit the no button on your post: ", textColumn: STREAMS_TEXT, obj: sObj, userPointerColumn: STREAMS_USER_POINTER)
            
            // Save Activity
            saveActivity(currUser: currUser, streamObj: sObj, text: "hit the no button on your post: '\(sObj[STREAMS_TEXT]!)'")
        }
    }
    
    
    
    
// MARK: - COMMENTS BUTTON
@IBAction func commentsButt(_ sender: UIButton) {
    // Get Parse Obj
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[sender.tag]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
    aVC.sObj = sObj
    present(aVC, animated: true, completion: nil)
}
    
    
    
    
// MARK: - SHARE BUTTON
@IBAction func shareButt(_ sender: UIButton) {
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[sender.tag]
        
    let indexP = IndexPath(row: sender.tag, section: 0)
    let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
    let streamImg = cell.thumbnailImg.image
    let streamText = cell.postlabel.text!

    let messageStr  = "\(streamText) on #PetPark"
    var img = UIImage()
    if sObj[STREAMS_IMAGE] != nil { img = streamImg!
    } else {  img = UIImage(named:"logo")! }
        
    let shareItems = [messageStr, img] as [Any]
        
    let actVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    actVC.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
        
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: actVC)
        popOver.present(from: CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: 0, height: 0), in: self.view, permittedArrowDirections: .down, animated: true)
    } else {
        // iPhone
        present(actVC, animated: true, completion: nil)
    }
    
    // Increment shares amount
    sObj.incrementKey(STREAMS_SHARES, byAmount: 1)
    sObj.saveInBackground()
}
    
    
 
    
// MARK: - AVATAR BUTTON
@IBAction func avatarButt(_ sender: UIButton) {
    // Get Parse Obj
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[sender.tag]
        
    // Get User Pointer
    let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
            aVC.userObj = userPointer
            self.navigationController?.pushViewController(aVC, animated: true)
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
}
    
 
    
    

// MARK: - REFRESH BUTTON
@IBAction func refreshButt(_ sender: Any) {
    // Recall query
    queryStreamsOfFollowing()
}
    
    

    
// MARK: - ADMOB INTERSTITIAL
func showInterstitial() {
    if adMobInterstitial.isReady {
        adMobInterstitial.present(fromRootViewController: self)
        print("AdMob Interstitial!")
    }
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

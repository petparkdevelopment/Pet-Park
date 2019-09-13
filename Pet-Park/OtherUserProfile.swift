/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/
import UIKit
import Parse


class OtherUserProfile: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{
    
    /* Views */
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var badgeImg: UIImageView!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    @IBOutlet weak var streamsTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var followOutlet: UIButton!
    
    
    
    /* Variables */
    var streamsArray = [PFObject]()
    var userObj = PFUser()
    
    
    
    
    
override func viewDidAppear(_ animated: Bool) {
    // Call queries
    showUserDetails()
    getFollowersAndFollowing()
    
    
    // Recall query in case something has been reported (either a User or a Stream)
    if mustRefresh {
        queryStreams()
        mustRefresh = false
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    
    // rounded
    usernameLabel.layer.cornerRadius = 10.0
    usernameLabel.layer.masksToBounds = true
    
    backButton.layer.cornerRadius = backButton.bounds.size.width/2
    backButton.layer.masksToBounds = true
    
    reportButton.layer.cornerRadius = reportButton.bounds.size.width/2
    reportButton.layer.masksToBounds = true
    
    // Layouts
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    avatarImg.layer.borderColor = UIColor.white.cgColor
    avatarImg.layer.borderWidth = 6
    
    followersLabel.layer.cornerRadius = 9
    followersLabel.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
    followersLabel.layer.borderWidth = 2
    
    followingLabel.layer.cornerRadius = 9
    followingLabel.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
    followingLabel.layer.borderWidth = 2
    
    followOutlet.layer.cornerRadius = 9
    followOutlet.layer.borderColor = MAIN_COLOR.cgColor
    followOutlet.layer.borderWidth = 2

    
    if UIDevice.current.userInterfaceIdiom == .pad {
        streamsTableView.frame.size.width = 500
        streamsTableView.center.x = view.center.x
    }
    
    
    
    // Init a Refresh Control
    refreshControl.tintColor = MAIN_COLOR
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    streamsTableView.addSubview(refreshControl)
    
    
    // Call query
    queryStreams()
}

    
    
    
// MARK: - SHOW USER'S DETAILS
func showUserDetails() {
    // Get username
    usernameLabel.text = "@\(userObj[USER_USERNAME]!)"
    // Get fullName
    fullNameLabel.text = "\(userObj[USER_FULLNAME]!)"
        
    // Get aboutMe
    if userObj[USER_ABOUT_ME] != nil {
        aboutMeLabel.text = "\(userObj[USER_ABOUT_ME]!)"
    } else { aboutMeLabel.text = "" }
    
    // Get avatar
    getParseImage(userObj, imgView: avatarImg, columnName: USER_AVATAR)
    
    // Get cover
    getParseImage(userObj, imgView: coverImg, columnName: USER_COVER_IMAGE)
    
    //Get verified badge
    getParseImage(userObj, imgView: badgeImg, columnName: USER_BADGE)
    
    
    // Set Follow Button
    let query = PFQuery(className: FOLLOW_CLASS_NAME)
    query.whereKey(FOLLOW_CURR_USER, equalTo: PFUser.current()!)
    query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            // You're following this user
            if objects!.count != 0 {
                self.followOutlet.setTitle("Following", for: .normal)
                self.followOutlet.backgroundColor = MAIN_COLOR
                self.followOutlet.setTitleColor(UIColor.white, for: .normal)
            // You're not following this user
            } else {
                self.followOutlet.setTitle("Follow", for: .normal)
                self.followOutlet.backgroundColor = UIColor.white
                self.followOutlet.setTitleColor(MAIN_COLOR, for: .normal)
            }
            
        // error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    

// MARK: - FOLLOW/UNFOLLOW BUTTON
@IBAction func followButt(_ sender: UIButton) {
    
    // FOLLOW USER --------------------------------
    if followOutlet.titleLabel?.text == "Follow" {
        let fObj = PFObject(className: FOLLOW_CLASS_NAME)
        let currUser = PFUser.current()!
        
        // Save data
        fObj[FOLLOW_CURR_USER] = currUser
        fObj[FOLLOW_IS_FOLLOWING] = userObj
        
        // Saving block
        fObj.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.followOutlet.setTitle("Following", for: .normal)
                self.followOutlet.backgroundColor = MAIN_COLOR
                self.followOutlet.setTitleColor(UIColor.white, for: .normal)

                // Send Push notification
                let pushStr = "\(currUser[USER_USERNAME]!) started following you!"
                let data = [ "badge" : "Increment",
                            "alert" : pushStr,
                            "sound" : "bingbong.aiff"
                ]
                let request = [
                        "someKey" : self.userObj.objectId!,
                        "data" : data
                ] as [String : Any]
                        
                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("\nPUSH SENT TO: \(self.userObj[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                }})
                
            // error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }})
        
        
    // UNFOLLOW USER ---------------------------------------
    } else {
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_CURR_USER, equalTo: PFUser.current()!)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                var fObj = PFObject(className: FOLLOW_CLASS_NAME)
                fObj = objects![0]
                fObj.deleteInBackground(block: { (succ, error) in
                    self.followOutlet.setTitle("Follow", for: .normal)
                    self.followOutlet.backgroundColor = UIColor.white
                    self.followOutlet.setTitleColor(MAIN_COLOR, for: .normal)
                })
        }}
    }
    
}
    

    
    
    
    
// MARK: - QUERY STREAMS
func queryStreams() {
    showHUD("Please wait...")
        
    let query = PFQuery(className: STREAMS_CLASS_NAME)
    query.whereKey(STREAMS_USER_POINTER, equalTo: userObj)
    query.limit = 10000
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.streamsArray = objects!
                self.hideHUD()
                self.streamsTableView.reloadData()
                // error
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
        
        
        
    // Get currUser details
    cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
    cell.avatarImg.layer.borderWidth = 2
    cell.avatarImg.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
    getParseImage(userObj, imgView: cell.avatarImg, columnName: USER_AVATAR)
        
    // Get verified badge if user got it
    let fullNameString = NSMutableAttributedString(string: "\(userObj[USER_FULLNAME]!)  ")
    let image1Attachment = NSTextAttachment()
    image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
    let image1String = NSAttributedString(attachment: image1Attachment)
    fullNameString.append(image1String)
    cell.fullnameLabel.attributedText = fullNameString
    
    
    if userObj[USER_BADGE] != nil {
        
        cell.fullnameLabel.attributedText = fullNameString
        //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
        
    } else {  //get full name
        cell.fullnameLabel.text = "\(userObj[USER_FULLNAME]!)"
    } //end verified badge
        
    let sDate = self.timeAgoSinceDate(sObj.createdAt!, currentDate: Date(), numericDates: true)
    cell.usernameTimeLabel.text = "@\(userObj[USER_USERNAME]!) • \(sDate)"
        
        
    // Assign tags to the Buttons
    cell.likeButton.tag = indexPath.row
    cell.noButton.tag = indexPath.row
    cell.commentsButton.tag = indexPath.row
    cell.shareButton.tag = indexPath.row
    
        
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
        
    // UNLIKE THIS STREAM
    if likedBy.contains(currUser.objectId!) {
        likedBy = likedBy.filter{ $0 != currUser.objectId! }
        sObj[STREAMS_LIKED_BY] = likedBy
        sObj.incrementKey(STREAMS_LIKES, byAmount: -1)
        sObj.saveInBackground()
        
        sender.setBackgroundImage(UIImage(named:"like_butt_small"), for: .normal)
        let cell = streamsTableView.cellForRow(at: indexP) as! StreamCell
        let likes = sObj[STREAMS_LIKES] as! Int
        cell.likesLabel.text = likes.abbreviated
            
            
    // LIKE THIS STREAM
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
            
            
            // LIKE THIS STREAM
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
            sendPushNotification(currentUser: currUser, pushMess: "downvoted your post: ", textColumn: STREAMS_TEXT, obj: sObj, userPointerColumn: STREAMS_USER_POINTER)
            
            // Save Activity
            saveActivity(currUser: currUser, streamObj: sObj, text: "downvoted your post: '\(sObj[STREAMS_TEXT]!)'")
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
    
    
    
   

    
    
    
// MARK: - GET FOLLOWERS AND FOLLOWING AMOUNT
func getFollowersAndFollowing() {
    
        // QUERY FOLLOWERS
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
        query.order(byDescending: "createdAt")
        query.countObjectsInBackground(block: { (amount, error) in
            if error == nil {
                let foll = Int(amount).abbreviated
                self.followersLabel.text = "\(foll) followers"
                
                
                // QUERY FOLLOWING
                let query2 = PFQuery(className: FOLLOW_CLASS_NAME)
                query2.whereKey(FOLLOW_CURR_USER, equalTo: self.userObj)
                query2.order(byDescending: "createdAt")
                query2.countObjectsInBackground(block: { (amount, error) in
                    if error == nil {
                        let foll = Int(amount).abbreviated
                        self.followingLabel.text = "\(foll) following"
                        
                        // Set Follow button
                        
                }})
        }})
}
    
    
    
    
    
// MARK: - FOLLOWING BUTTON
@IBAction func followingButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
    aVC.isFollowing = true
    aVC.userObj = userObj
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
// MAKR: - FOLLOWERS BUTTON
@IBAction func followersButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
    aVC.isFollowing = false
    aVC.userObj = userObj
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
    
   
 
// MARK: - REPORT USER BUTTON
@IBAction func reportUserButt(_ sender: Any) {
    let currUser = PFUser.current()!
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to report @\(userObj[USER_USERNAME]!)?",
        preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
        
        self.showHUD("Reporting User...")
        
        let request = [
            "userId" : self.userObj.objectId!,
            "reportMessage" : "OFFENSIVE USER"
            ] as [String : Any]
        
        PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
            if error == nil {
                print ("\(self.userObj[USER_USERNAME]!) has been reported!")
                
                self.simpleAlert("Thanks for reporting this user, we'll check it out within 24 hours!")
                self.hideHUD()
                mustRefresh = true
                
                
                
                // Automatically report all User's streams
                let query = PFQuery(className: STREAMS_CLASS_NAME)
                query.whereKey(STREAMS_USER_POINTER, equalTo: self.userObj)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        for i in 0..<objects!.count {
                            var stObj = PFObject(className: STREAMS_CLASS_NAME)
                            stObj = objects![i]
                            var reportedBy = stObj[STREAMS_REPORTED_BY] as! [String]
                            reportedBy.append(currUser.objectId!)
                            stObj[STREAMS_REPORTED_BY] = reportedBy
                            stObj.saveInBackground()
                        }
                }}
                
                
                // Automatically report all User's comments
                let query2 = PFQuery(className: COMMENTS_CLASS_NAME)
                query2.whereKey(COMMENTS_USER_POINTER, equalTo: self.userObj)
                query2.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        for i in 0..<objects!.count {
                            var commObj = PFObject(className: COMMENTS_CLASS_NAME)
                            commObj = objects![i]
                            var reportedBy = commObj[COMMENTS_REPORTED_BY] as! [String]
                            reportedBy.append(currUser.objectId!)
                            commObj[COMMENTS_REPORTED_BY] = reportedBy
                            commObj.saveInBackground()
                        }
                }}
                
            // error in Cloud Code
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
        }})
        
    })
    
    // Cancel
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
       
    alert.addAction(ok)
    alert.addAction(cancel)
    self.present(alert, animated: true, completion: nil)
}
    

    
    
    
    
// MARK: - MESSAGE BUTTON
@IBAction func messageButt(_ sender: Any) {
    let currUser = PFUser.current()!
    let blockedUsers = userObj[USER_HAS_BLOCKED] as! [String]
    
    // THIS USER HAS BLOCKED YOU!
    if blockedUsers.contains(currUser.objectId!) {
        simpleAlert("Sorry, @\(userObj[USER_USERNAME]!) has blocked you. You can't chat with this user.")
        
    // YOU CAN CHAT WITH THIS USER
    } else {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Inbox") as! Inbox
        aVC.userObj = userObj
        present(aVC, animated: true, completion: nil)
    }
}
    

    
    
    
    
// MARK: - REFRESH DATA
@objc func refreshTB () {
    // Recall query
    queryStreams()
        
    if refreshControl.isRefreshing {
        refreshControl.endRefreshing()
    }
}
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

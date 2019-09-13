/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse


class Account: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addStreamButton: UIButton!
    @IBOutlet weak var badgeImg: UIImageView!
    
    @IBOutlet weak var streamsTableView: UITableView!
    let refreshControl = UIRefreshControl()

    
    
    /* Variables */
    var streamsArray = [PFObject]()
    
    
    
    
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
    
    settingsButton.layer.cornerRadius = settingsButton.bounds.size.width/2
    settingsButton.layer.masksToBounds = true
    
    addStreamButton.layer.cornerRadius = addStreamButton.bounds.size.width/2
    addStreamButton.layer.masksToBounds = true
    
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
    let currUser = PFUser.current()!
    
    //Get verified badge
    if currUser[USER_BADGE] != nil {
        
        getParseImage(currUser, imgView: badgeImg, columnName: USER_BADGE)
        
    } else {
        badgeImg.image = nil
    }
    
    // Get username
    usernameLabel.text = "@\(currUser[USER_USERNAME]!)"
    // Get fullName
    fullNameLabel.text = "\(currUser[USER_FULLNAME]!)"
    
    // Get aboutMe
    if currUser[USER_ABOUT_ME] != nil {
        aboutMeLabel.text = "\(currUser[USER_ABOUT_ME]!)"
    } else { aboutMeLabel.text = "" }
    
    // Get avatar
    getParseImage(currUser, imgView: avatarImg, columnName: USER_AVATAR)

    // Get cover
    if currUser[USER_COVER_IMAGE] != nil {
        getParseImage(currUser, imgView: coverImg, columnName: USER_COVER_IMAGE)
    } else {
        coverImg.image = UIImage(named: "default banner")
    }

}
    

    
    

    
    
// MARK: - QUERY STREAMS
func queryStreams() {
    showHUD("Please wait...")
    let currUser = PFUser.current()!
        
    let query = PFQuery(className: STREAMS_CLASS_NAME)
    query.whereKey(STREAMS_USER_POINTER, equalTo: currUser)
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
    let currUser = PFUser.current()!
    
    
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
    getParseImage(currUser, imgView: cell.avatarImg, columnName: USER_AVATAR)
    
    
    // Get verified badge if user got it
    let fullNameString = NSMutableAttributedString(string: "\(currUser[USER_FULLNAME]!)  ")
    let image1Attachment = NSTextAttachment()
    image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
    let image1String = NSAttributedString(attachment: image1Attachment)
    fullNameString.append(image1String)
    cell.fullnameLabel.attributedText = fullNameString
    
    
    if currUser[USER_BADGE] != nil {
        
        cell.fullnameLabel.attributedText = fullNameString
        //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
        
    } else {  //get full name
        cell.fullnameLabel.text = "\(currUser[USER_FULLNAME]!)"
    } //end verified badge
                
    let sDate = self.timeAgoSinceDate(sObj.createdAt!, currentDate: Date(), numericDates: true)
    cell.usernameTimeLabel.text = "@\(currUser[USER_USERNAME]!) • \(sDate)"
                
                
    // Assign tags to the Buttons
    cell.likeButton.tag = indexPath.row
    cell.noButton.tag = indexPath.row
    cell.commentsButton.tag = indexPath.row
    cell.shareButton.tag = indexPath.row
    cell.statsButton.tag = indexPath.row
    cell.deleteStreamButton.tag = indexPath.row

    
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
    
    
    
    
    
  
// MARK: - STATISTICS BUTTON
@IBAction func statsButt(_ sender: UIButton) {
    // Get Parse Obj
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[sender.tag]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Statistics") as! Statistics
    aVC.sObj = sObj
    present(aVC, animated: true, completion: nil)
}
    

    
    
    
    
// MARK: - DELETE STREAM BUTTON
@IBAction func deleteStreamButt(_ sender: UIButton) {
    // Get Parse Obj
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    sObj = streamsArray[sender.tag]
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to delete this post?",
        preferredStyle: .alert)
    
    
    // DELETE STREAM --------------------------------------------
    let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
       
        self.showHUD("Please wait...")
        
        sObj.deleteInBackground(block: { (succ, error) in
            if error == nil {
                let indexP = IndexPath(row: sender.tag, section: 0)
                self.streamsArray.remove(at: sender.tag)
                self.streamsTableView.deleteRows(at: [indexP], with: .fade)
            
                self.hideHUD()
                mustRefresh = true
                
                
                // Delete those rows from the Activity class which have this Stream as a Pointer
                let query = PFQuery(className: ACTIVITY_CLASS_NAME)
                query.whereKey(ACTIVITY_STREAM_POINTER, equalTo: sObj)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        for i in 0..<objects!.count {
                            var aObj = PFObject(className: ACTIVITY_CLASS_NAME)
                            aObj = objects![i]
                            aObj.deleteInBackground()
                        }
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                        self.hideHUD()
                }}
                
                
            // error on deletion
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
        }})
    })
    
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
    
    alert.addAction(delete)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    

    
    
    

// MARK: - ADD STREAM BUTTON
@IBAction func addStreamButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "AddStream") as! AddStream
    present(aVC, animated: true, completion: nil)
}
    
    
    
    
    
    
    
    
// MARK: - GET FOLLOWERS AND FOLLOWING AMOUNT
func getFollowersAndFollowing() {
    let currUser = PFUser.current()!
    
    // QUERY FOLLOWERS
    let query = PFQuery(className: FOLLOW_CLASS_NAME)
    query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: currUser)
    query.order(byDescending: "createdAt")
    query.countObjectsInBackground(block: { (amount, error) in
        if error == nil {
            let foll = Int(amount).abbreviated
            self.followersLabel.text = "\(foll) followers"
    
            // QUERY FOLLOWING
            let query2 = PFQuery(className: FOLLOW_CLASS_NAME)
            query2.whereKey(FOLLOW_CURR_USER, equalTo: currUser)
            query2.order(byDescending: "createdAt")
            query2.countObjectsInBackground(block: { (amount, error) in
                if error == nil {
                    let foll = Int(amount).abbreviated
                    self.followingLabel.text = "\(foll) following"
            }})
    }})
    
    
}
    
    
    
    
 
// MARK: - FOLLOWING BUTTON
@IBAction func followingButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
    aVC.isFollowing = true
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
   
// MAKR: - FOLLOWERS BUTTON
@IBAction func followersButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
    aVC.isFollowing = false
    navigationController?.pushViewController(aVC, animated: true)
}

    
    
    
    
    
    
    
// MARK: - SETTINGS BUTTON
@IBAction func settingsButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Settings") as! Settings
    navigationController?.pushViewController(aVC, animated: true)
}

    
    
    
  
// MARK: - REFRESH DATA
@objc func refreshTB () {
    // Recall query
    queryStreams()
        
    if refreshControl.isRefreshing {
        refreshControl.endRefreshing()
    }
}
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

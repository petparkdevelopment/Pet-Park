/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import AVFoundation
import AVKit


// MARK: - STREAM DETAILS CONTROLLER
class StreamDetails: UIViewController,
AVAudioPlayerDelegate, UIScrollViewDelegate
{

    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //scroll
    @IBOutlet weak var containerScrollView: UIScrollView!
    //
    @IBOutlet weak var streamTxt: UITextView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var likeOutlet: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var noOutlet: UIButton!
    @IBOutlet weak var nosLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    //image
    @IBOutlet weak var streamImg: UIImageView!
    //
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playingTimeLabel: UILabel!
    
    
    
    /* Variables */
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    var audioPlayer:AVAudioPlayer!
    var audioIsPlaying = false
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()
    
    // Call queries
    showUserAndStreamDetails()
}

    

// MARK: - SHOW STREAM AND  USER DETAILS
func showUserAndStreamDetails() {
    let currUser = PFUser.current()!
    
    // Increment Stream views
    sObj.incrementKey(STREAMS_VIEWS, byAmount: 1)
    sObj.saveInBackground()
    
    
    // Get User Pointer
    let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            // Get full name
            //self.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
            
            // Get Avatar
            self.avatarImg.layer.cornerRadius = self.avatarImg.bounds.size.width/2
            self.avatarImg.layer.borderWidth = 2
            self.avatarImg.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
            getParseImage(userPointer, imgView: self.avatarImg, columnName: USER_AVATAR)
            
            // Get verified badge if user got it
            let fullNameString = NSMutableAttributedString(string: "\(userPointer[USER_FULLNAME]!)  ")
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullNameString.append(image1String)
            self.fullnameLabel.attributedText = fullNameString
            
            
            if userPointer[USER_BADGE] != nil {
                
                self.fullnameLabel.attributedText = fullNameString
                //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
                
            } else {  //get full name
                self.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
            } //end verified badge
            
            // Get Stream Date
            self.usernameLabel.text = "@\(userPointer[USER_USERNAME]!)"

            // Get Stream text
            self.streamTxt.text = "\(self.sObj[STREAMS_TEXT]!)"
            self.streamTxt.sizeToFit()
            
            
            // Get like/liked
            let likedBy = self.sObj[STREAMS_LIKED_BY] as! [String]
            if likedBy.contains(currUser.objectId!) {
                self.likeOutlet.setBackgroundImage(UIImage(named:"liked_butt_small"), for: .normal)
            } else {
                self.likeOutlet.setBackgroundImage(UIImage(named:"like_butt_small"), for: .normal)
            }
            
            // Get Likes
            let likes = self.sObj[STREAMS_LIKES] as! Int
            self.likesLabel.text = likes.abbreviated
            
            // Get no/nooed
            let nooedBy = self.sObj[STREAMS_NOOED_BY] as! [String]
            if nooedBy.contains(currUser.objectId!) {
                self.noOutlet.setBackgroundImage(UIImage(named:"nooed_butt_small"), for: .normal)
            } else {
                self.noOutlet.setBackgroundImage(UIImage(named:"no_butt_small"), for: .normal)
            }
            
            // Get Nos
            let nos = self.sObj[STREAMS_NOS] as! Int
            self.nosLabel.text = nos.abbreviated
            
            // Get Comments
            let comments = self.sObj[STREAMS_COMMENTS] as! Int
            self.commentsLabel.text = comments.abbreviated
            
            
            // Get Stream Image (if any)
            if self.sObj[STREAMS_IMAGE] != nil {
                getParseImage(self.sObj, imgView: self.streamImg, columnName: STREAMS_IMAGE)
                self.imageContainerView.frame.size.height = 290
                self.imageContainerView.isHidden = false
            } else {
                self.imageContainerView.frame.size.height = 1
                self.imageContainerView.isHidden = true
            }
            
            // Get Stream Video (if any)
            if self.sObj[STREAMS_VIDEO] != nil {
                self.playButton.isHidden = false
            }
            
            // Get Stream Audio (if any)
            if self.sObj[STREAMS_AUDIO] != nil {
                self.playButton.isHidden = false
                self.playingTimeLabel.isHidden = false
            }
            
            
            // Move the imageContainerView to the bottom of the streamTxt
            self.imageContainerView.frame.origin.y = self.streamTxt.frame.origin.y + self.streamTxt.frame.size.height + 10
            
            // Move optionsView and containerScrollView
            self.optionsView.frame.origin.y = self.imageContainerView.frame.origin.y + self.imageContainerView.frame.size.height + 10
            
            self.containerScrollView.contentSize = CGSize(
                width: self.containerScrollView.frame.size.width,
                height: self.optionsView.frame.origin.y + self.optionsView.frame.size.height + 10)
            
            
        // error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userPointer
}
    

    
    
  
// MARK: - PLAY VIDEO OR AUDIO BUTTON
@IBAction func playVideoAudioButt(_ sender: Any) {
    
        // PLAY VIDEO
        if sObj[STREAMS_VIDEO] != nil {
            let videoFile = sObj[STREAMS_VIDEO] as! PFFile
            let videoURL = URL(string: videoFile.url!)
            print("VIDEO URL: \(String(describing: videoURL!))")
            
            let player = AVPlayer(url: videoURL!)
            let pVC = AVPlayerViewController()
            pVC.player = player
            self.present(pVC, animated: true) {
                pVC.player!.play()
            }
            
        // PLAY AUDIO
        } else if sObj[STREAMS_AUDIO] != nil {
            let audioFile = sObj[STREAMS_AUDIO] as! PFFile
            audioFile.getDataInBackground(block: { (audioData, error) in
                if error == nil {
                    if !self.audioIsPlaying {
                        self.audioPlayer = try? AVAudioPlayer(data: audioData!)
                        self.audioPlayer?.delegate = self
                        self.audioPlayer?.play()
                        self.audioIsPlaying = true
                        
                        // Call timer to update the playing time
                        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayingTime), userInfo: nil, repeats: true)
                        
                        // Set stop button icon
                        self.playButton.setBackgroundImage(UIImage(named:"stop_butt"), for: .normal)
                    } else {
                        self.audioIsPlaying = false
                        self.audioPlayer?.stop()
                        self.playButton.setBackgroundImage(UIImage(named:"play_butt"), for: .normal)
                        self.playingTimeLabel.text = "0:0"
                    }
            }})
        }
}
    
    
// Audio Player finish playing
func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    audioIsPlaying = false
    playButton.setBackgroundImage(UIImage(named:"play_butt"), for: .normal)
    playingTimeLabel.text = "0:0"
}
    
 
// MARK: - UPDATE PLAYING TIME LABEL
@objc func updatePlayingTime() {
    let minutes = floor(audioPlayer.currentTime/60)
    let seconds = audioPlayer.currentTime - (minutes * 60)
    let time = String(format: "%0.0f:%0.0f", minutes, seconds)
    playingTimeLabel.text = time
}
    
    
    
    
    
    
    
    
// MARK: - STREAM USER AVATAR BUTTON
@IBAction func streamUserAvatarButt(_ sender: Any) {
    // Get User Pointer
    let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            // Increment Profile clicks
            self.sObj.incrementKey(STREAMS_PROFILE_CLICKS, byAmount: 1)
            self.sObj.saveInBackground()
            
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
            aVC.userObj = userPointer
            self.navigationController?.pushViewController(aVC, animated: true)
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userPointer
}
    
    
    
    
  
    
// MARK: - LIKE STREAM BUTTON
@IBAction func likeStreamButt(_ sender: UIButton) {
    let currUser = PFUser.current()!
    
    // Get likedBy
    var likedBy = sObj[STREAMS_LIKED_BY] as! [String]
    
    //var nooedBy = sObj[STREAMS_NOOED_BY] as! [String]
    
    // UNLIKE THIS STREAM
    if likedBy.contains(currUser.objectId!) {
        likedBy = likedBy.filter{ $0 != currUser.objectId! }
        sObj[STREAMS_LIKED_BY] = likedBy
        sObj.incrementKey(STREAMS_LIKES, byAmount: -1)
        sObj.saveInBackground()
        
        likeOutlet.setBackgroundImage(UIImage(named:"like_butt_small"), for: .normal)
        let likes = sObj[STREAMS_LIKES] as! Int
        likesLabel.text = likes.abbreviated
        
        
    // LIKE THIS STREAM
    } else {
        //sObj.incrementKey(STREAMS_NOS, byAmount: -1)
        likedBy.append(currUser.objectId!)
        sObj[STREAMS_LIKED_BY] = likedBy
        sObj.incrementKey(STREAMS_LIKES, byAmount: 1)
        sObj.saveInBackground()
        
        likeOutlet.setBackgroundImage(UIImage(named:"liked_butt_small"), for: .normal)
        let likes = sObj[STREAMS_LIKES] as! Int
        likesLabel.text = likes.abbreviated
        
        // Send push notification
        sendPushNotification(currentUser: currUser, pushMess: "liked your post: ", textColumn: STREAMS_TEXT, obj: sObj, userPointerColumn: STREAMS_USER_POINTER)
        
        // Save Activity
        saveActivity(currUser: currUser, streamObj: sObj, text: "liked your post: '\(sObj[STREAMS_TEXT]!)'")
    }
}
    
    // MARK: - NO STREAM BUTTON
    @IBAction func noStreamButt(_ sender: UIButton) {
        let currUser = PFUser.current()!
        
        // Get nooedBy
        var nooedBy = sObj[STREAMS_NOOED_BY] as! [String]
        
        
        // remove dislike
        if nooedBy.contains(currUser.objectId!) {
            nooedBy = nooedBy.filter{ $0 != currUser.objectId! }
            sObj[STREAMS_NOOED_BY] = nooedBy
            sObj.incrementKey(STREAMS_NOS, byAmount: -1)
            sObj.saveInBackground()
            
            noOutlet.setBackgroundImage(UIImage(named:"no_butt_small"), for: .normal)
            let nos = sObj[STREAMS_NOS] as! Int
            nosLabel.text = nos.abbreviated
            
            
            // dislike
        } else {
            
            
            
            nooedBy.append(currUser.objectId!)
            sObj[STREAMS_NOOED_BY] = nooedBy
            sObj.incrementKey(STREAMS_NOS, byAmount: 1)
            sObj.saveInBackground()
            
            noOutlet.setBackgroundImage(UIImage(named:"nooed_butt_small"), for: .normal)
            let nos = sObj[STREAMS_NOS] as! Int
            nosLabel.text = nos.abbreviated
            
            // Send push notification
            sendPushNotification(currentUser: currUser, pushMess: "downvoted your post: ", textColumn: STREAMS_TEXT, obj: sObj, userPointerColumn: STREAMS_USER_POINTER)
            
            // Save Activity
            saveActivity(currUser: currUser, streamObj: sObj, text: "downvoted your post: '\(sObj[STREAMS_TEXT]!)'")
        }
    }
    
    
    
    
   
// MARK: - COMMENTS BUTTON
@IBAction func commentsButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
        aVC.sObj = sObj
    present(aVC, animated: true, completion: nil)

}

    
    
 
// MARK: - SHARE STREAM BUTTON
@IBAction func shareStreamButt(_ sender: Any) {
    let messageStr  = "\(sObj[STREAMS_TEXT]!) on #ACYNICREPRISE"
    var img = UIImage()
    if sObj[STREAMS_IMAGE] != nil { img = streamImg.image!
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
}
    
    
    

   
// MARK: - OPTIONS BUTTON
@IBAction func optionsButt(_ sender: Any) {
    let currUser = PFUser.current()!
    
    // Get User Pointer
    let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            let alert = UIAlertController(title: APP_NAME,
                message: "Select option",
                preferredStyle: .alert)
            
            
            // REPORT STREAM -----------------------------------
            let reportStream = UIAlertAction(title: "Report Post", style: .default, handler: { (action) -> Void in
                
                    let alert = UIAlertController(title: APP_NAME,
                        message: "Are you sure you want to report this post to the Admin?",
                        preferredStyle: .alert)
                
                    let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
                    
                        self.showHUD("Reporting post...")
                        var reportedBy = self.sObj[STREAMS_REPORTED_BY] as! [String]
                        reportedBy.append(currUser.objectId!)
                        self.sObj[STREAMS_REPORTED_BY] = reportedBy
                        
                        self.sObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.hideHUD()
                                self.simpleAlert("Thanks for reporting this post, we'll check it out withint 24 hours!")
                                mustRefresh = true
                        }})
                    })
                
                // Cancel
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            
            })
            
            
            
            
            
            // REPORT USER BUTTON ----------------------------------------
            let reportUser = UIAlertAction(title: "Report @\(userPointer[USER_USERNAME]!)", style: .default, handler: { (action) -> Void in
                
                let alert = UIAlertController(title: APP_NAME,
                    message: "Are you sure you want to report @\(userPointer[USER_USERNAME]!) to the Admin?",
                    preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
                    
                    self.showHUD("Reporting User...")
                    
                    let request = [
                        "userId" : userPointer.objectId!,
                        "reportMessage" : "OFFENSIVE USER"
                        ] as [String : Any]
                    
                    PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
                        if error == nil {
                            print ("\(userPointer[USER_USERNAME]!) has been reported!")
                            
                            self.simpleAlert("Thanks for reporting this User, we'll check it out withint 24 hours!")
                            self.hideHUD()
                            mustRefresh = true
                            
                            
                            
                            // Automatically report all User's streams
                            let query = PFQuery(className: STREAMS_CLASS_NAME)
                            query.whereKey(STREAMS_USER_POINTER, equalTo: userPointer)
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
                            query2.whereKey(COMMENTS_USER_POINTER, equalTo: userPointer)
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
                
            })
            
            
            
            

            
            
            // CANCEL BUTTON ----------------------------------------
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

            // Add alert Actions
            alert.addAction(reportStream)
            reportStream.setValue(UIImage(named:"report_butt"), forKey: "image")
            
            alert.addAction(reportUser)
            reportUser.setValue(UIImage(named:"tab_account"), forKey: "image")
            
            
            
            // DELETE STREAM (IF IT'S YOURS) -----------------------------------------
            if userPointer.objectId == currUser.objectId {
                let deleteStream = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) -> Void in
                    
                    self.showHUD("Please wait..")
                    self.sObj.deleteInBackground(block: { (succ, error) in
                        if error == nil {
                            self.hideHUD()
                            mustRefresh = true
                            
                            
                            // Delete those rows from the Activity class which have this Stream as a Pointer
                            let query = PFQuery(className: ACTIVITY_CLASS_NAME)
                            query.whereKey(ACTIVITY_STREAM_POINTER, equalTo: self.sObj)
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
                            
                            
                            _ = self.navigationController?.popViewController(animated: true)
                        // error
                        } else {
                            self.hideHUD()
                            self.simpleAlert(error!.localizedDescription)
                        }
                    })
                })
                
                alert.addAction(deleteStream)
                deleteStream.setValue(UIImage(named:"dismiss_butt_black"), forKey: "image")
            }
            
            
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            
        // error in userPointer
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userPointer

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

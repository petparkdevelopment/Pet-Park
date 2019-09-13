/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox



// MARK: - COMMENT CELL
class CommentCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var cFullNameLabel: UILabel!
    @IBOutlet weak var cDateLabel: UILabel!
    @IBOutlet weak var cAvatarButton: UIButton!
    @IBOutlet weak var cOptionsButton: UIButton!
}




// MARK: - COMMENTS CONTROLLER
class Comments: UIViewController,
GADInterstitialDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
UITextViewDelegate
{
    /* Views */
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var streamTextLabel: UILabel!
    @IBOutlet weak var fakeTxt: UITextField!
    let commentTxt = UITextView()
    let refreshControl = UIRefreshControl()
    var adMobInterstitial: GADInterstitial!

    
    
    /* Variables */
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    var commentsArray = [PFObject]()
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Get User Pointer
    let userPointer = sObj[STREAMS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            // Get full name
            self.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
            
            // Get Stream text
            self.streamTextLabel.text = "\(self.sObj[STREAMS_TEXT]!)"
            
            // Call query
            self.queryComments()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userPointer
    
    
    
    // Init a refresh Control
    refreshControl.tintColor = UIColor.black
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    commentsTableView.addSubview(refreshControl)
    

    
    // Init a keyboard toolbar
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 48))
    toolbar.backgroundColor = LIGHT_BLUE
    
    let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 2, width: 44, height: 44))
    doneButt.setBackgroundImage(UIImage(named:"dismiss_butt_black"), for: .normal)
    doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(doneButt)
    
    let sendButton = UIButton(frame: CGRect(x: toolbar.frame.size.width - doneButt.frame.size.width - 60, y: 2, width: 44, height: 44))
    sendButton.setBackgroundImage(UIImage(named:"send_butt"), for: .normal)
    sendButton.addTarget(self, action: #selector(sendButt), for: .touchUpInside)
    toolbar.addSubview(sendButton)
    
    
    commentTxt.frame = CGRect(x: 8, y: 4, width: toolbar.frame.size.width - 120, height: 40)
    commentTxt.backgroundColor = UIColor.white
    commentTxt.textColor = UIColor.black
    commentTxt.font = UIFont(name: "Titillium-Regular", size: 13)
    commentTxt.clipsToBounds = true
    commentTxt.layer.cornerRadius = 5
    commentTxt.keyboardAppearance = .light
    commentTxt.autocapitalizationType = .none
    commentTxt.autocorrectionType = .no
    commentTxt.tintColor = .black
    toolbar.addSubview(commentTxt)
    
    
    fakeTxt.inputAccessoryView = toolbar
    fakeTxt.delegate = self
    
    
    
    // Call AdMob Interstitial
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_UNIT_ID)
    adMobInterstitial.load(GADRequest())
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        self.showInterstitial()
    })
}

   

    
// MARK: - QUERY COMMENTS
func queryComments() {
    showHUD("Please wait...")
    let currUser = PFUser.current()!
    
    let query = PFQuery(className: COMMENTS_CLASS_NAME)
    query.whereKey(COMMENTS_STREAM_POINTER, equalTo: sObj)
    query.whereKey(COMMENTS_REPORTED_BY, notContainedIn: [currUser.objectId!])
    query.addDescendingOrder("createdAt")
    query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.commentsArray = objects!
                self.hideHUD()
                self.commentsTableView.reloadData()
                // error
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentsArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
    var cObj = PFObject(className: COMMENTS_CLASS_NAME)
    cObj = commentsArray[indexPath.row]
        
        // Get User Pointer
        let userPointer = cObj[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Avatar
                cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
                getParseImage(userPointer, imgView: cell.avatarImg, columnName: USER_AVATAR)
                
                // Get full name
                // Get verified badge if user got it
                let fullNameString = NSMutableAttributedString(string: "\(userPointer[USER_FULLNAME]!)  ")
                let image1Attachment = NSTextAttachment()
                image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullNameString.append(image1String)
                cell.cFullNameLabel.attributedText = fullNameString
                
                
                if userPointer[USER_BADGE] != nil {
                    
                    cell.cFullNameLabel.attributedText = fullNameString
                    //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
                    
                } else {  //get full name
                    cell.cFullNameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                } //end verified badge
                //cell.cFullNameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                
                // Get comment
                cell.commentTxt.layer.cornerRadius = 8
                cell.commentTxt.text = "\(cObj[COMMENTS_COMMENT]!)"
                
                // Get comment date
                cell.cDateLabel.text = self.timeAgoSinceDate(cObj.createdAt!, currentDate: Date(), numericDates: true)
                
                
                // Assign tags
                cell.cAvatarButton.tag = indexPath.row
                cell.cOptionsButton.tag = indexPath.row

            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }})// userPointer
        
        return cell
    }
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
}


// MARK: - SEND COMMENT BUTTON
@objc func sendButt() {
    if commentTxt.text == "" {
        simpleAlert("You must type something!")
        
    } else {
        showHUD("Please wait...")
        let cObj = PFObject(className: COMMENTS_CLASS_NAME)
        let currUser = PFUser.current()!
        
        // Save data
        cObj[COMMENTS_USER_POINTER] = currUser
        cObj[COMMENTS_STREAM_POINTER] = sObj
        cObj[COMMENTS_COMMENT] = commentTxt.text!
        let reportedBy = [String]()
        cObj[COMMENTS_REPORTED_BY] = reportedBy

        // Saving block
        cObj.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
                self.dismissKeyboard()
                self.fakeTxt.text = ""
                self.commentTxt.text = ""

                
                // Increment comments of this Stream
                self.sObj.incrementKey(STREAMS_COMMENTS, byAmount: 1)
                self.sObj.saveInBackground()
                
                
                // Send push notification
                self.sendPushNotification(currentUser: currUser, pushMess: "commented on your post: ", textColumn: STREAMS_TEXT, obj: self.sObj, userPointerColumn: STREAMS_USER_POINTER)
                
                // Save Activity
                self.saveActivity(currUser: currUser, streamObj: self.sObj, text: "commented on your post: '\(self.sObj[STREAMS_TEXT]!)'")
                
                // Recall query
                self.queryComments()
            
            // error
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
        }})
    }
}

    
    
   
    

// MARK: - CELL OPTIONS BUTTON
@IBAction func optionsButt(_ sender: UIButton) {
    let currUser = PFUser.current()!
    
    var cObj = PFObject(className: COMMENTS_CLASS_NAME)
    cObj = commentsArray[sender.tag]
    
    // Get User Pointer
    let userPointer = cObj[COMMENTS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
           
            let alert = UIAlertController(title: APP_NAME,
                    message: "Select option",
                    preferredStyle: .alert)
            
            // REPORT COMMENT ------------------------
            let reportComment = UIAlertAction(title: "Report Comment", style: .default, handler: { (action) -> Void in
               
                let alert = UIAlertController(title: APP_NAME,
                    message: "Are you sure you want to report this comment?",
                    preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
                    
                    self.showHUD("Please wait...")
                    var reportedBy = cObj[COMMENTS_REPORTED_BY] as! [String]
                    reportedBy.append(currUser.objectId!)
                    cObj[COMMENTS_REPORTED_BY] = reportedBy
                    
                    cObj.saveInBackground(block: { (succ, error) in
                        if error == nil {
                            self.hideHUD()
                            self.simpleAlert("Thanks for reporting this comment! We'll check it out within 24h.")
                            
                            // Reload data
                            self.commentsArray.remove(at: sender.tag)
                            self.commentsTableView.reloadData()
                    }})
                    
                })
                
                // Cancel
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
              
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            })
            
            
            
            // COPY COMMENT TEXT ------------------------
            let copyComment = UIAlertAction(title: "Copy", style: .default, handler: { (action) -> Void in
                    UIPasteboard.general.string = "\(cObj[COMMENTS_COMMENT]!)"
            })
            
            
            // CANCEL BUTTON ------------------------
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

            alert.addAction(reportComment)
            reportComment.setValue(UIImage(named:"report_butt"), forKey: "image")
            alert.addAction(copyComment)
            copyComment.setValue(UIImage(named:"copy_butt"), forKey: "image")
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
    }})// END USERPOINTER
}
    

    
    
    
// MARK: - COMMENT AVATAR BUTTON
@IBAction func cAvatarButt(_ sender: UIButton) {
        var cObj = PFObject(className: COMMENTS_CLASS_NAME)
        cObj = commentsArray[sender.tag]
        
        // Get User Pointer
        let userPointer = cObj[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
                aVC.userObj = userPointer
                self.navigationController?.pushViewController(aVC, animated: true)
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }})// end userPointer
}
    
    
 
    
   
// MARK: - TEXTFIELD DELEGATES
func textFieldDidBeginEditing(_ textField: UITextField) {
    commentTxt.becomeFirstResponder()
}
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    commentTxt.becomeFirstResponder()
    
return true
}
    
    
    
// MARK: - REFRESH DATA
@objc func refreshTB () {
    // Recall query
    queryComments()
    
    if refreshControl.isRefreshing { refreshControl.endRefreshing() }
}
    
    
    
    
// DISMISS KEYBOARD
    @objc func dismissKeyboard() {
    fakeTxt.text = commentTxt.text
    commentTxt.resignFirstResponder()
    fakeTxt.resignFirstResponder()
}
    
    
    
// MARK: - DIMSISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
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

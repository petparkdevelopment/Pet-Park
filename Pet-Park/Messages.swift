/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox




// MARK: - CUSTOM NICKNAME CELL
class ChatsCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
}







// MARK: - MESSAGES CONTROLLER
class Messages: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate
{

    /* Views */
    @IBOutlet weak var chatsTableView: UITableView!
    @IBOutlet weak var noChatsView: UIView!
    
    
    
    /* Variables */
    var messagesArray = [PFObject]()
    
    
    
override func viewDidAppear(_ animated: Bool) {
    // Call wuery
    queryMessages()
}
    
override func viewDidLoad() {
        super.viewDidLoad()

}



    
// QUERY CHATS
func queryMessages() {
    messagesArray.removeAll()
    showHUD("Please wait...")
    
    // Make query
    let query = PFQuery(className: MESSAGES_CLASS_NAME)
    query.includeKey(USER_CLASS_NAME)
    query.whereKey(MESSAGES_ID, contains: "\(PFUser.current()!.objectId!)")
    query.order(byDescending: "createdAt")
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.messagesArray = objects!
            self.hideHUD()
            
            if self.messagesArray.count == 0 {
                self.noChatsView.isHidden = false
                self.chatsTableView.isHidden = true
            } else {
                self.noChatsView.isHidden = true
                self.chatsTableView.isHidden = false
                self.chatsTableView.reloadData()
            }
            
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
    return messagesArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsCell
    
    // Get Parse obj
    var mObj = PFObject(className: MESSAGES_CLASS_NAME)
    mObj = messagesArray[indexPath.row]
    let currUser = PFUser.current()!
    
    // Get User Pointer
    let userPointer = mObj[MESSAGES_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
    
        let otherUser = mObj[MESSAGES_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                
                // Get Sender's username
                if userPointer.objectId == currUser.objectId {
                    cell.senderLabel.text = "You wrote:"
                    getParseImage(otherUser, imgView: cell.userAvatar, columnName: USER_AVATAR)
                    // Get verified badge if user got it
                    let fullNameString = NSMutableAttributedString(string: "\(otherUser[USER_FULLNAME]!)  ")
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    fullNameString.append(image1String)
                    cell.usernameLabel.attributedText = fullNameString
                    
                    
                    if otherUser[USER_BADGE] != nil {
                        
                        cell.usernameLabel.attributedText = fullNameString
                        print("verified")
                        //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
                        
                    } else {  //get full name
                        cell.usernameLabel.text = "\(otherUser[USER_FULLNAME]!)"
                    } //end verified badge
                } else {
                    cell.senderLabel.text = "@\(userPointer[USER_USERNAME]!)"
                    
                    
                    // Get verified badge if user got it
                    let fullNameString = NSMutableAttributedString(string: "\(userPointer[USER_FULLNAME]!)  ")
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(named: "verifiedbadgepetparksmall.png")
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    fullNameString.append(image1String)
                    cell.usernameLabel.attributedText = fullNameString
                    
                    
                    if otherUser[USER_BADGE] != nil {
                        
                        cell.usernameLabel.attributedText = fullNameString
                        print("verified")
                        //getParseImage(userPointer, imgView: cell.badgeImg, columnName: USER_BADGE)
                        
                    } else {  //get full name
                        cell.usernameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                    } //end verified badge
                    
                    
                    //cell.usernameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                    
                    getParseImage(userPointer, imgView: cell.userAvatar, columnName: USER_AVATAR)
                }
                
                
                // Get last Message
                cell.lastMessLabel.text = "\(mObj[MESSAGES_LAST_MESSAGE]!)"
                
                // Get Date
                let cDate = mObj.createdAt!
                let date = Date()
                cell.dateLabel.text = self.timeAgoSinceDate(cDate, currentDate: date, numericDates: true)
 
                // cell layout
                cell.userAvatar.layer.cornerRadius = cell.userAvatar.bounds.size.width/2
                
                
            // error in otherUser
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }}) // end otherUser
    
        
    }// end userPointer
    
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
}
    
    
    
// MARK: -  CELL HAS BEEN TAPPED -> CHAT WITH THE SELECTED CHAT
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var mObj = PFObject(className: MESSAGES_CLASS_NAME)
    mObj = messagesArray[indexPath.row]
    let currUser = PFUser.current()!
   
    // Get userPointer
    let userPointer = mObj[MESSAGES_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
        
        // Get otherUser
        let otherUser = mObj[MESSAGES_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                
                // Get blocked users
                var blockedUsers = [String]()
                var blockMessage = ""
                if userPointer.objectId == currUser.objectId {
                    blockedUsers = otherUser[USER_HAS_BLOCKED] as! [String]
                    blockMessage = "Sorry, @\(otherUser[USER_USERNAME]!) has blocked you, you can't chat with this user."
                } else {
                    blockedUsers = userPointer[USER_HAS_BLOCKED] as! [String]
                    blockMessage = "Sorry, @\(userPointer[USER_USERNAME]!) has blocked you, you can't chat with this user."
                }
                
                // otherUser user has blocked you
                if blockedUsers.contains(currUser.objectId!) {
                    self.simpleAlert(blockMessage)
                
                // Chat with otherUser
                } else {
                    let inboxVC = self.storyboard?.instantiateViewController(withIdentifier: "Inbox") as! Inbox
        
                    if userPointer.objectId == currUser.objectId {
                        inboxVC.userObj = otherUser
                    } else {
                        inboxVC.userObj = userPointer
                    }
                    
                    self.present(inboxVC, animated: true, completion: nil)
                }
                
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// end otherUser

    }// end userPointer
    
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}





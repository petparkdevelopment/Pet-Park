/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse



// MARK: - FOLLOW CELL
class FollowCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    
}





// MARK: - FOLLOW CONTROLLER
class Follow: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{
    
    /* Views */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var followTableView: UITableView!
    
    
    /* Variables */
    var userObj = PFUser()
    var followArray = [PFObject]()
    var isFollowing = Bool()
    
    
    
    
    
override func viewDidAppear(_ animated: Bool) {
    if isFollowing { titleLabel.text = "Following"
    } else { titleLabel.text = "Followers" }
        
    // Call query
    queryFollow()
}
    
override func viewDidLoad() {
        super.viewDidLoad()

}


    
// MARK: - QUERY FOLLOW
func queryFollow() {
    if userObj.objectId == nil { userObj = PFUser.current()! }

    showHUD("Please wait..")
    
    let query = PFQuery(className: FOLLOW_CLASS_NAME)
    if isFollowing {
        query.whereKey(FOLLOW_CURR_USER, equalTo: userObj)
    } else {
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
    }
    query.order(byDescending: "createdAt")
    
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.followArray = objects!
            self.hideHUD()
            self.followTableView.reloadData()
            
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
    return followArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
    
    // Get Parse obj
    var fObj = PFObject(className: FOLLOW_CLASS_NAME)
    fObj = followArray[indexPath.row]
    
    // Get User Pointer
    var userPointer = PFUser()
    if isFollowing {
        userPointer = fObj[FOLLOW_IS_FOLLOWING] as! PFUser
    } else {
        userPointer = fObj[FOLLOW_CURR_USER] as! PFUser
    }
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            // Get Avatar
            cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
            getParseImage(userPointer, imgView: cell.avatarImg, columnName: USER_AVATAR)
            
            // Get full name
            cell.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
            
            // Get username
            cell.usernameLabel.text = "@\(userPointer[USER_USERNAME]!)"
            
            // Get aboutMe
            if userPointer[USER_ABOUT_ME] != nil {
                cell.aboutMeLabel.text = "\(userPointer[USER_ABOUT_ME]!)"
            } else {
                cell.aboutMeLabel.text = "N/A"
            }
            
            
        // error in userPointer
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userPointer

        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88
}
    
    
    
// MARK: - CELL TAPPED -> SHOW USER PROFILE
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Get Parse Obj
    var fObj = PFObject(className: FOLLOW_CLASS_NAME)
    fObj = followArray[indexPath.row]
    
    // Get User Pointer
    var userPointer = PFUser()
    if isFollowing {
        userPointer = fObj[FOLLOW_IS_FOLLOWING] as! PFUser
    } else {
        userPointer = fObj[FOLLOW_CURR_USER] as! PFUser
    }
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
            aVC.userObj = userPointer
            self.navigationController?.pushViewController(aVC, animated: true)
       
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

/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse


class Statistics: UIViewController {

    /* Views */
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var streamTextLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var profileClicksLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    
    
    
    /* Variables */
    var sObj = PFObject(className: STREAMS_CLASS_NAME)
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    showStreamStats()

}


// MARK: - SHOW STREAM STATISTICS
func showStreamStats() {
    let currUser = PFUser.current()!
    
    fullNameLabel.text = "\(currUser[USER_FULLNAME]!)"
    usernameLabel.text = "@\(currUser[USER_USERNAME]!)"
    streamTextLabel.text = "\(sObj[STREAMS_TEXT]!)"
    
    let views = sObj[STREAMS_VIEWS] as! Int
    viewsLabel.text = views.abbreviated
    
    let likes = sObj[STREAMS_LIKES] as! Int
    likesLabel.text = likes.abbreviated

    let profileClicks = sObj[STREAMS_PROFILE_CLICKS] as! Int
    profileClicksLabel.text = profileClicks.abbreviated
    
    let comments = sObj[STREAMS_COMMENTS] as! Int
    commentsLabel.text = comments.abbreviated
    
    let shares = sObj[STREAMS_SHARES] as! Int
    sharesLabel.text = shares.abbreviated
}
    
    
    

    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


// MARK: - ACTIVITY CELL
class ActivityCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var actTextLabel: UILabel!
}






// MARK: - ACTIVITY CONTROLLER
class Activity: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
GADInterstitialDelegate
{

    /* Views */
    @IBOutlet weak var activityTableView: UITableView!
    var adMobInterstitial: GADInterstitial!

    
    
    /* Variables */
    var activityArray = [PFObject]()
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Call query
    queryActivity()
    
    
    
    // Call AdMob Interstitial
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_UNIT_ID)
    adMobInterstitial.load(GADRequest())
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        self.showInterstitial()
    })
}


  
// MARK: - QUERY ACTIVITY
func queryActivity() {
    let query = PFQuery(className: ACTIVITY_CLASS_NAME)
    query.whereKey(ACTIVITY_CURRENT_USER, equalTo: PFUser.current()!)
    query.order(byDescending: ACTIVITY_CREATED_AT)
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.activityArray = objects!
            self.hideHUD()
            self.activityTableView.reloadData()
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
    return activityArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
    
    // Get Parse obj
    var aObj = PFObject(className: ACTIVITY_CLASS_NAME)
    aObj = activityArray[indexPath.row]
    
    // Get User Pointer
    let userPointer = aObj[ACTIVITY_OTHER_USER] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            // Get avatar
            cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
            getParseImage(userPointer, imgView: cell.avatarImg, columnName: USER_AVATAR)
            
            // Get text
            cell.actTextLabel.text = "\(aObj[ACTIVITY_TEXT]!)"
            
            
        // error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end userpointer

return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
}
    
    
    
// MARK: - CELL TAPPED -> VIEW STREAM
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Get Parse obj
    var aObj = PFObject(className: ACTIVITY_CLASS_NAME)
    aObj = activityArray[indexPath.row]
    
    // Get Stream Pointer
    let streamPointer = aObj[ACTIVITY_STREAM_POINTER] as! PFObject
    streamPointer.fetchIfNeededInBackground(block: { (user, error) in
        if error == nil {
            
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "StreamDetails") as! StreamDetails
            aVC.sObj = streamPointer
            self.navigationController?.pushViewController(aVC, animated: true)
            
        // error
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})// end streamPointer
}
    

    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
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

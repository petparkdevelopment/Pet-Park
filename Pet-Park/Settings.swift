/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse


class Settings: UIViewController,
UITableViewDelegate,
UITableViewDataSource
{

    /* Views */
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    
    
    /* Variables */
    let settingsArray = [
        "Edit Profile",         // 0
        "Activity",             // 1
        "Terms of Use",         // 2
        "Version",              // 3
        "Like on Facebook",     // 4
        "Visit Website",        // 5
        "Rate on the App Store",// 6
        "Logout",               // 7
    ]
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
}

 
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    // Set cells text
    cell.textLabel?.text = "\(settingsArray[indexPath.row])"
    
    // Get app version
    if indexPath.row == 3 {
        cell.textLabel?.text = "Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }
    
    // Red the Logout text
    if indexPath.row == 7 { cell.textLabel?.textColor = UIColor.red }
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
}
    
    
    
// MARK: - CELL TAPPED
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    
        
    // EDIT PROFILE ------------------------------------------
    case 0:
       let aVC = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
       present(aVC, animated: true, completion: nil)
    break
        
        
        
    // ACTIVITY ------------------------------------------------
    case 1:
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Activity") as! Activity
        navigationController?.pushViewController(aVC, animated: true)
    break
        
        
        
    // TERMS OF USE ------------------------------------------------
    case 2:
        let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(aVC, animated: true, completion: nil)
        break
        
        
    // LIKE ON FACEBOOK ----------------------------------------
    case 4:
        let aURL = URL(string: FACEBOOK_URL)
        UIApplication.shared.openURL(aURL!)
    break
        
        
        
    // FOLLOW ON TWITTER ----------------------------------------
    case 5:
        let aURL = URL(string: TWITTER_URL)
        UIApplication.shared.openURL(aURL!)
    break
        
    
    
    // RATE ON THE APP STORE ----------------------------------------
    case 6:
        let aURL = URL(string: "itms-apps://itunes.apple.com/app/id\(APP_ID)")
        UIApplication.shared.openURL(aURL!)
    break
        
        
        
    // LOGOUT ------------------------------------------------
    case 7:
        let alert = UIAlertController(title: APP_NAME,
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
            self.showHUD("Logging Out...")
            
            PFUser.logOutInBackground(block: { (error) in
                if error == nil {
                    let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
                    self.present(aVC, animated: true, completion: nil)
                }
                self.hideHUD()
            })
        })
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    break
        
    default:break
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

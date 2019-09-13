/*-----------------------------------
 
 - App -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import ParseFacebookUtilsV4



class Intro: UIViewController {
    
    /* Views */
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    
    
  
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        dismiss(animated: true, completion: nil)
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    facebookButton.layer.cornerRadius  = 5
    // Initial Layout
    logoImage.layer.cornerRadius = 20
    appNameLabel.text = APP_NAME

}

    
    
   
    
// MARK: - GET STARTED BUTTON
@IBAction func getStartedButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    present(aVC, animated: true, completion: nil)
}
    
    

// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
    present(aVC, animated: true, completion: nil)
}

    
    
    
   
// MARK: - FACEBOOK LOGIN BUTTON
@IBAction func facebookButt(_ sender: Any) {
        // Set permissions required from the facebook user account
        let permissions = ["public_profile", "email"];
        showHUD("Please wait...")
        
        // Login PFUser using Facebook
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
            if user == nil {
                self.simpleAlert("Facebook login cancelled")
                self.hideHUD()
                
            } else if (user!.isNew) {
                print("NEW USER signed up and logged in through Facebook!");
                self.getFBUserData()
                
            } else {
                print("User logged in through Facebook!");
                
                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
        }}
}
    
    
func getFBUserData() {
    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"])
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest) { (connection, result, error) in
            if error == nil {
                let userData:[String:AnyObject] = result as! [String : AnyObject]
                
                // Get data
                let facebookID = userData["id"] as! String
                let name = userData["name"] as! String
                let email = userData["email"] as! String
                
                let currUser = PFUser.current()!
                
                // Get avatar
                let pictureURL = URL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1")
                let urlRequest = URLRequest(url: pictureURL!)
                let session = URLSession.shared
                let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                    if error == nil && data != nil {
                        let image = UIImage(data: data!)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
                        currUser[USER_AVATAR] = imageFile
                        currUser.saveInBackground()
                    }})
                dataTask.resume()
             
                    
                // Update user data
                let nameArr = name.components(separatedBy: " ")
                var username = String()
                for word in nameArr {
                    username.append(word.lowercased())
                }
                currUser.username = username
                if email != "" { currUser.email = email
                } else { currUser.email = "noemail@facebook.com" }
                
                // Save Other Data
                currUser[USER_FULLNAME] = name
                currUser[USER_IS_REPORTED] = false
                let hasBlocked = [String]()
                currUser[USER_HAS_BLOCKED] = hasBlocked

                currUser.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        mustRefresh = true
                        self.dismiss(animated: false, completion: nil)
                        self.hideHUD()
                }})
                
            // error on graph request
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        connection.start()
}
    
    
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

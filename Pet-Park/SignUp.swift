/*-----------------------------------
 
 - App -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse


class SignUp: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField! {
        didSet {
            usernameTxt.tintColor = UIColor.lightGray
            usernameTxt.setIcon(#imageLiteral(resourceName: "icons8-user-500"))
        }
    }
    @IBOutlet var passwordTxt: UITextField! {
        didSet {
            passwordTxt.tintColor = UIColor.lightGray
            passwordTxt.setIcon(#imageLiteral(resourceName: "icons8-password-1-500"))
        }
    }
    @IBOutlet var emailTxt: UITextField! {
        didSet {
            emailTxt.tintColor = UIColor.lightGray
            emailTxt.setIcon(#imageLiteral(resourceName: "icons8-email-500"))
        }
    }
    @IBOutlet weak var fullnameTxt: UITextField! {
        didSet {
            fullnameTxt.tintColor = UIColor.lightGray
            fullnameTxt.setIcon(#imageLiteral(resourceName: "icons8-cat-footprint-500"))
        }
    }
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var signupTitleLabel: UILabel!
    

    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    usernameTxt.borderStyle = .roundedRect
    fullnameTxt.borderStyle = .roundedRect
    emailTxt.borderStyle = .roundedRect
    passwordTxt.borderStyle = .roundedRect
    // Initial Layouts
    signupTitleLabel.text = "Sign up to \(APP_NAME)"
    logoImage.layer.cornerRadius = 5

    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 650)
    
}
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
   dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    fullnameTxt.resignFirstResponder()
}
    
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    dismissKeyboard()
    
    if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" || fullnameTxt.text == "" {
        simpleAlert("You must fill all fields to sign up on \(APP_NAME)")
        self.hideHUD()
        
    } else {
        showHUD("Please wait...")

        let currUser = PFUser()
        currUser.username = usernameTxt.text!.lowercased()
        currUser.password = passwordTxt.text
        currUser.email = emailTxt.text
        
        // Other data
        currUser[USER_FULLNAME] = fullnameTxt.text
        currUser[USER_IS_REPORTED] = false
        let hasBlocked = [String]()
        currUser[USER_HAS_BLOCKED] = hasBlocked
        
        // Save default avatar
        let imageData = UIImageJPEGRepresentation(UIImage(named:"default_avatar")!, 1.0)
        let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
        currUser[USER_AVATAR] = imageFile
        
        
        currUser.signUpInBackground { (succeeded, error) -> Void in
            if error == nil {
                mustRefresh = true
                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
        
            // ERROR
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    }
}
    
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt {  fullnameTxt.becomeFirstResponder()     }
    if textField == fullnameTxt {
        emailTxt.resignFirstResponder()
        signupButt(self)
    }
    
return true
}
    
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    

// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

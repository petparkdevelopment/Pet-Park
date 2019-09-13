/*-----------------------------------
 
 - App -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse


class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!  {
        didSet {
            usernameTxt.tintColor = UIColor.lightGray
            usernameTxt.setIcon(#imageLiteral(resourceName: "icons8-user-500"))
        }
    }
    @IBOutlet var passwordTxt: UITextField!  {
        didSet {
            passwordTxt.tintColor = UIColor.lightGray
            passwordTxt.setIcon(#imageLiteral(resourceName: "icons8-password-1-500"))
        }
    }
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginTitleLabel: UILabel!
    
    
    
    
    
override func viewWillAppear(_ animated: Bool) {
    // Dismiss the controller is Current User is logged in
    if PFUser.current() != nil { dismiss(animated: false, completion: nil) }
}
    
        
override func viewDidLoad() {
        super.viewDidLoad()
        
    usernameTxt.borderStyle = .roundedRect
    passwordTxt.borderStyle = .roundedRect
    // Layouts
    logoImage.layer.cornerRadius = 5
    loginTitleLabel.text = "Log in to \(APP_NAME)"
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    
}
    
    
    
   
// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD("Please wait...")
        
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        if error == nil {
            mustRefresh = true
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
                
        // Login failed. Try again or SignUp
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
 
    
    


    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    signupVC.modalTransitionStyle = .crossDissolve
    present(signupVC, animated: true, completion: nil)
}
    
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {
        passwordTxt.resignFirstResponder()
        loginButt(self)
    }
return true
}
    
    
    
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}


    
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
    
    
    
    
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
                message: "Type your email address you used to register.",
                preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
        // TextField
        let textField = alert.textFields!.first!
        let txtStr = textField.text!
        PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
            if error == nil {
                self.simpleAlert("You will receive an email shortly with a link to reset your password")
        }})
        
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    // Add textField
    alert.addTextField { (textField: UITextField) in
        textField.keyboardAppearance = .dark
        textField.keyboardType = .emailAddress
    }
    
    alert.addAction(ok)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}


    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
//extension UITextField {
//    func setIcon2(_ image: UIImage) {
//        let iconView = UIImageView(frame:
//            CGRect(x: 10, y: 5, width: 20, height: 20))
//        iconView.image = image
//        let iconContainerView: UIView = UIView(frame:
//            CGRect(x: 20, y: 0, width: 30, height: 30))
//        iconContainerView.addSubview(iconView)
//        leftView = iconContainerView
//        leftViewMode = .always
//    }
//}

/*-----------------------------------
 
 - App -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit


class TermsOfUse: UIViewController {

    /* Views */
    @IBOutlet var webView: UIWebView!
    
    
    
   
override var prefersStatusBarHidden : Bool {
        return true
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    let url = Bundle.main.url(forResource: "tou", withExtension: "html")
    webView.loadRequest(URLRequest(url: url!))

}

    
    
// DISMISS BUTTON
@IBAction func dismissButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

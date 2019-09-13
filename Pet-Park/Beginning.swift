//
//  Beginning.swift
//  ACR
//
//  Created by Noah Cremer on 04.03.19.
//  Copyright © 2019 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

class Beginning: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        
        // USER IS NOT LOGGED IN
        if PFUser.current() == nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Password") as! Password
            aVC.modalTransitionStyle = .crossDissolve
            present(aVC, animated: true, completion: nil)
        }
        else{ //ist eingeloggt
            let aVC = storyboard?.instantiateViewController(withIdentifier: "StartPage") as! UITabBarController
            aVC.modalTransitionStyle = .crossDissolve
            present(aVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

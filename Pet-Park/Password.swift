//
//  Password.swift
//  ACR
//
//  Created by Noah Cremer on 03.03.19.
//  Copyright © 2019 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

class Password: UIViewController {
    var window: UIWindow?
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonclick(_ sender: Any) {
        if(password.text == "EICKEN123"){
            
            print("correct")
            performSegue(withIdentifier: "pass", sender: nil)

        }
        else{
            
            print("incorrect")
            simpleAlert("Incorrect Password")
            
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

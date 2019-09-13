//
//  IntroDoneViewController.swift
//  Pet-Park
//
//  Created by Noah Cremer on 13.09.19.
//  Copyright © 2019 FV iMAGINATION. All rights reserved.
//

import UIKit

class IntroDoneViewController: UIViewController {

    @IBOutlet weak var continueButt: UIButton!
    @IBAction func buttonclick(_ sender: Any) {
        performSegue(withIdentifier: "continueseg", sender: nil)
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

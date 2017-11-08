//
//  SigninViewController.swift
//  Client
//
//  Created by Minh on 2017-10-21.
//  Copyright © 2017 Minh. All rights reserved.
//

import UIKit
var ip: String=""
class SigninViewController: UIViewController {


    @IBOutlet weak var txtip: UITextField!
    @IBAction func connect(_ sender: Any) {
        ip=txtip.text!
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

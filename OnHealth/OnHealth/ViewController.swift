//
//  ViewController.swift
//  OnHealth
//
//  Created by Gianluca Rago on 4/2/16.
//  Copyright © 2016 Ragoware LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //UserHandler.attemptLogin("caretaker@test.com", pass:"testtesttest")
        // Do any additional setup after loading the view, typically from a nib.
        UserHandler.sendTwillioAlert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


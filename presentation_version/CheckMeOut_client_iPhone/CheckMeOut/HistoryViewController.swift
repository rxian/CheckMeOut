//
//  HistoryViewController.swift
//  CheckMeOut
//
//  Created by Ruicheng Xian on 11/7/15.
//  Copyright © 2015 CheckMeOut. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func returnToMainMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}


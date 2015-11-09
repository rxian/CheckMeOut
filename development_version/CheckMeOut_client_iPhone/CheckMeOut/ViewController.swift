//
//  ViewController.swift
//  CheckMeOut
//
//  Created by Ruicheng Xian on 11/7/15.
//  Copyright © 2015 CheckMeOut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let productsInCart = [["Hoodie Pillow", "DigiStore", "9.99"], ["LED Keychain", "DigiStore", "4.99"]]
        let productsInCart = []
        
        let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
        NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


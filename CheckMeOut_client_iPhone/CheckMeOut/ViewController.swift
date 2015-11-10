//
//  ViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let productsInCart = [["Hoodie Pillow", "DigiStore", "9.99"], ["LED Keychain", "DigiStore", "4.99"]]
        let productsInCart = []
        let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
        NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


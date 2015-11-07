//
//  PaymentTotalViewController.swift
//  CheckMeOut
//
//  Created by Ruicheng Xian on 11/7/15.
//  Copyright © 2015 CheckMeOut. All rights reserved.
//

import UIKit

class PaymentTotalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    
    
    
    
    //////////////
    var exp = [["Hoodie Pillow", "DigiStore", "$9.99"], ["LED Keychain", "DigiStore", "$9.55"]]
    
    
    
    var groupList = [String]()
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exp.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PaymentTotalViewControllerTableViewCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PaymentTotalViewControllerTableViewCell
        
        ///////////////
        let textexp = exp[indexPath.row]
        
        cell.productName.text = textexp[0]
        cell.productPrice.text = textexp[2]
        cell.storeName.text = textexp[1]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addMore(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}


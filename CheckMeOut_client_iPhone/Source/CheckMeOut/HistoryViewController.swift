//
//  HistoryViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var historyArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
        tableView.allowsSelection = false;
        
        
        let fetchRequest = NSFetchRequest(entityName: "History")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [History] {
                
                
                let formatter = NSNumberFormatter()
                formatter.minimumFractionDigits = 2
                
                var merchanth : String!
                var priceh : NSDecimalNumber!
                
                for entry in fetchResults {
                    merchanth = entry.merchant
                    priceh = entry.total
                    let item = [merchanth, priceh]
                    historyArray.addObject(item)
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func returnToMainMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HistoryViewControllerTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HistoryViewControllerTableViewCell
        
        
//        cell.productName.text = String(textexp[0])
//        cell.productPrice.text = String(format:"$\(textexp[2])")
        
//        return cell
        
        let textexp = historyArray[indexPath.row] as! NSArray
        
        cell.productName.text = String(textexp[0])
        cell.productPrice.text = String(format:"$\(textexp[1])")
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    
}


//
//  ViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var cartCounterBackground: UIImageView!
    @IBOutlet weak var cartCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let productsInCart = [["Hoodie Pillow", "DigiStore", "9.99"], ["LED Keychain", "DigiStore", "4.99"]]
//        let productsInCart = []
//        let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
//        NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")
        
        
        
        
//         Retreive the managedObjectContext from AppDelegate
        
//         Print it to the console
//        print(managedObjectContext)
        
        
//        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: self.managedObjectContext) as! Cart
        
        
        
//        newItem.product = "Test Item"
//        newItem.price = 12.69
//        newItem.merchant = "DigiStore LLC"
//        save()
    }

    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Cart")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Cart] {
                

                
//                print(fetchResults.count)
                
                if fetchResults.count == 0 {
                    cartCounterBackground.hidden = true
                    cartCounter.hidden = true
                } else {
                    cartCounter.text = String(format: "%d", fetchResults.count)
                    cartCounterBackground.hidden = false
                    cartCounter.hidden = false
                }
//                for entry in fetchResults {
//                    print("\((fetchResults[0].product)) \(formatter.stringFromNumber( fetchResults[0].price! ))")
//                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
//    func save() {
//        do {
//            try managedObjectContext.save()
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


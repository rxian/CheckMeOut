//
//  PaymentTotalViewController.swift
//  CheckMeOut
//
//  Created by Ruicheng Xian on 11/7/15.
//  Copyright © 2015 CheckMeOut. All rights reserved.
//

import UIKit

class PaymentTotalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate {
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    
    
    #if HAS_CARDIO
    var acceptCreditCards: Bool = true {
    didSet {
    payPalConfig.acceptCreditCards = acceptCreditCards
    }
    }
    #else
    var acceptCreditCards: Bool = false {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    #endif
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    
    
    
    
    
    
    
    
    
    //////////////
    var productsInCart = NSMutableArray()
    
    var groupList = [String]()
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsInCart.count
    }
    
    
    
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            productsInCart.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            totalLabel.text = String(format:"$%@",calculateTotal(productsInCart))
            
            let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
            NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")

        }
    }
    
    
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PaymentTotalViewControllerTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PaymentTotalViewControllerTableViewCell
        
        
        ///////////////
        let textexp = productsInCart[indexPath.row]
        
        
        
        
        
        cell.productName.text = String(textexp[0])
        cell.productPrice.text = String(format:"$%@",textexp[2])
        cell.storeName.text = String(textexp[1])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let cartData = NSUserDefaults.standardUserDefaults().objectForKey("cart") as? NSData
        
        if let cartData = cartData {
            let cartArray = NSKeyedUnarchiver.unarchiveObjectWithData(cartData) as? NSArray
            productsInCart = NSMutableArray(array: cartArray!)
        }
        
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
        
        
        
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "DigiStore LLC"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        
        totalLabel.text = String(format:"$%@",calculateTotal(productsInCart))
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addMore(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnectWithEnvironment(environment)
    }
    
    
    
    
    

    
    
    
    
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        print("PayPal Payment Success !")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment!.description
        })
    }
    
    
    
    
    
    
    
    
    
    
    func calculateTotal(productArray: NSArray) -> NSDecimalNumber {
        var sum = NSDecimalNumber(string: "0.00")
        if (productArray.count != 0) {
            for index in 0...productArray.count-1 {
                sum = sum.decimalNumberByAdding(NSDecimalNumber(string: String(productArray[index][2])))
            }
        }
        return sum
        
                
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func buyClothingAction(sender: AnyObject) {
        
        let subtotal = calculateTotal(productsInCart)
        
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0")
        let tax = NSDecimalNumber(string: "0")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "DigiStore LLC Transaction", intent: .Sale)
        
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            presentViewController(paymentViewController, animated: true, completion: nil)
            //////////////////////////////
            
            
            productsInCart = []
            
            let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
            NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")
            
            self.tableView.reloadData()
            totalLabel.text = String(format:"$%@",calculateTotal(productsInCart))

            
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
        
    }
    
    
    
    
    
}


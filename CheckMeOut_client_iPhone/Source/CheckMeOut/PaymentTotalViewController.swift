//
//  PaymentTotalViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//
//  References:
//  * PayPal-iOS-SDK-Sample-App, (c) 2014, PayPal
//

import PassKit
import UIKit
import CoreData

class PaymentTotalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PKPaymentAuthorizationViewControllerDelegate, PayPalPaymentDelegate {
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

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
    
    var productsInCart = NSMutableArray()
    var groupList = [String]()
    
    var paymentIsSuccessful = Bool()
    
    var total = NSDecimalNumber()
    
    var timer = NSTimer()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsInCart.count
    }
    
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            productsInCart.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            totalLabel.text = String(format:"$%@",calculateTotal(productsInCart))
            

            
            
            let fetchRequest = NSFetchRequest(entityName: "Cart")
            
            // Execute the fetch request, and cast the results to an array of LogItem objects
            do {
                if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Cart] {
                    
                    let logItemToDelete = fetchResults[indexPath.row]
                    managedObjectContext.deleteObject(logItemToDelete)
                    save()

                    //                productsInCart = fetchResults
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            

            
            
            let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
            NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")

        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PaymentTotalViewControllerTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PaymentTotalViewControllerTableViewCell

        let textexp = productsInCart[indexPath.row] as! NSArray
        
        cell.productName.text = String(textexp[0])
        cell.productPrice.text = String(format:"$\(textexp[2])")
        cell.storeName.text = String(textexp[1])
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentIsSuccessful = false
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Cart")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Cart] {
                
                
                let formatter = NSNumberFormatter()
                formatter.minimumFractionDigits = 2
                
                var producth : String!
                var merchanth : String!
                var priceh : NSDecimalNumber!
                
                for entry in fetchResults {
                    producth = entry.product
                    merchanth = entry.merchant
                    priceh = entry.price
                    let item = [producth, merchanth, priceh]
                    productsInCart.addObject(item)
                    //                    print("\(entry.product) \(formatter.stringFromNumber( entry.price ))")
                }
//                print(productsInCart)
                
//                productsInCart = fetchResults

                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
//        let cartData = NSUserDefaults.standardUserDefaults().objectForKey("cart") as? NSData
//        if let cartData = cartData {
//            let cartArray = NSKeyedUnarchiver.unarchiveObjectWithData(cartData) as? NSArray
//            productsInCart = NSMutableArray(array: cartArray!)
//        }
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func addMore(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnectWithEnvironment(environment)
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
            
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Choose Payment Option", preferredStyle: .ActionSheet)
            
            // 2
            let useApplePay = UIAlertAction(title: "Apple Pay", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.applePayButtonPressed(total)
            })
            let usePaypal = UIAlertAction(title: "Paypal", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.presentViewController(paymentViewController, animated: true, completion: nil)

            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            
            // 4
            optionMenu.addAction(useApplePay)
            optionMenu.addAction(usePaypal)
            optionMenu.addAction(cancelAction)
            
            // 5
            self.presentViewController(optionMenu, animated: true, completion: nil)

        
            
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
    }
    
    
    
    
    func paymentSuccessful() {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: self.managedObjectContext) as! History
        newItem.total = total
        newItem.merchant = "DigiStore LLC"
        save()
        

        productsInCart = []
        
//        let cartData = NSKeyedArchiver.archivedDataWithRootObject(productsInCart)
//        NSUserDefaults.standardUserDefaults().setObject(cartData, forKey: "cart")
        
        self.tableView.reloadData()
        totalLabel.text = String(format:"$%@",calculateTotal(productsInCart))
        
        
        let fetchRequest = NSFetchRequest(entityName: "Cart")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        
        do {
            try managedObjectContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        
        
        
        let alert = UIAlertController(title: "Payment is successful",
                                      message: "Your receipt number is DIGISTORE000000SAMPLE\nThis transaction has been saved to history",
                                      preferredStyle: .Alert)
        print("*** Send Receipt Confirmation to the Cloud Here ***")

        // Display the alert
        self.presentViewController(alert,
                                   animated: true,
                                   completion: nil)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)

        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("nextView") as NextViewController
//        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    func timerDidFire() {
        (self.dismissViewControllerAnimated(true, completion: nil))
        (self.dismissViewControllerAnimated(true, completion: nil))
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Paypal Methods

    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        
        // WARNING: implement your method when payment is complete
        
        
        
        print("PayPal Payment Success !")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment!.description
        })
        
        paymentSuccessful()
    }
    
    
    func calculateTotal(productArray: NSArray) -> NSDecimalNumber {
        var sum = NSDecimalNumber(string: "0.00")
        if (productArray.count != 0) {
            for index in 0...productArray.count-1 {
                sum = sum.decimalNumberByAdding(NSDecimalNumber(string: String(productArray.objectAtIndex(index).objectAtIndex(2))))
            }
        }
        total = sum
        return sum
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Apple Pay Methods
    
    func applePayButtonPressed(amount: NSDecimalNumber) {
        // Set up our payment request.
        let paymentRequest = PKPaymentRequest()
        
        /*
         Our merchant identifier needs to match what we previously set up in
         the Capabilities window (or the developer portal).
         */
        paymentRequest.merchantIdentifier = "merchant.CheckMeOut"
        
        /*
         Both country code and currency code are standard ISO formats. Country
         should be the region you will process the payment in. Currency should
         be the currency you would like to charge in.
         */
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        // The networks we are able to accept.
        paymentRequest.supportedNetworks = [
            PKPaymentNetworkAmex,
            PKPaymentNetworkDiscover,
            PKPaymentNetworkMasterCard,
            PKPaymentNetworkVisa
        ]
        
        /*
         Ask your payment processor what settings are right for your app. In
         most cases you will want to leave this set to .Capability3DS.
         */
        paymentRequest.merchantCapabilities = .Capability3DS
        
        /*
         An array of `PKPaymentSummaryItems` that we'd like to display on the
         sheet (see the summaryItems function).
         */
        paymentRequest.paymentSummaryItems = makeSummaryItems(requiresInternationalSurcharge: false, amount: amount)
        
        // Request shipping information, in this case just postal address.
//        paymentRequest.requiredShippingAddressFields = .PostalAddress
        
        // Display the view controller.
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    
    // A function to generate our payment summary items, applying an international surcharge if required.
    func makeSummaryItems(requiresInternationalSurcharge requiresInternationalSurcharge: Bool, amount:NSDecimalNumber) -> [PKPaymentSummaryItem] {
        var items = [PKPaymentSummaryItem]()
        
        /*
         Product items have a label (a string) and an amount (NSDecimalNumber).
         NSDecimalNumber is a Cocoa class that can express floating point numbers
         in Base 10, which ensures precision. It can be initialized with a
         double, or in this case, a string.
         */
        let productSummaryItem = PKPaymentSummaryItem(label: "Sub-total", amount: amount)
        items += [productSummaryItem]
        
        let totalSummaryItem = PKPaymentSummaryItem(label: "DigiStore LLC", amount: productSummaryItem.amount)
        // Apply an international surcharge, if needed.
//        if requiresInternationalSurcharge {
//            let handlingSummaryItem = PKPaymentSummaryItem(label: "International Handling", amount: NSDecimalNumber(string: "9.99"))
//            
//            // Note how NSDecimalNumber has its own arithmetic methods.
//            totalSummaryItem.amount = productSummaryItem.amount.decimalNumberByAdding(handlingSummaryItem.amount)
//            
//            items += [handlingSummaryItem]
//        }
        
        items += [totalSummaryItem]
        
        return items
    }
    
    
    // MARK: - PKPaymentAuthorizationViewControllerDelegate
    
    /*
     Whenever the user changed their shipping information we will receive a
     callback here.
     
     Note that for privacy reasons the contact we receive will be redacted,
     and only have a city, ZIP, and country.
     
     You can use this method to estimate additional shipping charges and update
     the payment summary items.
     */
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        
        /*
         Create a shipping method. Shipping methods use PKShippingMethod,
         which inherits from PKPaymentSummaryItem. It adds a detail property
         you can use to specify information like estimated delivery time.
         */
//        let shipping = PKShippingMethod(label: "Standard Shipping", amount: NSDecimalNumber.zero())
//        shipping.detail = "Delivers within two working days"
        
        /*
         Note that this is a contrived example. Because addresses can come from
         many sources on iOS they may not always have the fields you want.
         Your application should be sure to verify the address is correct,
         and return the appropriate status. If the address failed to pass validation
         you should return `.InvalidShippingPostalAddress` instead of `.Success`.
         */
        
//        let address = contact.postalAddress
//        let requiresInternationalSurcharge = address!.country != "United States"
        
//        let summaryItems = makeSummaryItems(requiresInternationalSurcharge: requiresInternationalSurcharge, )
        
//        completion(.Success, [shipping], summaryItems)
    }
    
    /*
     This is where you would send your payment to be processed - here we will
     simply present a confirmation screen. If your payment processor failed the
     payment you would return `completion(.Failure)` instead. Remember to never
     attempt to decrypt the payment token on device.
     */
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: PKPaymentAuthorizationStatus -> Void) {
        
//        paymentToken = payment.token
        
        completion(.Success)
        paymentIsSuccessful = true
//        performSegueWithIdentifier(ProductTableViewController.confirmationSegue, sender: self)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        // We always need to dismiss our payment view controller when done.
        dismissViewControllerAnimated(true, completion: nil)
        
        if paymentIsSuccessful {
            paymentSuccessful()
        }
    }
}
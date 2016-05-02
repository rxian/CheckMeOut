//
//  ScanQRCodeViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//
//  References:
//  * Unknown, online
//

import UIKit
import AVFoundation
import CoreData

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate  {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var foregroundImageView: UIImageView!
    @IBOutlet weak var messageLabel:UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sampleButton: UIButton!
    

    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var timer = NSTimer()
    let supportedBarCodes = [AVMetadataObjectTypeQRCode]//, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    var detected = false
    
    let sampleProductArray = [["LED Keychain", "DigiStore", "4.99"], ["Hoodie Pillow", "DigiStore", "9.99"], ["Soilent", "DigiStore", "2.99"], ["Blue Bull", "DigiStore", "2.49"], ["Outdoor Blanket", "DigiStore", "14.99"]];
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()

            view.bringSubviewToFront(foregroundImageView)
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(cancelButton)
            view.bringSubviewToFront(statusLabel)
            view.bringSubviewToFront(sampleButton)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.whiteColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timerDidFire() {
        detected = false
        timer.invalidate()
        statusLabel.text = ("Scan another QR code to continue")
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarCodes.contains(metadataObj.type) && self.view.hidden != true {
            if let viewControllers = navigationController?.viewControllers {
                for viewController in viewControllers {
                    if viewController.isKindOfClass(ScanQRCodeViewController) {
                    }
                } 
            }
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
            
            if (!detected && !timer.valid) {
                detected = true
                
                
                addSampleToCart(metadataObj.stringValue);
                
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewControllerWithIdentifier("PaymentTotalViewController")
//                
//                self.showViewController(vc, sender: nil)
            }
        }
    }
    
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    @IBAction func addSampleButton(sender: AnyObject) {
        if (!timer.valid) {
            addSampleToCart("")
        }
    }
    
    func addSampleToCart(identifier: String) -> Void {
        // WARNING: implement your method when a barcode is detected
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)
        
        print("*** Fetch Merchandise Information from the Cloud Here ***")
        
        let diceRoll = Int(arc4random_uniform(5))
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Cart", inManagedObjectContext: self.managedObjectContext) as! Cart
        
        
        let formatter = NSNumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        
        newItem.product = sampleProductArray[diceRoll][0]
        newItem.price = formatter.numberFromString(sampleProductArray[diceRoll][2]) as? NSDecimalNumber ?? 0
        newItem.productIdentifier = identifier
        newItem.merchant = sampleProductArray[diceRoll][1]
        save()
        statusLabel.text = String(format: "%@ has been added", sampleProductArray[diceRoll][0])


        
//        var productsInCart = NSMutableArray()
//        let cartData = NSUserDefaults.standardUserDefaults().objectForKey("cart") as? NSData
//        if let cartData = cartData {
//            let cartArray = NSKeyedUnarchiver.unarchiveObjectWithData(cartData) as? NSArray
//            productsInCart = NSMutableArray(array: cartArray!)
//        }
//        productsInCart.addObject(["LED Keychain", "DigiStore", "4.99"])
//        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(productsInCart), forKey: "cart")
    }
}
//
//  AboutViewController.swift
//  CheckMeOut
//
//  Created by R. Xian on 4/23/16.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var infoTextArea: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let myAttribute = [ NSFontAttributeName: UIFont(name: "Chalkduster", size: 18.0)! ]
//        let myString = NSMutableAttributedString(string: "Swift", attributes: myAttribute )
//        let attrString = NSAttributedString(string: " Attributed Strings")
//        myString.appendAttributedString(attrString)
//
//        var myRange = NSRange(location: 17, length: 7) // range starting at location 17 with a lenth of 7: "Strings"
//        myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: myRange)
//        
//        myRange = NSRange(location: 3, length: 17)
//        let anotherAttribute = [ NSBackgroundColorAttributeName: UIColor.yellowColor() ]
//        myString.addAttributes(anotherAttribute, range: myRange)
//        
//        infoTextArea.attributedText = myString
//        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            let desiredOffset = CGPoint(x: 0, y: -self.infoTextArea.contentInset.top)
            self.infoTextArea.setContentOffset(desiredOffset, animated: false)
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func returnToMainMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}


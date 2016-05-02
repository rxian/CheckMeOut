//
//  AppDelegate.swift
//  CheckMeOut
//
//  Created by R. Xian on 11/7/15.
//

import UIKit
import CoreData



@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    
    
    
    var window: UIWindow?
    

    enum ShortcutType: String {
        case showCart = "com.checkmeout.checkmeout.opencart"
        case scanItem = "com.checkmeout.checkmeout.scanitem"
    }
    
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert , UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)

        
        
        
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        
        PayPalMobile.initializeWithClientIdsForEnvironments([PayPalEnvironmentProduction:"TEST", PayPalEnvironmentSandbox:"TEST"])

        //Check for ShortCutItem
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            let storyboard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(storyboard.instantiateViewControllerWithIdentifier("ViewController"), animated: false, completion: {self.handleShortCutItem(shortcutItem)})

        }
        
        //Return false incase application was lanched from shorcut to prevent
        //application(_:performActionForShortcutItem:completionHandler:) from being called
//        return !launchedFromShortCut
        return true
    }
    
    func getCurrentViewController() -> UIViewController! {
        return UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController
    }

    
    func dismissAllView() {
        let presentViewController = getCurrentViewController()
        if presentViewController != nil {
            if (presentViewController.restorationIdentifier != "ViewController") {
                presentViewController.dismissViewControllerAnimated(false, completion:{
                    (self.dismissAllView())
                })
            }
        }
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        //Get type string from shortcutItem
        if let shortcutType = ShortcutType.init(rawValue: shortcutItem.type) {
            //Get root navigation viewcontroller and its first controller
//            let presentViewController = window!.rootViewController
//            let presentViewController = getCurrentViewController()
            
            self.dismissAllView()
            
            let viewController = window!.rootViewController as? ViewController
            let storyboard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)

//            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            //Pop to root view controller so that approperiete segue can be performed
//            rootNavigationViewController?.popToRootViewControllerAnimated(false)
            switch shortcutType {
            case.showCart:
            viewController!.presentViewController(storyboard.instantiateViewControllerWithIdentifier("PaymentTotalViewController"), animated: false, completion: nil)

                handled = true
            case.scanItem:
            viewController!.presentViewController(storyboard.instantiateViewControllerWithIdentifier("ScanQRCodeViewController"), animated: false, completion: nil)
                handled = true
            }
        }
        return handled
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let fetchRequest = NSFetchRequest(entityName: "Cart")
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Cart] {
                
                
                
                UIApplication.sharedApplication().applicationIconBadgeNumber = fetchResults.count
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "checkMeOut.CheckMeOut" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CheckMeOut", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}


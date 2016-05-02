//
//  History+CoreDataProperties.swift
//  CheckMeOut
//
//  Created by 冼睿成 on 4/20/16.
//  Copyright © 2016 CheckMeOut. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension History {

    @NSManaged var merchant: String?
    @NSManaged var total: NSDecimalNumber?

}

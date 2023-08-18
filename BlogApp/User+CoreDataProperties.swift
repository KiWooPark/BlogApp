//
//  User+CoreDataProperties.swift
//  BlogApp
//
//  Created by PKW on 2023/07/29.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var blogUrl: String?
    @NSManaged public var fine: Int64
    @NSManaged public var name: String?
    @NSManaged public var study: Study?

}

extension User : Identifiable {

}

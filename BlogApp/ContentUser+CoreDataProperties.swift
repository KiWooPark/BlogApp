//
//  ContentUser+CoreDataProperties.swift
//  BlogApp
//
//  Created by PKW on 2023/06/22.
//
//

import Foundation
import CoreData


extension ContentUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentUser> {
        return NSFetchRequest<ContentUser>(entityName: "ContentUser")
    }

    @NSManaged public var postUrl: String?
    @NSManaged public var fine: Int64
    @NSManaged public var name: String?
    @NSManaged public var title: String?
    @NSManaged public var content: Content?

}

extension ContentUser : Identifiable {

}

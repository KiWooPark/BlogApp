//
//  ContentUser+CoreDataProperties.swift
//  BlogApp
//
<<<<<<< HEAD
//  Created by PKW on 2023/07/29.
=======
//  Created by PKW on 2023/06/22.
>>>>>>> main
//
//

import Foundation
import CoreData


extension ContentUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentUser> {
        return NSFetchRequest<ContentUser>(entityName: "ContentUser")
    }

<<<<<<< HEAD
    @NSManaged public var fine: Int64
    @NSManaged public var name: String?
    @NSManaged public var postUrl: String?
=======
    @NSManaged public var postUrl: String?
    @NSManaged public var fine: Int64
    @NSManaged public var name: String?
>>>>>>> main
    @NSManaged public var title: String?
    @NSManaged public var content: Content?

}

extension ContentUser : Identifiable {

}

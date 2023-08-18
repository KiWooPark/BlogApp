//
//  Content+CoreDataProperties.swift
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


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }
<<<<<<< HEAD
    @NSManaged public var study: Study?
    
    @NSManaged public var contentNumber: Int64
    
    @NSManaged public var startDate: Date?
    @NSManaged public var deadlineDate: Date?
    @NSManaged public var deadlineDay: Int64
    
    @NSManaged public var fine: Int64
    @NSManaged public var plusFine: Int64
    @NSManaged public var totalFine: Int64
    
    @NSManaged public var members: NSSet?
    
=======

    @NSManaged public var finishDate: Date?
    @NSManaged public var plusFine: Int64
    @NSManaged public var totalFine: Int64
    @NSManaged public var currentWeekNumber: Int64
    @NSManaged public var finishWeekDay: Int64
    @NSManaged public var study: Study?
    @NSManaged public var members: NSSet?
>>>>>>> main

}

// MARK: Generated accessors for members
extension Content {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: ContentUser)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: ContentUser)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}

extension Content : Identifiable {

}

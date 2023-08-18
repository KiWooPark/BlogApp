//
//  Content+CoreDataProperties.swift
//  BlogApp
//
//  Created by PKW on 2023/07/29.
//
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }
    @NSManaged public var study: Study?
    
    @NSManaged public var contentNumber: Int64
    
    @NSManaged public var startDate: Date?
    @NSManaged public var deadlineDate: Date?
    @NSManaged public var deadlineDay: Int64
    
    @NSManaged public var fine: Int64
    @NSManaged public var plusFine: Int64
    @NSManaged public var totalFine: Int64
    
    @NSManaged public var members: NSSet?
    

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

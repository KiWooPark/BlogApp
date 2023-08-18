//
//  Study+CoreDataProperties.swift
//  BlogApp
//
//  Created by PKW on 2023/07/29.
//
//

import Foundation
import CoreData


extension Study {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Study> {
        return NSFetchRequest<Study>(entityName: "Study")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var fine: Int64
    @NSManaged public var deadlineDay: Int64
    @NSManaged public var isNewStudy: Bool
    @NSManaged public var memberCount: Int64
    @NSManaged public var firstStartDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var contents: NSSet?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for contents
extension Study {

    @objc(addContentsObject:)
    @NSManaged public func addToContents(_ value: Content)

    @objc(removeContentsObject:)
    @NSManaged public func removeFromContents(_ value: Content)

    @objc(addContents:)
    @NSManaged public func addToContents(_ values: NSSet)

    @objc(removeContents:)
    @NSManaged public func removeFromContents(_ values: NSSet)

}

// MARK: Generated accessors for members
extension Study {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: User)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: User)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}

extension Study : Identifiable {

}

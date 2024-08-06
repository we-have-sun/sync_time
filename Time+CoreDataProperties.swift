//
//  Time+CoreDataProperties.swift
//  Sync
//
//  Created by Nicho on 25/07/2024.
//
//

import Foundation
import CoreData


extension Time {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Time> {
        return NSFetchRequest<Time>(entityName: "Time")
    }

    @NSManaged public var name: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var duration: Int64
    @NSManaged public var project: Project?

}


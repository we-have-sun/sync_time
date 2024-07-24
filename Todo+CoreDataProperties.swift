//
//  Todo+CoreDataProperties.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var text: String
    @NSManaged public var isPlaying: Bool
    @NSManaged public var timeStart: Date?

}

extension Todo : Identifiable {

}

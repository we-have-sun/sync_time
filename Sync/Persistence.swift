//
//  Persistence.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<5 {
            let randomNumber = Int.random(in: -4_000_010 ... 0)
            let someDateTime = Date(timeIntervalSinceNow: Double(randomNumber))
            
            let todo = Todo(context: viewContext)
            todo.timeStart = Date()
            todo.text = "Todo item # \(index)"
            todo.isPlaying = false
            
            let project = Project(context: viewContext)
            project.name = "Project # \(index)"
            project.creationDate = someDateTime
            
        }
        
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Sync")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

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
            let durationAdded = Int.random(in: 10000 ... 60000)
            
            let time = Time(context: viewContext)
            time.startDate = Date(timeIntervalSinceNow: Double(durationAdded))
            time.duration = 100_000
            
            let time2 = Time(context: viewContext)
            time2.startDate = Date(timeIntervalSinceNow: Double(durationAdded))
            time2.duration = 33_000
            
            let todo = Todo(context: viewContext)
            todo.timeStart = Date()
            todo.text = "Todo item # \(index)"
            todo.isPlaying = false
            
            let project = Project(context: viewContext)
            project.name = "Project # \(index)"
            project.creationDate = someDateTime
            project.addToTimes(time)
            project.addToTimes(time2)
            
        }
        //adding a example data with not time recorded
        let project2 = Project(context: viewContext)
        project2.name = "Project no time"
        project2.creationDate = Date()
        
        //adding a example data with running task
        let project3 = Project(context: viewContext)
        project3.name = "Project running"
        project3.creationDate = Date()
        let time = Time(context: viewContext)
        time.startDate = Date(timeIntervalSinceNow: -2000)
        project3.addToTimes(time)
        
        
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

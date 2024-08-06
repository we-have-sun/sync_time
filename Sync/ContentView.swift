//
//  ContentView.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//

import SwiftUI
import CoreData

struct ObservedTimeView: View {
    @ObservedObject var time: Time

    var body: some View {
        Text("Time Duration: \(time.duration)")
            .font(.caption)
    }
}


struct ProjectRowView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext

    @State private var zeroDurationExists: Bool = false
    // make it computed variable inside the project
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                            TextField("Project", text: Binding(
                                get: { project.name },
                                set: { project.name = $0 }
                            ))
                            .onChange(of: project.name) {
                                try? viewContext.save()
                            }
                            
                            if let times = project.times as? Set<Time> {
                                if times == [] {
                                    Text("No time recorded")
                                        .font(.caption)
                                }
                                ForEach(Array(times), id: \.self) { time in
                                    ObservedTimeView(time: time)
                                }
                           }
                        }
            
            if !zeroDurationExists {
                            Image(systemName: "play")
                                .onTapGesture {
                                    addTime(to: project, context: viewContext)
                                    updateZeroDurationExists()
                                }
                        }
            if  zeroDurationExists {
                Image(systemName: "pause")
                    .onTapGesture {
                        calculateDurationAndPause(for: project, context: viewContext)
                        updateZeroDurationExists()
                    }
            }
                    }
        .onAppear(perform: updateZeroDurationExists)
                .onChange(of: project.times) { 
                    updateZeroDurationExists()
                }
                }
    func updateZeroDurationExists() {
            zeroDurationExists = (project.times as? Set<Time>)?.contains { $0.duration == 0 } ?? false
        }
    }



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(projects) { project in
                    ProjectRowView(project: project)
                }
                .onDelete(perform: deleteProject)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addProject) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Projects")
        }
    }

    private func addProject() {
        withAnimation {
            let project = Project(context: viewContext)
            project.creationDate = Date()
            project.name = ""
            try? viewContext.save()

        }
    }

    private func deleteProject(offsets: IndexSet) {
        withAnimation {
            offsets.map { projects[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
            
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

func addTime(to project: Project, context: NSManagedObjectContext) {
    let newTime = Time(context: context)
    newTime.startDate = Date()
    project.addToTimes(newTime)

    do {
        try context.save()
    } catch {
        print("Failed to save context: \(error)")
    }
}


func calculateDurationAndPause(for project: Project, context: NSManagedObjectContext) {
    guard let times = project.times as? Set<Time> else { return }
    if let zeroDurationTime = times.first(where: { $0.duration == 0 }) {
        if let startDate = zeroDurationTime.startDate {
            print(Int64(Date().timeIntervalSince(startDate)))
            zeroDurationTime.duration = Int64(Date().timeIntervalSince(startDate))
        }
        print(times)
        do {
            try context.save()
        } catch {
            //print("Failed to save context: \(error)")
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

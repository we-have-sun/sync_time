//
//  ContentView.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//

import SwiftUI
import CoreData

struct ProjectRowView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField("Project", text: $project.name)
                    .onChange(of: project.name) {
                        try? viewContext.save()
                    }
                Text("Created: \(project.creationDate ?? Date(),formatter: itemFormatter)")
                    .font(.caption)
                
            }
            Spacer()
//            Image(systemName: todo.isPlaying ? "pause" : "play")
//                .onTapGesture {
//                    todo.isPlaying.toggle()
//                    try? viewContext.save()
//                }
        }
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

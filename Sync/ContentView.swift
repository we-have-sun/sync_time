//
//  ContentView.swift
//  Sync
//
//  Created by Nicho on 23/07/2024.
//

import SwiftUI
import CoreData

struct TodoRowView: View {
    @ObservedObject var todo: Todo
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField("Todo", text: $todo.text)
                    .onChange(of: todo.text) {
                        try? viewContext.save()
                    }
                Text("\(todo.timeStart ?? Date(),formatter: itemFormatter)")
                    .font(.caption)
                
            }
            Spacer()
            Image(systemName: todo.isPlaying ? "pause" : "play")
                .onTapGesture {
                    todo.isPlaying.toggle()
                    try? viewContext.save()
                }
        }
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.timeStart, ascending: true)],
        animation: .default)
    private var todos: FetchedResults<Todo>

    var body: some View {
        NavigationStack {
            List {
                ForEach(todos) { todo in
                    TodoRowView(todo: todo)
                }
                .onDelete(perform: deleteTodo)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addTodo) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Todo CoreData")
        }
    }

    private func addTodo() {
        withAnimation {
            let todo = Todo(context: viewContext)
            todo.timeStart = Date()
            todo.text = ""
            todo.isPlaying = false
            try? viewContext.save()

        }
    }

    private func deleteTodo(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
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

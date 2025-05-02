import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var taskViewModel: TaskViewModel

    @State private var showingEditSheet = false
    @State private var taskToEdit: Task?

    var pet: Pet

    @FetchRequest var tasks: FetchedResults<Task>

    init(for pet: Pet) {
        self.pet = pet
        _tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
            predicate: NSPredicate(format: "taskPet == %@", pet)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(tasks, id: \.self) { task in
                    TaskView(task: task) { selectedTask in
                        taskToEdit = selectedTask
                        showingEditSheet = true
                    }
                }
            }
        }


        .listStyle(.plain)
        .onAppear {
            print("TaskListView: \(tasks.count) tasks loaded for pet '\(pet.name)'")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let task = taskToEdit {
                TaskFormView(pet: pet, taskToEdit: task)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(taskViewModel)
            }
        }
    }
}

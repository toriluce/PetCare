
import SwiftUI

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss

    var pet: Pet
    var taskToEdit: Task? = nil

    @State private var title = ""
    @State private var details = ""
    @State private var frequency = Date()

    var isEditing: Bool {
        taskToEdit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                    DatePicker("Frequency", selection: $frequency, displayedComponents: [.date])
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let task = taskToEdit {
                            taskViewModel.updateTask(task, title: title, details: details, isComplete: task.isComplete, frequency: frequency, context: context)
                        } else {
                            taskViewModel.addTask(to: pet, title: title, details: details, isComplete: false, frequency: frequency, context: context)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    details = task.details!
                    frequency = task.frequency ?? Date()
                }
            }
        }
    }
}

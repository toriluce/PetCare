import SwiftUI

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    
    var pet: Pet
    var existingTask: Task?
    
    @State private var title: String
    @State private var details: String
    @State private var frequency: Date
    
    var isEditing: Bool {
        existingTask != nil
    }
    
    init(pet: Pet, existingTask: Task? = nil) {
        self.pet = pet
        self.existingTask = existingTask
        
        _title = State(initialValue: existingTask?.title ?? "")
        _details = State(initialValue: existingTask?.details ?? "")
        _frequency = State(initialValue: existingTask?.frequency ?? Date())
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
                        if let task = existingTask {
                            petCareViewModel.editTask(task, title: title, details: details, isComplete: task.isComplete, frequency: frequency, context: context)
                        } else {
                            petCareViewModel.addTask(to: pet, title: title, details: details, isComplete: false, frequency: frequency, context: context)
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
        }
    }
}

#Preview {
    TaskFormView(pet: Pet.example, existingTask: Task.example)
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(PetCareViewModel())
}

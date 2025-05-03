import SwiftUI
import CoreData

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    
    var pet: Pet
    var existingTask: Task?
    
    @State private var title: String
    @State private var details: String
    @State private var recurrence: String
    @State private var timeOfDay: Date
    
    var isEditing: Bool {
        existingTask != nil
    }
    
    init(pet: Pet, existingTask: Task? = nil) {
        self.pet = pet
        self.existingTask = existingTask
        
        _title = State(initialValue: existingTask?.title ?? "")
        _details = State(initialValue: existingTask?.details ?? "")
        _recurrence = State(initialValue: existingTask?.frequency ?? "never")
        
        let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        _timeOfDay = State(initialValue: existingTask?.timeOfDay ?? defaultTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                    
                    Picker("Frequency", selection: $recurrence) {
                        Text("None").tag("never")
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                    }
                    
                    DatePicker("Time", selection: $timeOfDay, displayedComponents: [.hourAndMinute])
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let task = existingTask {
                            petCareViewModel.editTask(
                                task,
                                title: title,
                                details: details,
                                isComplete: task.isComplete,
                                frequency: recurrence,
                                timeOfDay: timeOfDay,
                                context: context
                            )
                        } else {
                            petCareViewModel.addTask(
                                to: pet,
                                title: title,
                                details: details,
                                isComplete: false,
                                frequency: recurrence,
                                timeOfDay: timeOfDay,
                                context: context
                            )
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

import SwiftUI
import CoreData

enum TaskFrequency: String, CaseIterable {
    case never, daily, weekly
    
    var label: String {
        switch self {
        case .never: return "None"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    
    var pet: Pet
    var existingTask: Task?
    
    @State private var title: String
    @State private var details: String
    @State private var recurrence: TaskFrequency
    @State private var timeOfDay: Date
    
    var isEditing: Bool {
        existingTask != nil
    }
    
    init(pet: Pet, existingTask: Task? = nil) {
        self.pet = pet
        self.existingTask = existingTask
        
        _title = State(initialValue: existingTask?.title ?? "")
        _details = State(initialValue: existingTask?.details ?? "")
        _recurrence = State(initialValue: TaskFrequency(rawValue: existingTask?.frequency ?? "") ?? .never)
        
        let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        _timeOfDay = State(initialValue: existingTask?.timeOfDay ?? defaultTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                        .autocapitalization(.sentences)
                        .disableAutocorrection(true)
                    
                    TextField("Details", text: $details)
                        .autocapitalization(.sentences)
                    
                    Picker("Frequency", selection: $recurrence) {
                        ForEach(TaskFrequency.allCases, id: \.self) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Time", selection: $timeOfDay, displayedComponents: [.hourAndMinute])
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = petCareViewModel.addOrEditTask(
                            for: pet,
                            existingTask: existingTask,
                            title: title,
                            details: details,
                            isComplete: existingTask?.isComplete ?? false,
                            frequency: recurrence.rawValue,
                            timeOfDay: timeOfDay,
                            context: context
                        )
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

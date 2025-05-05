import SwiftUI
import CoreData

enum TaskFrequency: String, CaseIterable {
    case never, daily, weekly
    
    var label: String {
        switch self {
        case .never: return "Never"
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
    @State private var timeOfDay: Date?
    @State private var includeTimeOfDay: Bool
    
    var isEditing: Bool {
        existingTask != nil
    }
    
    init(pet: Pet, existingTask: Task? = nil) {
        self.pet = pet
        self.existingTask = existingTask
        
        _title = State(initialValue: existingTask?.title ?? "")
        _details = State(initialValue: existingTask?.details ?? "")
        _recurrence = State(initialValue: TaskFrequency(rawValue: existingTask?.repeatFrequency ?? "") ?? .never)
        
        let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        _timeOfDay = State(initialValue: existingTask?.timeOfDay ?? defaultTime)
        _includeTimeOfDay = State(initialValue: existingTask?.timeOfDay != nil)
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
                    
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(TaskFrequency.allCases, id: \.self) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("Set Time of Day", isOn: $includeTimeOfDay)

                    if includeTimeOfDay {
                        DatePicker("Time", selection: Binding(
                            get: { timeOfDay ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())! },
                            set: { timeOfDay = $0 }
                        ), displayedComponents: [.hourAndMinute])
                    }                }
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
                            repeatFrequency: recurrence.rawValue,
                            timeOfDay: includeTimeOfDay ? timeOfDay : nil,
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

import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petViewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    var pet: PetEntity
    
    @State private var title = ""
    @State private var details = ""
    @State private var dueDate = Date()
    @State private var frequency = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    DatePicker("Frequency", selection: $frequency, displayedComponents: [.date])
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        petViewModel.addTask(to: pet, title: title, details: details, dueDate: dueDate, isComplete: false, frequency: frequency, context: context)
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
    AddTaskView(pet: PetEntity()) 
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environmentObject(PetViewModel())
}

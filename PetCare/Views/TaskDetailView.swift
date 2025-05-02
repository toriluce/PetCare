import SwiftUI

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var task: Task

    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let pet = task.taskPet {
                Section(header: Text("Pet Details").font(.headline)) {
                    Text("Name: \(pet.name)")
                    Text("Breed: \(pet.breed)")
                    Text("Species: \(pet.species)")
                    Text("Birthday: \(pet.birthday.formatted(date: .abbreviated, time: .omitted))")
                }
            }

            Section(header: Text("Task").font(.headline)) {
                Text("Title: \(task.title)")
                Text("Details: \(task.details)")
                Text("Completed: \(task.isComplete ? "Yes" : "No")")
            }

            Spacer()

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Task", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                showingEdit = true
            }
        }
        .sheet(isPresented: $showingEdit) {
            TaskFormView(pet: task.taskPet!)
                .environment(\.managedObjectContext, context)
                .environmentObject(PetCareViewModel())
        }
        .alert("Delete Task?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func deleteTask() {
        dismiss()
        context.delete(task)
        try? context.save()
    }
}

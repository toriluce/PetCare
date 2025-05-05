import SwiftUI

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var task: Task
    
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingPetDetails = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(task.title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                    Text(task.details?.isEmpty == false ? task.details! : "No details were added.")
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }

                GroupBox(label: Label("Schedule", systemImage: "calendar")) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let time = task.timeOfDay {
                            HStack {
                                Text("Time:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(time.formatted(date: .omitted, time: .shortened))
                            }
                        }
                        
                        if let freq = task.repeatFrequency, !freq.isEmpty {
                            HStack {
                                Text("Repeat:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(freq.capitalized)
                            }
                        }

                        HStack {
                            Text("Completed:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(task.isComplete ? "Yes" : "No")
                                .foregroundColor(task.isComplete ? .green : .secondary)
                        }
                    }
                    .padding(.top, 4)
                }

                let pet = task.pet

                Button(showingPetDetails ? "Hide Pet Details" : "Show Pet Details") {
                    withAnimation {
                        showingPetDetails.toggle()
                    }
                }

                if showingPetDetails {
                    GroupBox(label: Label("Pet Info", systemImage: "pawprint")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(pet.name)")
                            Text("Breed: \(pet.breed)")
                            Text("Species: \(pet.species)")
                            Text("Birthday: \(pet.birthday.formatted(date: .abbreviated, time: .omitted))")
                            if let notes = pet.notes, !notes.isEmpty {
                                Text("Notes: \(notes)")
                            }
                        }
                    }
                }

                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Task", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                showingEdit = true
            }
        }
        .sheet(isPresented: $showingEdit) {
            TaskFormView(pet: task.pet, existingTask: task)
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

import SwiftUI
import CoreData

struct PetDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddTask = false
    @State private var showingEditForm = false
    @State private var showDeleteAlert = false
    
    var pet: Pet
    
    @FetchRequest var tasks: FetchedResults<Task>
    @FetchRequest var logs: FetchedResults<Log>
    
    init(pet: Pet) {
        self.pet = pet
        _tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
            predicate: NSPredicate(format: "taskPet == %@", pet)
        )
        _logs = FetchRequest<Log>(
            entity: Log.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Log.timestamp, ascending: false)],
            predicate: NSPredicate(format: "logPet == %@", pet)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                taskSection
                logSection
                petInfoSection
                
                HStack {
                    Button("Edit Pet Info") {
                        showingEditForm = true
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Delete Pet Profile", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            petCareViewModel.resetTasksIfNeeded(for: pet, context: context)
        }
        .sheet(isPresented: $showingEditForm) {
            PetFormView(existingPet: pet)
                .environment(\.managedObjectContext, context)
                .environmentObject(petCareViewModel)
        }
        .sheet(isPresented: $showingAddTask) {
            TaskFormView(pet: pet)
                .environment(\.managedObjectContext, context)
                .environmentObject(petCareViewModel)
        }
        .alert("Delete Pet Profile", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                petCareViewModel.deletePet(pet, context: context)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deleting this pet profile will delete stored task logs and all related info. This action cannot be undone.")
        }
    }
    
    private var petInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Breed: \(pet.breed)")
            Text("Species: \(pet.species)")
            Text("Birthday: \(pet.birthday.formatted(date: .abbreviated, time: .omitted))")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tasks")
                .font(.headline)
            
            if tasks.isEmpty {
                Text("No tasks yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(tasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.body)
                            if let time = task.timeOfDay {
                                Text("Time: \(time.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Task Log")
                .font(.headline)
            
            if logs.isEmpty {
                Text("No completed tasks yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(logs) { log in
                    Text("Task: \(log.taskTitle) was completed on \(log.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                }
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    NavigationView {
        PetDetailView(pet: Pet.example)
            .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
            .environmentObject(PetCareViewModel())
    }
}

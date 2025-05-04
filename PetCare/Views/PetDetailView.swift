import SwiftUI
import CoreData

struct PetDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    @State private var showingAddTask = false
    @State private var showingEditForm = false
    @State private var showDeleteAlert = false
    @State private var editableTasks: [Task] = []
    
    var pet: Pet
    
    @FetchRequest var tasks: FetchedResults<Task>
    @FetchRequest var logs: FetchedResults<Log>
    
    init(pet: Pet) {
        self.pet = pet
        _tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.sortOrder, ascending: true)],
            predicate: NSPredicate(format: "pet == %@", pet)
        )
        _logs = FetchRequest<Log>(
            entity: Log.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Log.timestamp, ascending: false)],
            predicate: NSPredicate(format: "pet == %@", pet)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                taskSection
                logSection
                petInfoSection
                contactsSection
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear {
            editableTasks = tasks.sorted { $0.sortOrder < $1.sortOrder }
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
            Text("Notes: \(pet.notes ?? "")")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tasks")
                .font(.headline)
            
            if editableTasks.isEmpty {
                Text("No tasks yet.")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(editableTasks, id: \.self) { task in
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
                    .onMove(perform: moveTask)
                }
                .environment(\.editMode, editMode)
                .frame(height: CGFloat(editableTasks.count * 60))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(editMode?.wrappedValue == .active ? "Done" : "Reorder") {
                            editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                        }
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
    
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contacts")
                .font(.headline)
            
            if pet.sortedContacts.isEmpty {
                Text("No contacts available.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(pet.sortedContacts, id: \.id) { contact in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let phone = contact.phoneNumber, !phone.isEmpty {
                            Text("📞 \(phone)")
                        }
                        
                        if let address = contact.address, !address.isEmpty {
                            Text("\(address)")
                        }
                        
                        if let url = contact.websiteURL, let link = URL(string: url) {
                            Link("Website", destination: link)
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        editableTasks.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in editableTasks.enumerated() {
            task.sortOrder = Int64(index)
        }
        
        try? context.save()
    }
}

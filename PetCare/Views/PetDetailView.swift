import SwiftUI
import CoreData

struct PetDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    @State private var showingEditForm = false
    @State private var showDeleteAlert = false
    @State private var showingFullLog = false
    @State private var editableTasks: [Task] = []
    @State private var showingContactForm = false
    
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
                
                petInfoSection
                vaccinesSection
                pastAppointmentsSection
                contactsSection
                logSection
                
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
        .sheet(isPresented: $showingFullLog) {
            TaskLogView(pet: pet)
                .environment(\.managedObjectContext, context)
        }
        .sheet(isPresented: $showingEditForm) {
            PetFormView(existingPet: pet)
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
        GroupBox(label: Label("Pet Info", systemImage: "pawprint")) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Breed: \(pet.breed)")
                Text("Species: \(pet.species)")
                Text("Birthday: \(pet.birthday.formatted(date: .abbreviated, time: .omitted))")
                if let notes = pet.notes, !notes.isEmpty {
                    Text("Notes: \(notes)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
    }
    
    private var vaccinesSection: some View {
        GroupBox(label: Label("Vaccines", systemImage: "cross.case")) {
            VStack(alignment: .leading, spacing: 6) {
                if let vaccines = pet.vaccines, !vaccines.isEmpty {
                    ForEach(Array(vaccines), id: \.id) { vaccine in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vaccine.name)
                                .font(.headline)
                            
                            if let lastDate = vaccine.lastAdministered {
                                let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: lastDate)
                                Text("Last dose: \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                if let dueDate = dueDate {
                                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.footnote)
                                        .foregroundColor(vaccine.isOverdue ? .red : .secondary)
                                }
                            } else {
                                Text("No record of administration.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No vaccines recorded.")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var pastAppointmentsSection: some View {
        GroupBox(label: Label("Past Appointments", systemImage: "calendar")) {
            VStack(alignment: .leading, spacing: 6) {
                let pastAppointments = pet.sortedAppointments.filter { $0.date < Date() }
                
                if pastAppointments.isEmpty {
                    Text("No past appointments.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pastAppointments, id: \.id) { appointment in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appointment.title)
                                .font(.headline)
                            Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            if let notes = appointment.notes, !notes.isEmpty {
                                Text("Notes: \(notes)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var contactsSection: some View {
        GroupBox(label: Label("Contacts", systemImage: "person.crop.circle")) {
            VStack(alignment: .leading, spacing: 6) {
                if pet.sortedContacts.isEmpty {
                    Text("No contacts available.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pet.sortedContacts, id: \.id) { contact in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(contact.title)
                                .fontWeight(.semibold)
                            
                            if let phone = contact.phoneNumber, !phone.isEmpty {
                                Text("Phone Number: \(phone)")
                            }
                            
                            if let address = contact.address, !address.isEmpty {
                                Text("Address: \(address)")
                            }
                            
                            if let url = contact.websiteURL, let link = URL(string: url) {
                                Link("Website", destination: link)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                Button("Add Contact") {
                    showingContactForm = true
                }
                .font(.subheadline)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $showingContactForm) {
            ContactFormView(pet: pet)
                .environment(\.managedObjectContext, context)
        }
    }
    
    private var logSection: some View {
        GroupBox(label: Label("Recently Completed Tasks", systemImage: "checkmark.circle")) {
            VStack(alignment: .leading, spacing: 6) {
                if logs.isEmpty {
                    Text("No completed tasks yet.")
                        .foregroundColor(.secondary)
                } else {
                    let recentLogs = logs.prefix(3)
                    
                    ForEach(recentLogs) { log in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(log.taskTitle)
                                .fontWeight(.semibold)
                            Text("Completed on \(log.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if logs.count > 3 {
                        Button("View All Logs") {
                            showingFullLog = true
                        }
                        .font(.subheadline)
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

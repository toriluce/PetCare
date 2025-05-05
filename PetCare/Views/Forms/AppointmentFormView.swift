import SwiftUI
import CoreData

enum RepeatOption: String, CaseIterable, Identifiable {
    case oneTime = "One-time"
    case weekly = "Every Week"
    case monthly = "Every Month"
    case yearly = "Every Year"
    case custom = "Custom"

    var id: String { self.rawValue }

    var days: Int64 {
        switch self {
        case .oneTime: return 0
        case .weekly: return 7
        case .monthly: return 30
        case .yearly: return 365
        case .custom: return -1
        }
    }
}

struct AppointmentFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petCareViewModel: PetCareViewModel

    var existingAppointment: Appointment?

    @State private var selectedPetID: UUID
    @State private var title: String
    @State private var notes: String
    @State private var date: Date
    @State private var selectedContact: Contact?
    @State private var selectedVaccines: Set<Vaccine>

    @State private var showingAddContact = false
    @State private var showingAddVaccine = false
    @State private var contactOptions: [Contact]
    @State private var vaccineOptions: [Vaccine]

    @State private var selectedRepeatOption: RepeatOption = .oneTime
    @State private var customIntervalInDays: String = ""

    var isEditing: Bool { existingAppointment != nil }

    var pet: Pet {
        petCareViewModel.pets.first(where: { $0.id == selectedPetID }) ?? petCareViewModel.pets.first!
    }

    init(pet: Pet, existingAppointment: Appointment? = nil) {
        self.existingAppointment = existingAppointment

        let contacts = pet.sortedContacts
        let vaccines = pet.vaccines.map(Array.init) ?? []

        let intervalDays = existingAppointment?.intervalInDays ?? 0
        let repeatOption = RepeatOption.allCases.first(where: { $0.days == intervalDays }) ?? .custom

        _selectedPetID = State(initialValue: pet.id)
        _title = State(initialValue: existingAppointment?.title ?? "")
        _notes = State(initialValue: existingAppointment?.notes ?? "")
        _date = State(initialValue: existingAppointment?.date ?? SuggestedAppointmentManager.suggestNextAppointmentDate(for: pet))
        _selectedContact = State(initialValue: existingAppointment?.contact ?? contacts.first)
        _selectedVaccines = State(initialValue: existingAppointment?.vaccines ?? [])
        _contactOptions = State(initialValue: contacts)
        _vaccineOptions = State(initialValue: vaccines)
        _selectedRepeatOption = State(initialValue: repeatOption)
        _customIntervalInDays = State(initialValue: repeatOption == .custom ? "\(intervalDays)" : "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet")) {
                    Picker("Pet", selection: $selectedPetID) {
                        ForEach(petCareViewModel.pets, id: \.id) { pet in
                            Text(pet.name).tag(pet.id)
                        }
                    }
                }

                Section(header: Text("Appointment Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Repeat", selection: $selectedRepeatOption) {
                        ForEach(RepeatOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedRepeatOption == .custom {
                        TextField("Custom Interval (days)", text: $customIntervalInDays)
                            .keyboardType(.numberPad)
                    }
                }

                Section(header: Text("Contact")) {
                    Picker("Contact", selection: $selectedContact) {
                        ForEach(contactOptions, id: \.self) { contact in
                            Text(contact.title).tag(Optional(contact))
                        }
                    }
                    .pickerStyle(.menu)

                    if contactOptions.isEmpty {
                        Text("No contacts available.").foregroundColor(.secondary)
                    }

                    Button("Add New Contact") {
                        showingAddContact = true
                    }
                }

                Section(header: Text("Vaccines (Optional)")) {
                    if !vaccineOptions.isEmpty {
                        ForEach(vaccineOptions, id: \.self) { vaccine in
                            let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: vaccine.lastAdministered ?? .distantPast)
                            let isOverdue = dueDate != nil && dueDate! < Date()
                            let isSelected = selectedVaccines.contains(vaccine)

                            MultipleSelectionRow(
                                title: vaccine.name + (dueDate != nil ? " (due on \(dueDate!.formatted(date: .abbreviated, time: .omitted)))" : ""),
                                isSelected: isSelected,
                                isOverdue: isOverdue
                            ) {
                                if isSelected {
                                    selectedVaccines.remove(vaccine)
                                } else {
                                    selectedVaccines.insert(vaccine)
                                }
                            }
                        }
                    } else {
                        Text("No vaccines available.").foregroundColor(.secondary)
                    }

                    Button("Add New Vaccine") {
                        showingAddVaccine = true
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Appointment" : "Add Appointment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let contact = selectedContact else { return }

                        let intervalInDays: Int64 = {
                            if selectedRepeatOption == .custom {
                                return Int64(customIntervalInDays) ?? 0
                            } else {
                                return selectedRepeatOption.days
                            }
                        }()

                        petCareViewModel.addOrEditAppointment(
                            for: pet,
                            existingAppointment: existingAppointment,
                            title: title,
                            date: date,
                            contact: contact,
                            vaccines: Array(selectedVaccines),
                            notes: notes,
                            intervalInDays: intervalInDays,
                            context: context
                        )

                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedContact == nil)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPetID) {
                contactOptions = pet.sortedContacts
                vaccineOptions = pet.vaccines.map(Array.init) ?? []
                selectedContact = contactOptions.first
                selectedVaccines = []
            }
            .sheet(isPresented: $showingAddContact, onDismiss: refreshContactOptions) {
                ContactFormView(pet: pet)
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $showingAddVaccine, onDismiss: refreshVaccineOptions) {
                VaccineFormView(pet: pet, contactOptions: contactOptions)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(petCareViewModel)
            }
        }
    }

    private func refreshContactOptions() {
        contactOptions = pet.sortedContacts
        if selectedContact == nil {
            selectedContact = contactOptions.first
        }
    }

    private func refreshVaccineOptions() {
        vaccineOptions = pet.vaccines.map(Array.init) ?? []
    }
}

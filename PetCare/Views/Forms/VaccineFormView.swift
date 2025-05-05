import SwiftUI
import CoreData

struct VaccineFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petCareViewModel: PetCareViewModel

    var pet: Pet
    var existingVaccine: Vaccine?
    var contactOptions: [Contact]

    @State private var name: String
    @State private var years: Int
    @State private var months: Int
    @State private var lastAdministered: Date
    @State private var selectedContact: Contact?

    var isEditing: Bool {
        existingVaccine != nil
    }

    init(pet: Pet, existingVaccine: Vaccine? = nil, contactOptions: [Contact]) {
        self.pet = pet
        self.existingVaccine = existingVaccine
        self.contactOptions = contactOptions

        _name = State(initialValue: existingVaccine?.name ?? "")

        let totalDays = Int(existingVaccine?.intervalInDays ?? 0)
        let calcYears = totalDays / 365
        let calcMonths = (totalDays % 365) / 30

        _years = State(initialValue: calcYears)
        _months = State(initialValue: calcMonths)
        _lastAdministered = State(initialValue: existingVaccine?.lastAdministered ?? Date())
        _selectedContact = State(initialValue: existingVaccine?.contacts?.first ?? contactOptions.first)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaccine Details")) {
                    TextField("Name", text: $name)

                    HStack {
                        Stepper(value: $years, in: 0...20) {
                            Text("Every \(years) year\(years != 1 ? "s" : "")")
                        }
                    }

                    HStack {
                        Stepper(value: $months, in: 0...11) {
                            Text("\(months) month\(months != 1 ? "s" : "")")
                        }
                    }

                    DatePicker("Last Administered", selection: $lastAdministered, displayedComponents: .date)
                }

                Section(header: Text("Administered By")) {
                    Picker("Contact", selection: $selectedContact) {
                        ForEach(contactOptions, id: \.self) { contact in
                            Text(contact.title).tag(Optional(contact))
                        }
                    }
                    .pickerStyle(.menu)

                    if contactOptions.isEmpty {
                        Text("No contacts available.")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Vaccine" : "Add Vaccine")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let contact = selectedContact else { return }

                        let intervalInDays = (years * 365) + (months * 30)

                        let vaccine = existingVaccine ?? Vaccine(context: context)
                        vaccine.name = name
                        vaccine.intervalInDays = Int64(intervalInDays)
                        vaccine.lastAdministered = lastAdministered
                        vaccine.pet = pet
                        vaccine.contacts = [contact]

                        try? context.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || selectedContact == nil)
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

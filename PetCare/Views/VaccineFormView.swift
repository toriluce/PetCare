import SwiftUI
import CoreData

struct VaccineFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    
    var existingVaccine: Vaccine?
    var contactOptions: [Contact]
    
    @State private var name: String
    @State private var intervalInDays: Int
    @State private var lastAdministered: Date
    @State private var selectedContact: Contact?
    
    var isEditing: Bool {
        existingVaccine != nil
    }
    
    init(existingVaccine: Vaccine? = nil, contactOptions: [Contact]) {
        self.existingVaccine = existingVaccine
        self.contactOptions = contactOptions
        
        _name = State(initialValue: existingVaccine?.name ?? "")
        _intervalInDays = State(initialValue: Int(existingVaccine?.intervalInDays ?? 0))
        _lastAdministered = State(initialValue: existingVaccine?.lastAdministered ?? Date())
        _selectedContact = State(initialValue: existingVaccine?.contacts?.first)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaccine Details")) {
                    TextField("Name", text: $name)
                    Stepper(value: $intervalInDays, in: 0...3650) {
                        Text("Interval: \(intervalInDays) days")
                    }
                    DatePicker("Last Administered", selection: $lastAdministered, displayedComponents: .date)
                }
                
                Section(header: Text("Administered By")) {
                    Picker("Contact", selection: $selectedContact) {
                        ForEach(contactOptions, id: \.self) { contact in
                            Text(contact.title).tag(Optional(contact))
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Vaccine" : "Add Vaccine")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let contact = selectedContact else { return }
                        
                        petCareViewModel.addOrEditVaccine(
                            name: name,
                            intervalInDays: Int64(intervalInDays),
                            lastAdministered: lastAdministered,
                            contact: contact,
                            existingVaccine: existingVaccine,
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

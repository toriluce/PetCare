import SwiftUI

struct ContactFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var pet: Pet
    var existingContact: Contact?
    
    @State private var title = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var websiteURL = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Phone Number", text: $phoneNumber)
                TextField("Address", text: $address)
                TextField("Website URL", text: $websiteURL)
            }
            .navigationTitle(existingContact == nil ? "Add Contact" : "Edit Contact")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let contact = existingContact ?? Contact(context: context)
                        contact.title = title
                        contact.phoneNumber = phoneNumber
                        contact.address = address
                        contact.websiteURL = websiteURL
                        contact.pet = pet
                        
                        try? context.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let contact = existingContact {
                    title = contact.title
                    phoneNumber = contact.phoneNumber ?? ""
                    address = contact.address ?? ""
                    websiteURL = contact.websiteURL ?? ""
                }
            }
        }
    }
}

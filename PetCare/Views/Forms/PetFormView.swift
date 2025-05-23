import SwiftUI

struct PetFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss

    var existingPet: Pet?

    @State private var name = ""
    @State private var breed = ""
    @State private var species = ""
    @State private var birthday = Date()
    @State private var notes = ""

    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false

    @State private var showContactForm = false
    @State private var selectedContact: Contact?

    var contacts: [Contact] {
        existingPet?.contacts?.sorted { $0.title < $1.title } ?? []
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    HStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                        }

                        Button("Choose Photo") {
                            showingImagePicker = true
                        }
                    }
                }

                Section(header: Text("Pet Details")) {
                    TextField("Name", text: $name)
                    TextField("Species", text: $species)
                    TextField("Breed", text: $breed)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    TextField("Notes", text: $notes)
                }

                if existingPet != nil {
                    Section(header: Text("Contacts")) {
                        ForEach(contacts, id: \.id) { contact in
                            VStack(alignment: .leading) {
                                Text(contact.title).font(.headline)
                                if let phone = contact.phoneNumber { Text("Phone: \(phone)") }
                                if let address = contact.address { Text("Address: \(address)") }
                                if let site = contact.websiteURL {
                                    Link("Website", destination: URL(string: site)!)
                                }
                            }
                            .onTapGesture {
                                selectedContact = contact
                                showContactForm = true
                            }
                        }

                        Button("Add Contact") {
                            selectedContact = nil
                            showContactForm = true
                        }
                    }
                }
            }
            .navigationTitle(existingPet == nil ? "Add Pet" : "Edit Pet")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)

                        if let pet = existingPet {
                            petCareViewModel.editPet(
                                pet,
                                name: name,
                                breed: breed,
                                species: species,
                                birthday: birthday,
                                notes: notes,
                                imageData: imageData,
                                context: context
                            )
                        } else {
                            petCareViewModel.addPet(
                                name: name,
                                breed: breed,
                                species: species,
                                birthday: birthday,
                                notes: notes,
                                imageData: imageData,
                                context: context
                            )
                        }
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showContactForm) {
                if let pet = existingPet {
                    ContactFormView(pet: pet, existingContact: selectedContact)
                        .environment(\.managedObjectContext, context)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                if let pet = existingPet {
                    name = pet.name
                    breed = pet.breed
                    species = pet.species
                    birthday = pet.birthday
                    notes = pet.notes ?? ""
                    if let data = pet.photo {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
        }
    }
}

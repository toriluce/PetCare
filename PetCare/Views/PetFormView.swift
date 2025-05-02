import SwiftUI

struct PetFormView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petViewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss

    var petToEdit: Pet?

    @State private var name = ""
    @State private var breed = ""
    @State private var species = ""
    @State private var birthday = Date()

    var isEditing: Bool {
        petToEdit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isEditing ? "Edit Pet Details" : "New Pet")) {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    TextField("Species", text: $species)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }
            }
            .navigationTitle(isEditing ? "Edit Pet" : "Add Pet")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let pet = petToEdit {
                            petViewModel.updatePet(pet, name: name, breed: breed, species: species, birthday: birthday, context: context)
                        } else {
                            petViewModel.addPet(name: name, breed: breed, species: species, birthday: birthday, context: context)
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
            .onAppear {
                if let pet = petToEdit {
                    name = pet.name
                    breed = pet.breed
                    species = pet.species
                    birthday = pet.birthday
                }
            }
        }
    }
}

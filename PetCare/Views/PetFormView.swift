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
    
    var isEditing: Bool {
        existingPet != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet Details")) {
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
                        if let pet = existingPet {
                            petCareViewModel.editPet(pet, name: name, breed: breed, species: species, birthday: birthday, context: context)
                        } else {
                            petCareViewModel.addPet(name: name, breed: breed, species: species, birthday: birthday, context: context)
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
                if let pet = existingPet {
                    name = pet.name
                    breed = pet.breed
                    species = pet.species
                    birthday = pet.birthday
                }
            }
        }
    }
}

#Preview {
    PetFormView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(PetCareViewModel())
}

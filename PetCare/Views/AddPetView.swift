import SwiftUI

struct AddPetView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petViewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var species = ""
    @State private var birthday = Date()
    
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
            .navigationTitle("Add Pet")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        petViewModel.addPet(name: name, breed: breed, species: species, birthday: birthday, context: context)
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

#Preview {
    AddPetView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(PetViewModel())
}

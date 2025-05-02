import SwiftUI

struct PetDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.dismiss) private var dismiss
    
    var pet: Pet

    @State private var showingEditForm = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text(pet.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Breed: \(pet.breed)")
            Text("Species: \(pet.species)")
            Text("Birthday: \(pet.birthday, style: .date)")

            Spacer()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Pet", systemImage: "trash")
            }
        }
        .padding()
        .navigationTitle("Pet Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditForm = true
                }
            }
        }
        .sheet(isPresented: $showingEditForm) {
            PetFormView(existingPet: pet) 
                .environmentObject(petCareViewModel)
                .environment(\.managedObjectContext, context)
        }
        .alert("Delete Pet?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                petCareViewModel.deletePet(pet, context: context)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationView {
        PetDetailView(pet: Pet.example)
            .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
            .environmentObject(PetCareViewModel())
    }
}

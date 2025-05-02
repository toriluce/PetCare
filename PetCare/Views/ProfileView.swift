import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.managedObjectContext) private var context

    @State private var showingAddPet = false
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Pets")) {
                    ForEach(petCareViewModel.pets, id: \.id) { pet in
                        NavigationLink(destination: PetDetailView(pet: pet)) {
                            VStack(alignment: .leading) {
                                Text(pet.name)
                                    .font(.headline)
                                Text("Birthday: \(pet.birthday, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                petToDelete = pet
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingAddPet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                PetFormView()
                    .environmentObject(petCareViewModel)
                    .environment(\.managedObjectContext, context)
            }
            .alert("Delete Pet?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let pet = petToDelete {
                        petCareViewModel.deletePet(pet, context: context)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                petCareViewModel.fetchPets(context: context)
            }
        }
    }
}

#Preview {
    let previewViewModel = PetCareViewModel()
    previewViewModel.pets = [Pet.example, Pet.example2]

    return ProfileView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewViewModel)
}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.managedObjectContext) private var context
    
    @State private var showingAddPet = false
    @State private var selectedPet: Pet?
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Pets")) {
                    ForEach(petCareViewModel.pets, id: \.id) { pet in
                        VStack(alignment: .leading) {
                            Text(pet.name)
                                .font(.headline)
                            Text("Birthday: \(pet.birthday, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                petToDelete = pet
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedPet = pet
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
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

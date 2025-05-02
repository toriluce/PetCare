import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var petViewModel: PetViewModel
    @Environment(\.managedObjectContext) private var context

    @State private var showingAddPet = false
    @State private var selectedPet: Pet?
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Pets")) {
                    ForEach(petViewModel.pets, id: \.id) { pet in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                PetFormView(petToEdit: nil)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(petViewModel)
            }
            .sheet(item: $selectedPet) { pet in
                PetFormView(petToEdit: pet)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(petViewModel)
            }
            .alert("Delete Pet?", isPresented: $showDeleteAlert, presenting: petToDelete) { pet in
                Button("Delete", role: .destructive) {
                    petViewModel.deletePet(pet, context: context)
                }
                Button("Cancel", role: .cancel) {}
            } message: { pet in
                Text("Are you sure you want to delete \(pet.name)? This cannot be undone.")
            }
            .onAppear {
                petViewModel.fetchPets(context: context)
            }
        }
    }
}

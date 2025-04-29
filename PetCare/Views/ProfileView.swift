import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var petViewModel: PetViewModel
    @Environment(\.managedObjectContext) private var context
    
    @State private var showingAddPet = false
    
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
                AddPetView()
                    .environmentObject(petViewModel)
                    .environment(\.managedObjectContext, context)
            }
            .onAppear {
                petViewModel.fetchPets(context: context)
            }
        }
    }
}

#Preview {
    let previewViewModel = PetViewModel()
    previewViewModel.pets = [PetEntity.example, PetEntity.example2]
    
    return ProfileView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewViewModel)
}

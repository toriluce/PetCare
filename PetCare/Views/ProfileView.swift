import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var context
    
    @State private var showingAddPet = false
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false
    
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
    ) var pets: FetchedResults<Pet>
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Pets")) {
                    ForEach(pets, id: \.id) { pet in
                        NavigationLink(destination: PetDetailView(pet: pet)) {
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
#if DEBUG
                NotificationDebugView()
#endif
                
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
                    .environment(\.managedObjectContext, context)
            }
        }
    }
}

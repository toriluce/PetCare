import SwiftUI
import CoreData
struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var viewModel: PetCareViewModel
    
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
    ) var pets: FetchedResults<Pet>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if pets.isEmpty {
                    Text("Add a pet from the profile tab to get started")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(pets, id: \.id) { pet in
                        PetView(pet: pet)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("My Pets")
        .refreshable {
            viewModel.fetchPets(context: context)
        }
    }
}

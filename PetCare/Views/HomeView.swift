import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if petCareViewModel.pets.isEmpty {
                        Text("Add a pet from the profile tab to get started")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ForEach(petCareViewModel.pets, id: \.id) { pet in
                            PetView(pet: pet)
                                .environmentObject(petCareViewModel)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Pets")
        }
    }
}

#Preview {
    let previewViewModel = PetCareViewModel()
    previewViewModel.pets = [Pet.example, Pet.example2]
    
    return HomeView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewViewModel)
}

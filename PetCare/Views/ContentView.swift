import SwiftUI

struct ContentView: View {
    @StateObject var petCareViewModel = PetCareViewModel()
    @Environment(\.managedObjectContext) private var context
    @State private var isProfileMenuOpen = false
    
    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(petCareViewModel)
                .navigationBarTitle("Pet Care", displayMode: .large)
                .navigationBarItems(trailing: Button(action: {
                    isProfileMenuOpen.toggle()
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                })
                .sheet(isPresented: $isProfileMenuOpen) {
                    ProfileView()
                        .environmentObject(petCareViewModel)
                }
        }
        .onAppear {
            petCareViewModel.fetchPets(context: context)
        }
    }
}

#Preview {
    let context = PreviewPersistenceController.shared.container.viewContext

    // Create example pets manually and add them to the view model
    let pet1 = Pet.example
    let pet2 = Pet.example2

    let viewModel = PetCareViewModel()
    viewModel.pets = [pet1, pet2]

    return ContentView()
        .environment(\.managedObjectContext, context)
        .environmentObject(viewModel)
}

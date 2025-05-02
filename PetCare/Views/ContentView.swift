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
    let previewModel = PetCareViewModel()
    previewModel.pets = [Pet.example, Pet.example2]
    
    return ContentView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewModel)
}

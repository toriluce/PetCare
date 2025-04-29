import SwiftUI

struct ContentView: View {
    @StateObject var petViewModel = PetViewModel()
    @Environment(\.managedObjectContext) private var context
    @State private var isProfileMenuOpen = false
    
    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(petViewModel)
                .navigationBarTitle("Pet Care", displayMode: .large)
                .navigationBarItems(trailing: Button(action: {
                    isProfileMenuOpen.toggle()
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                })
                .sheet(isPresented: $isProfileMenuOpen) {
                    ProfileView()
                        .environmentObject(petViewModel)
                }
        }
        .onAppear {
            petViewModel.fetchPets(context: context)
        }
    }
}

#Preview {
    let previewModel = PetViewModel()
    previewModel.pets = [PetEntity.example, PetEntity.example2]
    
    return ContentView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewModel)
}

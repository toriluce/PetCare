import SwiftUI

struct ContentView: View {
    @StateObject var petViewModel = PetViewModel()
    @StateObject var taskViewModel = TaskViewModel()
    @Environment(\.managedObjectContext) private var context
    @State private var isProfileMenuOpen = false

    var body: some View {
        NavigationView {
            HomeView()
                .navigationBarTitle("PetCare", displayMode: .large)
                .navigationBarItems(trailing: Button(action: {
                    isProfileMenuOpen.toggle()
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                })
                .sheet(isPresented: $isProfileMenuOpen) {
                    ProfileView()
                }
        }
        .environmentObject(petViewModel)
        .environmentObject(taskViewModel)
        .onAppear {
            petViewModel.fetchPets(context: context)
        }
    }
}

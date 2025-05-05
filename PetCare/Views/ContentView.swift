import SwiftUI

struct ContentView: View {
    @StateObject var petCareViewModel = PetCareViewModel()
    @Environment(\.managedObjectContext) private var context
    @State private var isProfileMenuOpen = false
    @State private var showAppointments = false
    
    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(petCareViewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showAppointments = true
                        }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("My Pets")
                            .font(.headline)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isProfileMenuOpen = true
                        }) {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $isProfileMenuOpen) {
                    NavigationStack {
                        ProfileView()
                            .environment(\.managedObjectContext, context)
                            .environmentObject(petCareViewModel)
                    }}
                .sheet(isPresented: $showAppointments) {
                    NavigationStack {
                        CalendarView(pets: petCareViewModel.pets)
                            .environment(\.managedObjectContext, context)
                            .environmentObject(petCareViewModel)
                    }
                }

        }
        .onAppear {
            petCareViewModel.fetchPets(context: context)
        }
    }
}

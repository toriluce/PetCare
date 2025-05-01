import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petViewModel: PetCareViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(petViewModel.pets, id: \.id) { pet in
                        PetView(pet: pet)
                            .environmentObject(petViewModel)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
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

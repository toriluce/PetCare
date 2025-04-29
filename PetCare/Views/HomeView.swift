import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petViewModel: PetViewModel
    
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
    let previewViewModel = PetViewModel()
    previewViewModel.pets = [PetEntity.example, PetEntity.example2]
    
    return HomeView()
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
        .environmentObject(previewViewModel)
}

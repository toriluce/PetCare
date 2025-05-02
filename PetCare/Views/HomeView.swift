import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petViewModel: PetViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(petViewModel.pets, id: \ .id) { pet in
                    PetView(pet: pet)
                }
            }
            .padding()
        }
    }
}

#Preview {
    let context = PreviewPersistenceController.shared.container.viewContext
    let viewModel = PetViewModel()
    
    viewModel.pets = [Pet.example, Pet.example2]

    return HomeView()
        .environmentObject(viewModel)
        .environment(\.managedObjectContext, context)
}

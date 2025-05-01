import SwiftUI

struct PetView: View {
    @EnvironmentObject var petViewModel: PetCareViewModel
    @Environment(\.managedObjectContext) private var context
    
    var pet: Pet
    
    @State private var showingAddTask = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pet.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            TaskListView(tasks: Array(pet.tasks ?? []))
            
            Button("Add Task") {
                showingAddTask = true
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) 
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(pet: pet)
                .environmentObject(petViewModel)
                .environment(\.managedObjectContext, context)
        }
    }
}

#Preview {
    PetView(pet: Pet.example)
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environmentObject(PetCareViewModel())
}

import SwiftUI
import CoreData

struct PetView: View {
    @Environment(\.managedObjectContext) private var context
    
    var pet: Pet
    @State private var showingAddTask = false
    
    @FetchRequest var tasks: FetchedResults<Task>
    
    init(pet: Pet) {
        self.pet = pet
        _tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
            predicate: NSPredicate(format: "taskPet == %@", pet)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pet.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            TaskListView(tasks: Array(tasks))
            
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
        .sheet(isPresented: $showingAddTask) {
            TaskFormView(pet: pet)
                .environment(\.managedObjectContext, context)
        }
    }
}

#Preview {
    PetView(pet: Pet.example)
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
}

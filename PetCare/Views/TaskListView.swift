import SwiftUI

struct TaskListView: View {
    var pet: Pet
    var tasks: [Task]
    
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.managedObjectContext) private var context
    
    @State private var taskToEdit: Task?
    @State private var showingReorderSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .padding(.bottom, 4)
                Spacer()
                Button("Edit Task Order") {
                    showingReorderSheet = true
                }}
            
            ForEach(pet.sortedTasks, id: \.self) { task in
                TaskView(task: task)
            }
        }
        .sheet(isPresented: $showingReorderSheet) {
            EditTaskOrderView(pet: pet)
                .environment(\.managedObjectContext, context)
        }
    }
}

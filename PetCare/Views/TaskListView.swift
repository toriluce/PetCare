import SwiftUI

struct TaskListView: View {
    var tasks: [Task]
    
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @Environment(\.managedObjectContext) private var context
    
    @State private var taskToEdit: Task?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tasks")
                .font(.title2)
                .padding(.bottom, 4)
            
            ForEach(tasks, id: \.self) { task in
                TaskView(task: task)
            }
        }
    }
}

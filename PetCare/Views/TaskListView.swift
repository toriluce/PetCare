import SwiftUI

struct TaskListView: View {
    var tasks: [TaskEntity]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tasks")
                .font(.title2)
            ForEach(tasks, id: \.self) { task in
                TaskView(task: task)
            }
        }
    }
}

#Preview {
    TaskListView(tasks: [TaskEntity.example, TaskEntity.example2])
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
}

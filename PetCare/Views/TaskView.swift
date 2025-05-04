import SwiftUI

struct TaskView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    @ObservedObject var task: Task
    
    var body: some View {
        NavigationLink(destination: TaskDetailView(task: task)) {
            HStack {
                Button(action: toggleComplete) {
                    Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isComplete ? .green : .gray)
                        .font(.title)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isComplete ? .gray : .primary)
                        .strikethrough(task.isComplete, color: .gray)
                    
                    if let details = task.details, !details.isEmpty {
                        Text(details)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .padding(.vertical, 4)
        }
    }
    
    private func toggleComplete() {
        petCareViewModel.completeTask(task, context: context)
    }
}

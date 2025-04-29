import SwiftUI

struct TaskView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var task: TaskEntity
    
    var body: some View {
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
                
                if !task.details.isEmpty {
                    Text(task.details)
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
        .padding(.horizontal)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleComplete()
        }
    }
    
    private func toggleComplete() {
        task.isComplete.toggle()
        save()
    }
    
    private func save() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
        }
    }
}

#Preview {
    TaskView(task: TaskEntity.example)
        .environment(\.managedObjectContext, PreviewPersistenceController.shared.container.viewContext)
}

import SwiftUI
struct TaskView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var task: Task
    var onEdit: ((Task) -> Void)? = nil

    var body: some View {
        HStack {
            Button(action: toggleComplete) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isComplete ? .green : .gray)
                    .font(.title)
            }

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleComplete()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                context.delete(task)
                save()
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                onEdit?(task)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    private func toggleComplete() {
        task.isComplete.toggle()
        save()
    }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

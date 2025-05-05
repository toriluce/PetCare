import SwiftUI
import CoreData

struct TaskLogView: View {
    var pet: Pet
    
    @FetchRequest var logs: FetchedResults<Log>
    @Environment(\.dismiss) private var dismiss

    init(pet: Pet) {
        self.pet = pet
        _logs = FetchRequest<Log>(
            entity: Log.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Log.timestamp, ascending: false)],
            predicate: NSPredicate(format: "pet == %@", pet)
        )
    }

    var body: some View {
        NavigationView {
            List {
                if logs.isEmpty {
                    Text("No completed tasks yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(logs) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.taskTitle)
                                .font(.headline)
                            Text("Completed on \(log.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Task Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

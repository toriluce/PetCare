import SwiftUI
import CoreData

struct EditTaskOrderView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    var pet: Pet
    @State private var tasks: [Task] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks, id: \.self) { task in
                    Text(task.title)
                }
                .onMove(perform: move)
            }
            .navigationTitle("Reorder Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveOrder()
                        dismiss()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .onAppear {
                tasks = pet.tasks?.sorted(by: { $0.sortOrder < $1.sortOrder }) ?? []
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }

    private func saveOrder() {
        for (index, task) in tasks.enumerated() {
            task.sortOrder = Int64(index)
        }
        try? context.save()
    }
}

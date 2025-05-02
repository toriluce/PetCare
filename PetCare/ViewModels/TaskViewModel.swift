import Foundation
import CoreData

class TaskViewModel: ObservableObject {
    func addTask(to pet: Pet, title: String, details: String, isComplete: Bool, frequency: Date?, context: NSManagedObjectContext) {
        let newTask = Task(context: context)
        newTask.title = title
        newTask.details = details
        newTask.isComplete = isComplete
        newTask.frequency = frequency
        newTask.taskPet = pet

        print("🟢 Adding task '\(title)' to pet '\(pet.name)'")
        saveContext(context)
    }

    func updateTask(_ task: Task, title: String, details: String, isComplete: Bool, frequency: Date?, context: NSManagedObjectContext) {
        print("🔵 Updating task '\(task.title)'")

        task.title = title
        task.details = details
        task.isComplete = isComplete
        task.frequency = frequency
        saveContext(context)
    }

    func deleteTask(_ task: Task, context: NSManagedObjectContext) {
        print("🗑️ Deleting task '\(task.title)'")
        context.delete(task)
        saveContext(context)
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            print("✅ Context saved")
        } catch {
            print("❌ Failed to save context: \(error.localizedDescription)")
        }
    }
}

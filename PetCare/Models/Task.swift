import Foundation
import CoreData

final class Task: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var details: String?
    @NSManaged var isComplete: Bool
    @NSManaged var frequency: Date?
    @NSManaged var taskPet: Pet?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(false, forKey: "isComplete")
    }
}

extension Task {
    static var example: Task {
        let context = PreviewPersistenceController.shared.container.viewContext
        let task = Task(context: context)
        task.title = "Breakfast"
        task.details = "Dog food is in the pantry. Use half a can and one scoop."
        task.isComplete = false
        return task
    }

    static var example2: Task {
        let context = PreviewPersistenceController.shared.container.viewContext
        let task = Task(context: context)
        task.title = "Dinner"
        task.details = "Dog food is in the pantry. Use half a can and one scoop."
        task.isComplete = false
        return task
    }
}

import Foundation
import CoreData

final class TaskEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var details: String
    @NSManaged var isComplete: Bool
    @NSManaged var frequency: Date?
    @NSManaged var taskPet: PetEntity?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(false, forKey: "isComplete")
    }
}

extension TaskEntity {
    static var example: TaskEntity {
        let context = PreviewPersistenceController.shared.container.viewContext
        let task = TaskEntity(context: context)
        task.title = "Breakfast"
        task.details = "Dog food is in the pantry. Use half a can and one scoop."
        task.isComplete = false
        return task
    }
    
    static var example2: TaskEntity {
        let context = PreviewPersistenceController.shared.container.viewContext
        let task = TaskEntity(context: context)
        task.title = "Dinner"
        task.details = "Dog food is in the pantry. Use half a can and one scoop."
        task.isComplete = false
        return task
    }
}

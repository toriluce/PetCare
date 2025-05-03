import Foundation
import CoreData

final class Task: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var details: String?
    @NSManaged var isComplete: Bool
    @NSManaged var frequency: String?
    @NSManaged var timeOfDay: Date?
    @NSManaged var lastCompletedAt: Date?
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
        task.frequency = "daily"
        task.timeOfDay = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
        task.lastCompletedAt = nil

        let pet = Pet(context: context)
        pet.id = UUID()
        pet.name = "Brody"
        pet.breed = "Yorkie"
        pet.species = "Dog"
        pet.birthday = Date()

        task.taskPet = pet
        pet.tasks = [task]

        return task
    }

    static var example2: Task {
        let context = PreviewPersistenceController.shared.container.viewContext

        let task = Task(context: context)
        task.id = UUID()
        task.title = "Clean Litterbox"
        task.details = "Bags sit beside box"
        task.isComplete = false
        task.frequency = "weekly"
        task.timeOfDay = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
        task.lastCompletedAt = nil

        return task
    }
}

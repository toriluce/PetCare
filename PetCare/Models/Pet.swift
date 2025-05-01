import Foundation
import CoreData

final class Pet: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var breed: String
    @NSManaged var birthday: Date
    @NSManaged var species: String
    @NSManaged var tasks: Set<Task>?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

extension Pet {
    static var example: Pet {
        let context = PreviewPersistenceController.shared.container.viewContext
        let pet = Pet(context: context)
        pet.name = "Brody"
        pet.breed = "Yorkie"
        pet.species = "Dog"
        pet.birthday = Date()
        
        let task1 = Task(context: context)
        task1.title = "Breakfast"
        task1.details = "Dog food is in the pantry. Use half a can and one scoop."
        task1.isComplete = false
        task1.taskPet = pet
        
        let task2 = Task(context: context)
        task2.title = "Dinner"
        task2.details = "Dog food is in the pantry. Use half a can and one scoop."
        task2.isComplete = false
        task2.taskPet = pet
        
        pet.tasks = [task1, task2]
        
        return pet
    }
    
    static var example2: Pet {
        let context = PreviewPersistenceController.shared.container.viewContext
        let pet = Pet(context: context)
        pet.name = "Nala"
        pet.breed = "Shorthair"
        pet.species = "Cat"
        pet.birthday = Date()
        pet.tasks = []
        
        return pet
    }
}

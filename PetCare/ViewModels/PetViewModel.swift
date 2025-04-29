import Foundation
import SwiftUI
import CoreData

class PetViewModel: ObservableObject {
    @Published var pets: [PetEntity] = []
    
    func fetchPets(context: NSManagedObjectContext) {
        let request = NSFetchRequest<PetEntity>(entityName: "PetEntity")
        do {
            pets = try context.fetch(request)
        } catch {
            print("Failed to fetch pets: \(error)")
        }
    }
    
    
    func addPet(name: String, breed: String, species: String, birthday: Date?, context: NSManagedObjectContext) {
        let newPet = PetEntity(context: context)
        newPet.name = name
        newPet.breed = breed
        newPet.species = species
        newPet.birthday = birthday ?? Date()
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save pet: \(error)")
        }
    }
    
    
    func addTask(to pet: PetEntity, title: String, details: String, dueDate: Date?, isComplete: Bool, frequency: Date?, context: NSManagedObjectContext) {
        let newTask = TaskEntity(context: context)
        newTask.title = title
        newTask.details = details
        newTask.isComplete = isComplete
        newTask.frequency = frequency
        newTask.taskPet = pet
        
        var taskSet = pet.tasks ?? []
        taskSet.insert(newTask)
        pet.tasks = taskSet
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

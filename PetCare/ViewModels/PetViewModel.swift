import Foundation
import SwiftUI
import CoreData

class PetViewModel: ObservableObject {
    @Published var pets: [Pet] = []

    func fetchPets(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Pet>(entityName: "Pet")
        do {
            pets = try context.fetch(request)
        } catch {
            print("Failed to fetch pets: \(error.localizedDescription)")
        }
    }

    func addPet(name: String, breed: String, species: String, birthday: Date?, context: NSManagedObjectContext) {
        let newPet = Pet(context: context)
        newPet.name = name
        newPet.breed = breed
        newPet.species = species
        newPet.birthday = birthday ?? Date()
        saveContext(context)
    }

    func updatePet(_ pet: Pet, name: String, breed: String, species: String, birthday: Date, context: NSManagedObjectContext) {
        pet.name = name
        pet.breed = breed
        pet.species = species
        pet.birthday = birthday
        saveContext(context)
    }

    func deletePet(_ pet: Pet, context: NSManagedObjectContext) {
        context.delete(pet)
        saveContext(context)
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}

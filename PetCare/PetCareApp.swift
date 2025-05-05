import SwiftUI

@main
struct PetCareApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        TaskNotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tint(Color.purple)
        }
    }
}

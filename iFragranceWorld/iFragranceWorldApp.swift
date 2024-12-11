import SwiftUI
import CoreData

@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        // I've been making updates to the csv data so I added a check to see if it populated or not so i don't reinsert data
        if !isCoreDataPopulated() { // Check if Core Data is already populated
            clearCoreData()
            importCSVData()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    // Empties core data
    private func clearCoreData() {
        let context = persistenceController.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("CoreData cleared successfully.")
        } catch {
            print("Failed to clear CoreData: \(error)")
        }
    }

    // Imports the data within the CSV file into core data
    private func importCSVData() {
        guard let fileURL = Bundle.main.url(forResource: "fra_cleaned", withExtension: "csv") else {
            print("Failed to locate the file fra_cleaned.csv in the bundle.")
            return
        }

        guard let parsedData = DataImporter.parseCSV(fileURL: fileURL) else {
            print("Failed to parse the CSV file.")
            return
        }

        DataImporter.importToCoreData(parsedData: parsedData, context: PersistenceController.shared.container.viewContext)
        print("CSV data imported successfully.")
    }

    // Function to check if there is data inside core data
    private func isCoreDataPopulated() -> Bool {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)
            print("Core Data contains \(count) items.")
            return count > 0
        } catch {
            print("Failed to check Core Data population: \(error)")
            return false
        }
    }
}

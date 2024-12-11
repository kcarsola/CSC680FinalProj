import Foundation
import CoreData

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

struct DataImporter {
    // The main use of the function is to transform the url that is in the dataset to a proper image link using the ID in the url.
    private static func transformURL(originalURL: String) -> String? {
        
        guard let id = originalURL.split(separator: "-").last?.split(separator: ".").first else {
            print("Failed to extract ID from URL: \(originalURL)")
            return nil
        }
        
        // Construct the new URL using the extracted ID
        return "https://fimgs.net/mdimg/perfume/375x500.\(id).jpg"
    }
    // Main parsing funciton for the data
    static func parseCSV(fileURL: URL) -> [[String: String]]? {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = content.components(separatedBy: "\n").filter { !$0.isEmpty }
            
            // Sets the first row as the header where it is separated by ";"
            guard let header = rows.first?.components(separatedBy: ";") else {
                print("Invalid CSV format: Missing header row.")
                return nil
            }
            
            // Print headers for debugging
            //print("CSV Headers: \(header.map { $0.debugDescription })")
            
            return rows.dropFirst().map { row in
                let values = row.components(separatedBy: ";")
                return Dictionary(uniqueKeysWithValues: zip(header, values))
            }
        } catch {
            print("Failed to read the file: \(error)")
            return nil
        }
    }
    
    // Main function to import into CoreData
    static func importToCoreData(parsedData: [[String: String]], context: NSManagedObjectContext) {
        // I'm unable to find a proper solution to display data. So currently it load all the data in the background which makes it laggy when searching
        // I decided to divide my data to make it bearable when searching for a fragrance
        let halfwayIndex = parsedData.count / 3
        
        context.perform {
            for record in parsedData.prefix(halfwayIndex) {
                let fragrance = Item(context: context)
                
                let perfumeName = record["Perfume"]?
                // Replace "-" with " "
                    .replacingOccurrences(of: "-", with: " ")
                    .capitalizedFirstLetter() ?? "Unknown"
                fragrance.name = perfumeName
                
                let brandName = record["Brand"] ?? "Unknown"
                fragrance.brand = brandName.capitalizedFirstLetter()
                
                fragrance.gender = record["Gender"] ?? "Unisex"
                fragrance.base_notes = record["Base"] ?? "Unknown"
                fragrance.top_notes = record["Top"] ?? "Unknown"
                fragrance.middle_notes = record["Middle"] ?? "Unknown"
                
                let originalURL = record["url"] ?? ""
                let transformedURL = transformURL(originalURL: originalURL) ?? "No URL"
                fragrance.url = transformedURL
            
                fragrance.year = record["Year"] ?? "Unknown"
                
                // Debugging
                //print("Added fragrance: \(fragrance.name ?? "Unknown")")
            }
            
            do {
                try context.save()
                print("Data imported successfully!")
            } catch {
                print("Failed to save data: \(error)")
            }
        }
    }
}

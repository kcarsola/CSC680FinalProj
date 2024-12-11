import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    private var items: FetchedResults<Item>

    @State private var searchText = ""
    @State private var displayCount = 10
    @State private var selectedFragrance: Item?

    @State private var selectedNotes: Set<String> = []
    @State private var isNotesDropDownOpen: Bool = false
    @State private var visibleNotesCount: Int = 5

    @State private var selectedGenders: Set<String> = []
    @State private var isGenderDropDownOpen: Bool = false
    
    // Gets all unique notes across all items
    private var allNotes: [String] {
        var notesSet = Set<String>()
        for item in items {
            notesSet.formUnion(item.base_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? [])
            notesSet.formUnion(item.middle_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? [])
            notesSet.formUnion(item.top_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? [])
        }
        return Array(notesSet).sorted()
    }
    // Do to complications of my dataset being large, there was lag when searching and filtering. With the help of a LLM, it helped to condense and optimize filtering items so that is what I did here.
    private var filteredItems: [Item] {
        let normalizedSearchText = searchText.lowercased()
        let searchWords = normalizedSearchText.split(separator: " ").map { String($0) }

        let searchFilteredItems = items.filter { item in
            let combinedString = "\(item.brand ?? "") \(item.name ?? "")".lowercased()
            return searchWords.allSatisfy { combinedString.contains($0) }
        }

        let notesFilteredItems = searchFilteredItems.filter { item in
            let baseNotes = item.base_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
            let middleNotes = item.middle_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
            let topNotes = item.top_notes?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []

            let fragranceNotes = Set(baseNotes + middleNotes + topNotes)
            return selectedNotes.isEmpty || selectedNotes.isSubset(of: fragranceNotes)
        }

        return notesFilteredItems.filter { item in
            selectedGenders.isEmpty || (item.gender != nil && selectedGenders.contains(item.gender!))
        }
    }
    // Groups the items by 2, I wasn't able to efficiently display the items and make it look nice so I used an LLM
    // to help identify the a solution
    private var groupedItems: [[Item]] {
        let limitedItems = Array(filteredItems.prefix(displayCount))
        return stride(from: 0, to: limitedItems.count, by: 2).map {
            Array(limitedItems[$0..<min($0 + 2, limitedItems.count)])
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search by brand or perfume name", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                
                FilterView(
                    selectedNotes: $selectedNotes,
                    isNotesDropDownOpen: $isNotesDropDownOpen,
                    visibleNotesCount: $visibleNotesCount,
                    selectedGenders: $selectedGenders,
                    isGenderDropDownOpen: $isGenderDropDownOpen,
                    allNotes: allNotes
                )
                .padding(.horizontal)

                List {
                    ForEach(groupedItems, id: \.self) { row in
                        HStack(spacing: 16) {
                            ForEach(row, id: \.self) { item in
                                Button(action: {
                                    selectedFragrance = item
                                    //Debugging
                                    print("Selected fragrance: \(item.name ?? "Unknown")")
                                }) {
                                    VStack {
                                        // Displays the image that we parsed and created in DataImporter
                                        AsyncImage(url: URL(string: item.url ?? "")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView().frame(width: 100, height: 100)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .foregroundColor(.gray) // gray
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        Text(item.brand ?? "Unknown Brand")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(item.name ?? "Unknown Perfume")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.brown)
                                    .cornerRadius(8)
                                    .frame(width: 150, height: 200)
                                }
                                .buttonStyle(PlainButtonStyle())
                            
                            }
                            
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray3))
                        
                    }
                    
                    // Created a Load More button so that it doesn't display all the items at once.
                    // However i still loads them in the background making my app Lag (Find more info in DataImporter)
                    if filteredItems.count > displayCount {
                        Button(action: { displayCount += 10 }) {
                            Text("Load More")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                    }
                }
            }
            .navigationTitle("iFragranceWorld")
            .background(Color(.systemGray3))
            .navigationDestination(isPresented: Binding(
                get: { selectedFragrance != nil },
                set: { if !$0 { selectedFragrance = nil } }
            )) {
                if let fragrance = selectedFragrance {
                    FragranceView(fragrance: fragrance)
                }
            }
        }
    }
}




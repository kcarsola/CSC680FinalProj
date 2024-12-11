import SwiftUI

struct FilterView: View {
    @Binding var selectedNotes: Set<String>
    @Binding var isNotesDropDownOpen: Bool
    @Binding var visibleNotesCount: Int
    @Binding var selectedGenders: Set<String>
    @Binding var isGenderDropDownOpen: Bool
    let allNotes: [String]
    @State private var noteSearchText = ""

    var filteredNotes: [String] {
        allNotes.filter { noteSearchText.isEmpty || $0.lowercased().contains(noteSearchText.lowercased()) }
    }

    var body: some View {
        VStack {
            // Gender Filtering Stacks
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        isGenderDropDownOpen.toggle()
                    }
                }) {
                    HStack {
                        Text("Filter by Gender")
                            .foregroundColor(.brown)
                        Spacer()
                        Image(systemName: isGenderDropDownOpen ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                // Checks if true then continue
                if isGenderDropDownOpen {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Unisex", isOn: Binding(
                            get: { selectedGenders.contains("unisex") },
                            set: { isSelected in
                                if isSelected {
                                    selectedGenders.insert("unisex")
                                } else {
                                    selectedGenders.remove("unisex")
                                }
                            }
                        ))
                        Toggle("Men", isOn: Binding(
                            get: { selectedGenders.contains("men") },
                            set: { isSelected in
                                if isSelected {
                                    selectedGenders.insert("men")
                                } else {
                                    selectedGenders.remove("men")
                                }
                            }
                        ))
                        Toggle("Women", isOn: Binding(
                            get: { selectedGenders.contains("women") },
                            set: { isSelected in
                                if isSelected {
                                    selectedGenders.insert("women")
                                } else {
                                    selectedGenders.remove("women")
                                }
                            }
                        ))
                    }
                    .padding(.horizontal)
                }
            }

            // Notes Filter Stacks
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        isNotesDropDownOpen.toggle()
                    }
                }) {
                    HStack {
                        Text("Filter by Notes")
                            .foregroundColor(.brown)
                        Spacer()
                        Image(systemName: isNotesDropDownOpen ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                if isNotesDropDownOpen {
                    VStack(alignment: .leading, spacing: 8) {
                        // Search Bar for Notes
                        TextField("Search notes...", text: $noteSearchText)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)

                        ScrollView {
                            ForEach(filteredNotes.prefix(visibleNotesCount), id: \.self) { note in
                                Toggle(note, isOn: Binding(
                                    get: { selectedNotes.contains(note) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedNotes.insert(note)
                                        } else {
                                            selectedNotes.remove(note)
                                        }
                                    }
                                ))
                            }

                            if visibleNotesCount < filteredNotes.count {
                                Button(action: {
                                    visibleNotesCount += 5
                                }) {
                                    Text("Show More")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(.blue)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

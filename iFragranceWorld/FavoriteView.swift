import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationStack {
            // Displays "No Favorites yet" if favorites is empty
            if favoritesManager.favorites.isEmpty {
                Text("No favorites yet :(")
                    .font(.title2)
                    .foregroundColor(.brown)
                    .padding()
            } else {
                List {
                    
                    ForEach(favoritesManager.favorites, id: \.self) { fragrance in
                        NavigationLink(destination: FragranceView(fragrance: fragrance)) {
                            VStack(alignment: .leading) {
                                Text(fragrance.name ?? "Unknown Name")
                                    .font(.headline)
                                Text(fragrance.brand ?? "Unknown Brand")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
}

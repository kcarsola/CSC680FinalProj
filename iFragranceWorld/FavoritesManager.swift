import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favorites: [Item] = []

    func toggleFavorite(for fragrance: Item) {
        if let index = favorites.firstIndex(of: fragrance) {
            // Remove from favorites if already there
            favorites.remove(at: index)
        } else {
            // Add to favorites
            favorites.append(fragrance)
        }
    }

    func isFavorite(_ fragrance: Item) -> Bool {
        favorites.contains(fragrance)
    }
}

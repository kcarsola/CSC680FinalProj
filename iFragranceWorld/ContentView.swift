import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some View {
        // Creates the two bottom tabs, Search and Favorites.
        TabView {
            SearchView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FavoriteView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}



#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

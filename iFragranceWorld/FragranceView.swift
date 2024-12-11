import SwiftUI

struct FragranceView: View {
    let fragrance: Item // The selected fragrance
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Image
            AsyncImage(url: URL(string: fragrance.url ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 250)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(12)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }

            // Fragrance Details
            Group {
                Text("Name: \(fragrance.name ?? "Unknown Name")")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Brand: \(fragrance.brand ?? "Unknown Brand")")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Gender: \(fragrance.gender ?? "Unknown")")
                    .font(.body)
                    .foregroundColor(.brown)
                Text("Top Notes: \(fragrance.top_notes ?? "N/A")")
                    .font(.body)
                    .foregroundColor(.brown)
                Text("Middle Notes: \(fragrance.middle_notes ?? "N/A")")
                    .font(.body)
                    .foregroundColor(.brown)
                Text("Base Notes: \(fragrance.base_notes ?? "N/A")")
                    .font(.body)
                    .foregroundColor(.brown)
                Text("Year: \(fragrance.year ?? "Unknown")")
                    .font(.body)
                    .foregroundColor(.brown)
            }

            // Heart Button
            Button(action: {
                favoritesManager.toggleFavorite(for: fragrance)
            }) {
                HStack {
                    Image(systemName: favoritesManager.isFavorite(fragrance) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                    Text(favoritesManager.isFavorite(fragrance) ? "Favorited" : "Favorite")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Spacer() // Push content to the top
        }
        .padding()
        .navigationTitle(fragrance.name ?? "Fragrance Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

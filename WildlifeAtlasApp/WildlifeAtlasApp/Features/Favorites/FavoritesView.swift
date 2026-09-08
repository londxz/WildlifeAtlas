//
//  FavoritesView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct FavoritesView: View {
    let favoritesStore: FavoritesStore
    let imagePipeline: ImagePipeline
    let onBrowseObservations: () -> Void

    @State private var isRemoveFavoriteErrorPresented = false

    var body: some View {
        Group {
            switch favoritesStore.state {
            case .content(let observations):
                favoritesList(observations)
            case .empty:
                emptyState
            case .failure(let message):
                failureState(message: message)
            }
        }
        .navigationTitle("Favorites")
        .alert(
            "Unable to remove favorite",
            isPresented: $isRemoveFavoriteErrorPresented
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Try again.")
        }
    }

    private func favoritesList(
        _ observations: [ObservationDetails]
    ) -> some View {
        List {
            ForEach(observations) { observation in
                NavigationLink(value: observation) {
                    ObservationRowView(
                        observation: observation.summary,
                        imagePipeline: imagePipeline
                    )
                }
            }
            .onDelete { offsets in
                removeFavorites(at: offsets, from: observations)
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No favorites", systemImage: "heart")
        } description: {
            Text("Use the heart button to save observations.")
        } actions: {
            Button("Browse observations", action: onBrowseObservations)
                .buttonStyle(.borderedProminent)
        }
    }

    private func failureState(message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to load", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: favoritesStore.retry)
                .buttonStyle(.borderedProminent)
        }
    }

    private func removeFavorites(
        at offsets: IndexSet,
        from observations: [ObservationDetails]
    ) {
        do {
            for index in offsets {
                try favoritesStore.removeFavorite(id: observations[index].id)
            }
        } catch {
            isRemoveFavoriteErrorPresented = true
        }
    }
}

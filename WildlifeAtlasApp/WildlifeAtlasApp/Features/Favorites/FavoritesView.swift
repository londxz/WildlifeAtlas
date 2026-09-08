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
        .navigationTitle("Избранное")
        .alert(
            "Не удалось удалить из избранного",
            isPresented: $isRemoveFavoriteErrorPresented
        ) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Попробуйте ещё раз.")
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
            Label("Нет избранных", systemImage: "heart")
        } description: {
            Text("Добавляйте наблюдения с помощью кнопки сердца.")
        } actions: {
            Button("Смотреть наблюдения", action: onBrowseObservations)
                .buttonStyle(.borderedProminent)
        }
    }

    private func failureState(message: String) -> some View {
        ContentUnavailableView {
            Label("Не удалось загрузить", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Повторить", action: favoritesStore.retry)
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

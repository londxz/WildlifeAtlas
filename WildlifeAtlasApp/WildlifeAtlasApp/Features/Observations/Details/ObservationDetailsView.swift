//
//  ObservationDetailsView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationDetailsView: View {
    @State private var viewModel: ObservationDetailsViewModel
    @State private var isFavoriteErrorPresented = false

    private let favoritesStore: FavoritesStore

    init(
        viewModel: ObservationDetailsViewModel,
        favoritesStore: FavoritesStore
    ) {
        _viewModel = State(initialValue: viewModel)
        self.favoritesStore = favoritesStore
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ObservationDetailsLoadingView()
            case .content(let details):
                ObservationDetailsContentView(details: details)
            case .empty:
                ContentUnavailableView(
                    "Наблюдение не найдено",
                    systemImage: "binoculars"
                )
            case .failure(let message):
                ContentUnavailableView {
                    Label("Не удалось загрузить", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Повторить") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Наблюдение")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            favoriteToolbarItem
        }
        .alert(
            "Не удалось изменить избранное",
            isPresented: $isFavoriteErrorPresented
        ) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Попробуйте ещё раз.")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    @ToolbarContentBuilder
    private var favoriteToolbarItem: some ToolbarContent {
        if case .content(let details) = viewModel.state {
            let isFavorite = favoritesStore.isFavorite(id: details.id)

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite(details)
                } label: {
                    Label(
                        isFavorite
                            ? "Удалить из избранного"
                            : "Добавить в избранное",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                    .labelStyle(.iconOnly)
                }
                .tint(isFavorite ? .red : .primary)
            }
        }
    }

    private func toggleFavorite(_ details: ObservationDetails) {
        do {
            try favoritesStore.toggleFavorite(details)
        } catch {
            isFavoriteErrorPresented = true
        }
    }
}

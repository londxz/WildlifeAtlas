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
    private let imagePipeline: ImagePipeline

    init(
        viewModel: ObservationDetailsViewModel,
        favoritesStore: FavoritesStore,
        imagePipeline: ImagePipeline
    ) {
        _viewModel = State(initialValue: viewModel)
        self.favoritesStore = favoritesStore
        self.imagePipeline = imagePipeline
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ObservationDetailsLoadingView()
            case .content(let details):
                ObservationDetailsContentView(
                    details: details,
                    imagePipeline: imagePipeline
                )
            case .empty:
                ContentUnavailableView(
                    "Observation not found",
                    systemImage: "binoculars"
                )
            case .failure(let message):
                ContentUnavailableView {
                    Label("Unable to load", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Observation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            detailsToolbarItems
        }
        .alert(
            "Unable to update favorites",
            isPresented: $isFavoriteErrorPresented
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Try again.")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    @ToolbarContentBuilder
    private var detailsToolbarItems: some ToolbarContent {
        if case .content(let details) = viewModel.state {
            let isFavorite = favoritesStore.isFavorite(id: details.id)

            ToolbarItemGroup(placement: .topBarTrailing) {
                if let publicURL = details.publicURL {
                    ShareLink(item: publicURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .labelStyle(.iconOnly)
                    }
                }

                Button {
                    toggleFavorite(details)
                } label: {
                    Label(
                        isFavorite
                            ? "Remove from favorites"
                            : "Add to favorites",
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

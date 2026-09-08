//
//  ObservationDetailsView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationDetailsView: View {
    @State private var viewModel: ObservationDetailsViewModel

    init(viewModel: ObservationDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
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
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

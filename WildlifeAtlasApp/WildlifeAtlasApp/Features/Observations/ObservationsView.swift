//
//  ObservationsView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ObservationsView: View {
    let viewModel: ObservationsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Загружаем наблюдения…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .content(let observations):
                List(observations) { observation in
                    ObservationRowView(observation: observation)
                }
                .listStyle(.plain)
            case .empty:
                ContentUnavailableView(
                    "Наблюдений не найдено",
                    systemImage: "binoculars",
                    description: Text("Попробуйте обновить данные позднее.")
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
        .navigationTitle("Наблюдения")
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

private struct PreviewObservationRepository: ObservationRepository {
    func fetchObservations(page: Int, perPage: Int) async throws -> ObservationPage {
        ObservationPage(
            observations: [
                WildlifeObservation(
                    id: 1,
                    commonName: "Рыжая лисица",
                    scientificName: "Vulpes vulpes",
                    observedOn: ObservationDate(year: 2026, month: 9, day: 6),
                    qualityGrade: .research,
                    previewImageURL: nil
                )
            ],
            page: page,
            perPage: perPage,
            totalResults: 1
        )
    }
}

#Preview {
    NavigationStack {
        ObservationsView(
            viewModel: ObservationsViewModel(
                observationRepository: PreviewObservationRepository()
            )
        )
    }
}

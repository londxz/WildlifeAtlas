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
            case .content(let contentState):
                List {
                    ForEach(contentState.observations) { observation in
                        ObservationRowView(observation: observation)
                            .task {
                                await viewModel.loadNextPageIfNeeded(
                                    currentObservation: observation
                                )
                            }
                    }

                    paginationFooter(
                        for: contentState.paginationState,
                        loadingPage: contentState.nextPage
                    )
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
                            await viewModel.retryInitialLoad()
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

    @ViewBuilder
    private func paginationFooter(
        for paginationState: ObservationsViewModel.PaginationState,
        loadingPage: Int?
    ) -> some View {
        switch paginationState {
        case .idle:
            EmptyView()
        case .loading:
            HStack(spacing: 8) {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 20, height: 20)
                    .id(loadingPage)
                Text("Загружаем ещё…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .listRowSeparator(.hidden)
        case .failure(let message):
            VStack(spacing: 8) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Повторить") {
                    Task {
                        await viewModel.retryNextPage()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
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

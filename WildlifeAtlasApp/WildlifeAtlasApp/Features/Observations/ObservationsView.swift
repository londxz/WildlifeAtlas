//
//  ObservationsView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ObservationsView: View {
    let viewModel: ObservationsViewModel

    @ScaledMetric(relativeTo: .body)
    private var minimumGridItemWidth: CGFloat = 160

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Загружаем наблюдения…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .content(let contentState):
                observationsContent(for: contentState)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Режим отображения", selection: layoutModeSelection) {
                    Label("Список", systemImage: "list.bullet")
                        .labelStyle(.iconOnly)
                        .tag(ObservationLayoutMode.list)

                    Label("Плитка", systemImage: "square.grid.2x2")
                        .labelStyle(.iconOnly)
                        .tag(ObservationLayoutMode.grid)
                }
                .pickerStyle(.segmented)
                .frame(width: 88)
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private func observationsContent(
        for contentState: ObservationsViewModel.ContentState
    ) -> some View {
        switch viewModel.layoutMode {
        case .list:
            observationsList(for: contentState)
        case .grid:
            observationsGrid(for: contentState)
        }
    }

    private func observationsList(
        for contentState: ObservationsViewModel.ContentState
    ) -> some View {
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
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private func observationsGrid(
        for contentState: ObservationsViewModel.ContentState
    ) -> some View {
        ScrollView {
            LazyVGrid(
                columns: gridColumns,
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(contentState.observations) { observation in
                    ObservationGridItemView(observation: observation)
                        .task {
                            await viewModel.loadNextPageIfNeeded(
                                currentObservation: observation
                            )
                        }
                }
            }

            paginationFooter(
                for: contentState.paginationState,
                loadingPage: contentState.nextPage
            )
        }
        .contentMargins(.horizontal, 12, for: .scrollContent)
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
            .padding(.vertical, 12)
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
            .padding(.vertical, 12)
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: minimumGridItemWidth),
                spacing: 12,
                alignment: .top
            )
        ]
    }

    private var layoutModeSelection: Binding<ObservationLayoutMode> {
        Binding(
            get: { viewModel.layoutMode },
            set: { viewModel.selectLayoutMode($0) }
        )
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
                observationRepository: PreviewObservationRepository(),
                appSettings: AppSettings(userDefaults: .standard)
            )
        )
    }
}

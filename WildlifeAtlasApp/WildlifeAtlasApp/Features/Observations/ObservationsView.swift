//
//  ObservationsView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation
import SwiftUI

struct ObservationsView: View {
    let viewModel: ObservationsViewModel
    let taxonSearchViewModel: TaxonSearchViewModel
    let imagePipeline: ImagePipeline

    @ScaledMetric(relativeTo: .body)
    private var minimumGridItemWidth: CGFloat = 160
    @FocusState private var isTaxonSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            taxonSearchView
                .zIndex(1)
                .layoutPriority(taxonSearchViewModel.hasQuery ? 1 : 0)
            filtersView
            Divider()

            ZStack {
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        ObservationsLoadingView(
                            layoutMode: viewModel.layoutMode,
                            gridColumns: gridColumns
                        )
                    case .content(let contentState):
                        observationsContent(for: contentState)
                    case .empty:
                        ContentUnavailableView(
                            "Наблюдений не найдено",
                            systemImage: "binoculars",
                            description: Text("Попробуйте изменить фильтры.")
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

                if taxonSearchViewModel.hasQuery {
                    Color.black.opacity(0.45)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissTaxonSearch()
                        }
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

    private var taxonSearchView: some View {
        TaxonSearchView(
            viewModel: taxonSearchViewModel,
            imagePipeline: imagePipeline,
            searchFieldFocus: $isTaxonSearchFocused,
            onSelectTaxon: { taxon in
                selectTaxon(taxon)
            }
        )
    }

    private var filtersView: some View {
        ObservationFiltersView(
            filters: viewModel.filters,
            onSelectTaxon: { taxon in
                selectTaxon(taxon)
            },
            onSelectQuality: { quality in
                Task {
                    await viewModel.selectQualityFilter(quality)
                }
            },
            onSelectDateOrder: { dateOrder in
                Task {
                    await viewModel.selectDateOrder(dateOrder)
                }
            }
        )
    }

    private func dismissTaxonSearch() {
        isTaxonSearchFocused = false
        taxonSearchViewModel.clearQuery()
    }

    private func selectTaxon(_ taxon: TaxonSummary?) {
        Task {
            await viewModel.selectTaxon(taxon)
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
                NavigationLink(value: observation.id) {
                    ObservationRowView(
                        observation: observation,
                        imagePipeline: imagePipeline
                    )
                }
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
                    NavigationLink(value: observation.id) {
                        ObservationGridItemView(
                            observation: observation,
                            imagePipeline: imagePipeline
                        )
                    }
                        .buttonStyle(.plain)
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
    private let observationID = UUID()

    func fetchObservations(
        page: Int,
        perPage: Int,
        filters: ObservationFilters
    ) async throws -> ObservationPage {
        ObservationPage(
            observations: [
                ObservationSummary(
                    id: observationID,
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

    func fetchObservationDetails(id: UUID) async throws -> ObservationDetails? {
        nil
    }
}

private struct PreviewTaxonRepository: TaxonRepository {
    func searchTaxa(
        query: String,
        limit: Int
    ) async throws -> [TaxonSummary] {
        []
    }
}

#Preview {
    NavigationStack {
        ObservationsView(
            viewModel: ObservationsViewModel(
                observationRepository: PreviewObservationRepository(),
                appSettings: AppSettings(userDefaults: .standard)
            ),
            taxonSearchViewModel: TaxonSearchViewModel(
                taxonRepository: PreviewTaxonRepository()
            ),
            imagePipeline: ImagePipeline()
        )
    }
}

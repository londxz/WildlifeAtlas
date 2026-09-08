//
//  TaxonSearchView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import SwiftUI

struct TaxonSearchView: View {
    private static let searchFieldHeight: CGFloat = 44
    private static let searchResultsMaxHeight: CGFloat = 320
    private static let searchResultRowHeight: CGFloat = 69

    @Bindable var viewModel: TaxonSearchViewModel
    let imagePipeline: ImagePipeline
    let searchFieldFocus: FocusState<Bool>.Binding
    let onSelectTaxon: (TaxonSummary) -> Void

    var body: some View {
        VStack(spacing: 8) {
            searchField

            if isSuggestionsPresented {
                suggestions
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Поиск таксона", text: $viewModel.query)
                .focused(searchFieldFocus)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    submitSearch()
                }

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.clearQuery()
                    searchFieldFocus.wrappedValue = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: Self.searchFieldHeight)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var suggestions: some View {
        VStack(spacing: 0) {
            Text(suggestionsTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)

            Divider()

            suggestionsContent
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    @ViewBuilder
    private var suggestionsContent: some View {
        if viewModel.hasQuery {
            switch viewModel.state {
            case .idle:
                searchMessage("Введите минимум два символа")
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Ищем таксоны…")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            case .content(let taxa):
                taxaList(taxa)
            case .empty:
                searchMessage("Подходящих таксонов не найдено")
            case .failure(let message):
                VStack(spacing: 12) {
                    Text(message)
                        .foregroundStyle(.secondary)

                    Button("Повторить") {
                        viewModel.retry()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        } else {
            taxaList(viewModel.recentTaxa)
        }
    }

    private func taxaList(_ taxa: [TaxonSummary]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(taxa) { taxon in
                    Button {
                        selectTaxon(taxon)
                    } label: {
                        TaxonSearchResultRowView(
                            taxon: taxon,
                            imagePipeline: imagePipeline
                        )
                    }
                    .buttonStyle(.plain)

                    if taxon.id != taxa.last?.id {
                        Divider()
                            .padding(.leading, 76)
                    }
                }
            }
        }
        .frame(
            maxHeight: min(
                CGFloat(taxa.count) * Self.searchResultRowHeight,
                Self.searchResultsMaxHeight
            )
        )
    }

    private func searchMessage(_ message: String) -> some View {
        Text(message)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }

    private func selectTaxon(_ taxon: TaxonSummary) {
        viewModel.clearQuery()
        searchFieldFocus.wrappedValue = false
        onSelectTaxon(taxon)
    }

    private func submitSearch() {
        guard case .content(let taxa) = viewModel.state else { return }

        if taxa.count == 1, let taxon = taxa.first {
            selectTaxon(taxon)
        } else if !taxa.isEmpty {
            searchFieldFocus.wrappedValue = false
        }
    }

    private var isSuggestionsPresented: Bool {
        viewModel.hasQuery
            || searchFieldFocus.wrappedValue && !viewModel.recentTaxa.isEmpty
    }

    private var suggestionsTitle: String {
        viewModel.hasQuery
            ? "Выберите таксон для фильтрации наблюдений"
            : "Недавно выбранные таксоны"
    }
}

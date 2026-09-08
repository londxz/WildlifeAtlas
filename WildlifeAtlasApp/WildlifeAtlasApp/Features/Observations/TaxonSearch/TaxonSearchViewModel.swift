//
//  TaxonSearchViewModel.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TaxonSearchViewModel {
    private static let minimumQueryLength = 2
    private static let searchDelay = Duration.milliseconds(300)
    private static let searchResultsLimit = 20

    enum State {
        case idle
        case loading
        case content([TaxonSummary])
        case empty
        case failure(String)
    }

    var query = "" {
        didSet {
            guard query != oldValue else { return }
            scheduleSearch()
        }
    }

    private(set) var state: State = .idle

    var hasQuery: Bool {
        !normalizedQuery.isEmpty
    }

    private let taxonRepository: any TaxonRepository
    private var searchTask: Task<Void, Never>?

    init(taxonRepository: any TaxonRepository) {
        self.taxonRepository = taxonRepository
    }

    func clearQuery() {
        query = ""
    }

    func retry() {
        scheduleSearch(waitForDelay: false)
    }

    private func scheduleSearch(waitForDelay: Bool = true) {
        searchTask?.cancel()

        let searchQuery = normalizedQuery

        guard searchQuery.count >= Self.minimumQueryLength else {
            state = .idle
            return
        }

        state = .loading
        let taxonRepository = taxonRepository

        searchTask = Task { [weak self] in
            do {
                if waitForDelay {
                    try await Task.sleep(for: Self.searchDelay)
                }

                let taxa = try await taxonRepository.searchTaxa(
                    query: searchQuery,
                    limit: Self.searchResultsLimit
                )
                try Task.checkCancellation()

                guard
                    let self,
                    searchQuery == self.normalizedQuery
                else {
                    return
                }

                state = taxa.isEmpty ? .empty : .content(taxa)
            } catch {
                guard !Task.isCancelled else { return }

                guard
                    let self,
                    searchQuery == self.normalizedQuery
                else {
                    return
                }

                state = .failure(Self.errorMessage(for: error))
            }
        }
    }

    private var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func errorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Нет подключения к интернету."
            case .timedOut:
                return "Сервер не ответил вовремя."
            default:
                return "Не удалось выполнить поиск."
            }
        }

        return "Не удалось выполнить поиск."
    }
}

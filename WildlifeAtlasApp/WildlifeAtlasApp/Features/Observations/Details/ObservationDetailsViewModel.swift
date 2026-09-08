//
//  ObservationDetailsViewModel.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ObservationDetailsViewModel {
    enum State {
        case idle
        case loading
        case content(ObservationDetails)
        case empty
        case failure(String)
    }

    private(set) var state: State = .idle

    private let observationID: UUID
    private let observationRepository: any ObservationRepository

    init(
        observationID: UUID,
        observationRepository: any ObservationRepository,
        initialDetails: ObservationDetails? = nil
    ) {
        self.observationID = observationID
        self.observationRepository = observationRepository

        if let initialDetails {
            state = .content(initialDetails)
        }
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func retry() async {
        guard case .failure = state else { return }
        await load()
    }

    private func load() async {
        if case .loading = state {
            return
        }

        state = .loading

        do {
            let details = try await observationRepository.fetchObservationDetails(
                id: observationID
            )
            try Task.checkCancellation()

            if let details {
                state = .content(details)
            } else {
                state = .empty
            }
        } catch {
            guard !Task.isCancelled else {
                state = .idle
                return
            }

            state = .failure(Self.errorMessage(for: error))
        }
    }

    private static func errorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Нет подключения к интернету. Проверьте сеть."
            case .timedOut:
                return "Сервер не ответил вовремя."
            default:
                return "Не удалось связаться с сервером."
            }
        }

        return "Не удалось загрузить подробности."
    }
}

//
//  ObservationsViewModel.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ObservationsViewModel {
    private static let initialPage = 1
    private static let pageSize = 20

    enum State {
        case idle
        case loading
        case content([WildlifeObservation])
        case empty
        case failure(String)
    }

    private(set) var state: State = .idle

    private let observationRepository: any ObservationRepository

    init(observationRepository: any ObservationRepository) {
        self.observationRepository = observationRepository
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func retry() async {
        await load()
    }

    private func load() async {
        if case .loading = state {
            return
        }

        state = .loading

        do {
            let observationPage = try await observationRepository.fetchObservations(
                page: Self.initialPage,
                perPage: Self.pageSize
            )
            try Task.checkCancellation()

            state = observationPage.observations.isEmpty
                ? .empty
                : .content(observationPage.observations)
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
                return "Нет подключения к интернету. Проверьте сеть и попробуйте ещё раз."
            case .timedOut:
                return "Сервер не ответил вовремя. Попробуйте ещё раз."
            default:
                return "Не удалось связаться с сервером. Попробуйте ещё раз."
            }
        }

        if let apiError = error as? APIClientError {
            switch apiError {
            case .invalidRequestURL:
                return "Не удалось сформировать запрос. Попробуйте ещё раз."
            case .nonHTTPResponse:
                return "Сервер вернул некорректный ответ. Попробуйте ещё раз."
            case .unsuccessfulStatusCode:
                return "Не удалось загрузить данные с сервера. Попробуйте ещё раз."
            }
        }

        return "Не удалось загрузить наблюдения. Попробуйте ещё раз."
    }
}

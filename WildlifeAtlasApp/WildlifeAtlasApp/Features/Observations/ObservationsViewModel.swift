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
        case content(ContentState)
        case empty
        case failure(String)
    }

    struct ContentState {
        let observations: [WildlifeObservation]
        let nextPage: Int?
        let paginationState: PaginationState
    }

    enum PaginationState {
        case idle
        case loading
        case failure(String)
    }

    private(set) var state: State = .idle

    private let observationRepository: any ObservationRepository

    init(observationRepository: any ObservationRepository) {
        self.observationRepository = observationRepository
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await loadInitialPage()
    }

    func retryInitialLoad() async {
        guard case .failure = state else { return }
        await loadInitialPage()
    }

    func loadNextPageIfNeeded(currentObservation: WildlifeObservation) async {
        guard
            case .content(let contentState) = state,
            contentState.observations.last?.id == currentObservation.id,
            contentState.nextPage != nil,
            case .idle = contentState.paginationState
        else {
            return
        }

        await loadNextPage()
    }

    func retryNextPage() async {
        guard
            case .content(let contentState) = state,
            case .failure = contentState.paginationState
        else {
            return
        }

        await loadNextPage()
    }

    private func loadInitialPage() async {
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

            guard !observationPage.observations.isEmpty else {
                state = .empty
                return
            }

            state = .content(
                ContentState(
                    observations: observationPage.observations,
                    nextPage: Self.nextPage(after: observationPage),
                    paginationState: .idle
                )
            )
        } catch {
            guard !Task.isCancelled else {
                state = .idle
                return
            }

            state = .failure(Self.errorMessage(for: error))
        }
    }

    private func loadNextPage() async {
        guard
            case .content(let currentContentState) = state,
            let nextPage = currentContentState.nextPage
        else {
            return
        }

        if case .loading = currentContentState.paginationState {
            return
        }

        state = .content(
            ContentState(
                observations: currentContentState.observations,
                nextPage: nextPage,
                paginationState: .loading
            )
        )

        do {
            let observationPage = try await observationRepository.fetchObservations(
                page: nextPage,
                perPage: Self.pageSize
            )
            try Task.checkCancellation()

            state = .content(
                ContentState(
                    observations: Self.appendingUniqueObservations(
                        observationPage.observations,
                        to: currentContentState.observations
                    ),
                    nextPage: Self.nextPage(after: observationPage),
                    paginationState: .idle
                )
            )
        } catch {
            guard !Task.isCancelled else {
                state = .content(
                    ContentState(
                        observations: currentContentState.observations,
                        nextPage: nextPage,
                        paginationState: .idle
                    )
                )
                return
            }

            state = .content(
                ContentState(
                    observations: currentContentState.observations,
                    nextPage: nextPage,
                    paginationState: .failure(Self.errorMessage(for: error))
                )
            )
        }
    }

    private static func nextPage(after observationPage: ObservationPage) -> Int? {
        guard
            !observationPage.observations.isEmpty,
            observationPage.hasNextPage
        else {
            return nil
        }

        return observationPage.page + 1
    }

    private static func appendingUniqueObservations(
        _ newObservations: [WildlifeObservation],
        to currentObservations: [WildlifeObservation]
    ) -> [WildlifeObservation] {
        let currentObservationIDs = Set(currentObservations.map(\.id))
        let uniqueNewObservations = newObservations.filter {
            !currentObservationIDs.contains($0.id)
        }

        return currentObservations + uniqueNewObservations
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

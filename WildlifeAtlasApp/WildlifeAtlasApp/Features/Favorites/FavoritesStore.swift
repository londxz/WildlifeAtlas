//
//  FavoritesStore.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class FavoritesStore {
    enum State {
        case content([ObservationDetails])
        case empty
        case failure(String)
    }

    private(set) var state: State = .empty

    private let favoritesRepository: any FavoritesRepository

    init(favoritesRepository: any FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
        loadFavorites()
    }

    func isFavorite(id: UUID) -> Bool {
        favorites.contains { $0.id == id }
    }

    func toggleFavorite(_ details: ObservationDetails) throws {
        if isFavorite(id: details.id) {
            try favoritesRepository.removeFavorite(id: details.id)
        } else {
            try favoritesRepository.saveFavorite(details)
        }

        try refreshFavorites()
    }

    func removeFavorite(id: UUID) throws {
        try favoritesRepository.removeFavorite(id: id)
        try refreshFavorites()
    }

    func retry() {
        loadFavorites()
    }

    private var favorites: [ObservationDetails] {
        guard case .content(let observations) = state else { return [] }
        return observations
    }

    private func loadFavorites() {
        do {
            try refreshFavorites()
        } catch {
            state = .failure("Unable to load favorites.")
        }
    }

    private func refreshFavorites() throws {
        let favorites = try favoritesRepository.fetchFavorites()
        state = favorites.isEmpty ? .empty : .content(favorites)
    }
}

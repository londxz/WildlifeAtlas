//
//  FavoritesRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation

@MainActor
protocol FavoritesRepository {
    func fetchFavorites() throws -> [ObservationDetails]
    func saveFavorite(_ observation: ObservationDetails) throws
    func removeFavorite(id: UUID) throws
}

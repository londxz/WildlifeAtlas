//
//  SwiftDataFavoritesRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataFavoritesRepository: FavoritesRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init() throws {
        let modelContainer = try ModelContainer(
            for: FavoriteObservationRecord.self
        )

        self.modelContainer = modelContainer
        modelContext = ModelContext(modelContainer)
    }

    func fetchFavorites() throws -> [ObservationDetails] {
        let descriptor = FetchDescriptor<FavoriteObservationRecord>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map {
            $0.toObservationDetails()
        }
    }

    func saveFavorite(_ observation: ObservationDetails) throws {
        do {
            if let existingRecord = try record(id: observation.id) {
                existingRecord.update(with: observation)
            } else {
                modelContext.insert(
                    FavoriteObservationRecord(observation: observation)
                )
            }

            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    func removeFavorite(id: UUID) throws {
        do {
            guard let record = try record(id: id) else { return }

            modelContext.delete(record)
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func record(id: UUID) throws -> FavoriteObservationRecord? {
        let favoriteID = id
        var descriptor = FetchDescriptor<FavoriteObservationRecord>(
            predicate: #Predicate { record in
                record.id == favoriteID
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }
}

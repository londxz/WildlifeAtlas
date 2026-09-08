//
//  ObservationRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

protocol ObservationRepository: Sendable {
    func fetchObservations(
        page: Int,
        perPage: Int,
        filters: ObservationFilters
    ) async throws -> ObservationPage

    func fetchObservationDetails(id: UUID) async throws -> ObservationDetails?
}

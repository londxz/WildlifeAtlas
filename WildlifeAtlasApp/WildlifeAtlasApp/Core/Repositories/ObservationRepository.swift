//
//  ObservationRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

protocol ObservationRepository: Sendable {
    func fetchObservations(page: Int, perPage: Int) async throws -> ObservationPage
}

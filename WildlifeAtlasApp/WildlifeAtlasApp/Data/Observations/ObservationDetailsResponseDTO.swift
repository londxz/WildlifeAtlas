//
//  ObservationDetailsResponseDTO.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

struct ObservationDetailsResponseDTO: Decodable, Sendable {
    private let results: [ObservationDTO]

    func toDomain() -> ObservationDetails? {
        results.first?.toObservationDetails()
    }
}

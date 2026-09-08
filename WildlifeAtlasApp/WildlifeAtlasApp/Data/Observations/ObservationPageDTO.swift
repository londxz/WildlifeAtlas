//
//  ObservationPageDTO.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct ObservationPageDTO: Decodable, Sendable {
    private let totalResults: Int
    private let page: Int
    private let perPage: Int
    private let results: [ObservationDTO]

    private enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
        case results
    }

    func toDomain() -> ObservationPage {
        ObservationPage(
            observations: results.map { $0.toObservationSummary() },
            page: page,
            perPage: perPage,
            totalResults: totalResults
        )
    }
}

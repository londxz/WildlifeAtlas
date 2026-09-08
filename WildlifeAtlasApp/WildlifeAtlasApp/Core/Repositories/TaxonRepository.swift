//
//  TaxonRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

protocol TaxonRepository: Sendable {
    func searchTaxa(
        query: String,
        limit: Int
    ) async throws -> [TaxonSummary]
}

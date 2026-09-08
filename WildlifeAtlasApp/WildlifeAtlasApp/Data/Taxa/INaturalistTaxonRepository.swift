//
//  INaturalistTaxonRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation

struct INaturalistTaxonRepository: TaxonRepository {
    private static let searchResultFields = [
        "id",
        "name",
        "preferred_common_name",
        "iconic_taxon_name",
        "default_photo.square_url"
    ].joined(separator: ",")

    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func searchTaxa(
        query: String,
        limit: Int
    ) async throws -> [TaxonSummary] {
        let request = APIRequest(
            path: "taxa",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "per_page", value: String(limit)),
                URLQueryItem(name: "locale", value: "en"),
                URLQueryItem(name: "fields", value: Self.searchResultFields)
            ]
        )

        let responseDTO = try await apiClient.get(
            request,
            as: TaxonSearchResponseDTO.self
        )
        return responseDTO.toDomain()
    }
}

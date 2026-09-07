//
//  INaturalistObservationRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct INaturalistObservationRepository: ObservationRepository {
    private static let observationSummaryFields = [
        "id",
        "observed_on",
        "quality_grade",
        "taxon.name",
        "taxon.preferred_common_name",
        "photos.url"
    ].joined(separator: ",")

    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchObservations(page: Int, perPage: Int) async throws -> ObservationPage {
        let request = APIRequest(
            path: "observations",
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "captive", value: "false"),
                URLQueryItem(name: "order", value: "desc"),
                URLQueryItem(name: "order_by", value: "observed_on"),
                URLQueryItem(name: "fields", value: Self.observationSummaryFields)
            ]
        )

        let responseDTO = try await apiClient.get(request, as: ObservationPageDTO.self)
        return responseDTO.toDomain()
    }
}

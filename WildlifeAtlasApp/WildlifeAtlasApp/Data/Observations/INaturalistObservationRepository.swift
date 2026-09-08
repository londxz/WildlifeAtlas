//
//  INaturalistObservationRepository.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct INaturalistObservationRepository: ObservationRepository {
    private static let observationSummaryFields = [
        "uuid",
        "observed_on",
        "quality_grade",
        "taxon.name",
        "taxon.preferred_common_name",
        "photos.url",
        "place_guess",
        "geoprivacy",
        "taxon_geoprivacy",
        "obscured"
    ].joined(separator: ",")

    private static let observationDetailsFields = [
        "uuid",
        "observed_on",
        "time_observed_at",
        "quality_grade",
        "taxon.id",
        "taxon.name",
        "taxon.preferred_common_name",
        "taxon.rank",
        "taxon.iconic_taxon_name",
        "taxon.wikipedia_url",
        "photos.url",
        "photos.license_code",
        "photos.attribution",
        "user.login",
        "user.name",
        "user.icon_url",
        "place_guess",
        "geoprivacy",
        "taxon_geoprivacy",
        "obscured",
        "uri"
    ].joined(separator: ",")

    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchObservations(
        page: Int,
        perPage: Int,
        filters: ObservationFilters
    ) async throws -> ObservationPage {
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "captive", value: "false"),
            URLQueryItem(name: "locale", value: "en"),
            URLQueryItem(name: "order_by", value: "observed_on"),
            URLQueryItem(name: "fields", value: Self.observationSummaryFields)
        ]

        if let taxon = filters.taxon {
            queryItems.append(
                URLQueryItem(name: "taxon_id", value: String(taxon.id))
            )
        }

        if filters.quality == .research {
            queryItems.append(
                URLQueryItem(name: "quality_grade", value: "research")
            )
        }

        switch filters.dateOrder {
        case .newestFirst:
            queryItems.append(URLQueryItem(name: "order", value: "desc"))
        case .oldestFirst:
            queryItems.append(URLQueryItem(name: "order", value: "asc"))
        }

        let request = APIRequest(
            path: "observations",
            queryItems: queryItems
        )

        let responseDTO = try await apiClient.get(request, as: ObservationPageDTO.self)
        return responseDTO.toDomain()
    }

    func fetchObservationDetails(id: UUID) async throws -> ObservationDetails? {
        let request = APIRequest(
            path: "observations/\(id.uuidString.lowercased())",
            queryItems: [
                URLQueryItem(name: "captive", value: "false"),
                URLQueryItem(name: "locale", value: "en"),
                URLQueryItem(name: "fields", value: Self.observationDetailsFields)
            ]
        )

        do {
            let responseDTO = try await apiClient.get(
                request,
                as: ObservationDetailsResponseDTO.self
            )
            guard let observationDTO = responseDTO.observation else {
                return nil
            }

            let classification = await fetchTaxonClassification(
                taxonID: observationDTO.taxonID
            )
            return observationDTO.toObservationDetails(
                classification: classification
            )
        } catch APIClientError.unsuccessfulStatusCode(404) {
            return nil
        }
    }

    private func fetchTaxonClassification(
        taxonID: Int?
    ) async -> [ObservationTaxonRank] {
        guard let taxonID else { return [] }

        let request = APIRequest(
            path: "taxa/\(taxonID)",
            queryItems: [
                URLQueryItem(name: "locale", value: "en"),
                URLQueryItem(
                    name: "fields",
                    value: "name,rank,ancestors.name,ancestors.rank"
                )
            ]
        )

        guard let responseDTO = try? await apiClient.get(
            request,
            as: TaxonClassificationResponseDTO.self
        ) else {
            return []
        }

        return responseDTO.toDomain()
    }
}

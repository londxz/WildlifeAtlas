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
            observations: results.map { $0.toDomain() },
            page: page,
            perPage: perPage,
            totalResults: totalResults
        )
    }
}

private struct ObservationDTO: Decodable, Sendable {
    let id: Int
    let observedOn: String?
    let qualityGrade: String?
    let taxon: TaxonDTO?
    let photos: [PhotoDTO]?

    private enum CodingKeys: String, CodingKey {
        case id
        case observedOn = "observed_on"
        case qualityGrade = "quality_grade"
        case taxon
        case photos
    }

    func toDomain() -> WildlifeObservation {
        WildlifeObservation(
            id: id,
            commonName: taxon?.preferredCommonName,
            scientificName: taxon?.name,
            observedOn: observedOn.flatMap(Self.parseObservedOn),
            qualityGrade: qualityGrade.flatMap(Self.parseQualityGrade),
            previewImageURL: photos?
                .compactMap(\.url)
                .compactMap { URL(string: $0) }
                .first
        )
    }

    private static func parseObservedOn(_ value: String) -> ObservationDate? {
        let components = value.split(separator: "-", omittingEmptySubsequences: false)

        guard
            components.count == 3,
            let year = Int(components[0]),
            let month = Int(components[1]),
            let day = Int(components[2])
        else {
            return nil
        }

        return ObservationDate(
            year: year,
            month: month,
            day: day
        )
    }

    private static func parseQualityGrade(_ value: String) -> ObservationQualityGrade? {
        switch value {
        case "research":
            .research
        case "needs_id":
            .needsIdentification
        case "casual":
            .casual
        default:
            nil
        }
    }
}

private struct TaxonDTO: Decodable, Sendable {
    let name: String?
    let preferredCommonName: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case preferredCommonName = "preferred_common_name"
    }
}

private struct PhotoDTO: Decodable, Sendable {
    let url: String?
}

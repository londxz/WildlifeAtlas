//
//  TaxonSearchResponseDTO.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation

struct TaxonSearchResponseDTO: Decodable, Sendable {
    private let results: [TaxonSearchResultDTO]

    func toDomain() -> [TaxonSummary] {
        results.map { $0.toDomain() }
    }
}

private struct TaxonSearchResultDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let preferredCommonName: String?
    let iconicTaxonName: String?
    let defaultPhoto: TaxonPhotoDTO?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case preferredCommonName = "preferred_common_name"
        case iconicTaxonName = "iconic_taxon_name"
        case defaultPhoto = "default_photo"
    }

    func toDomain() -> TaxonSummary {
        TaxonSummary(
            id: id,
            commonName: Self.nonEmpty(preferredCommonName),
            scientificName: name,
            groupName: Self.nonEmpty(iconicTaxonName),
            previewImageURL: defaultPhoto?.previewImageURL
        )
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

private struct TaxonPhotoDTO: Decodable, Sendable {
    private let squareURL: String?

    private enum CodingKeys: String, CodingKey {
        case squareURL = "square_url"
    }

    var previewImageURL: URL? {
        guard let squareURL else { return nil }

        return URL(
            string: squareURL.replacingOccurrences(
                of: "/square.",
                with: "/small."
            )
        )
    }
}

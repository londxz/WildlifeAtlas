//
//  ObservationDetails.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct ObservationDetails: Identifiable, Hashable, Sendable {
    let id: UUID
    let taxon: ObservationTaxon?
    let observedOn: ObservationDate?
    let observedTime: ObservationTime?
    let qualityGrade: ObservationQualityGrade?
    let photos: [ObservationPhoto]
    let location: ObservationLocation?
    let author: ObservationAuthor?
    let publicURL: URL?

    var summary: ObservationSummary {
        ObservationSummary(
            id: id,
            commonName: taxon?.commonName,
            scientificName: taxon?.scientificName,
            observedOn: observedOn,
            qualityGrade: qualityGrade,
            previewImageURL: photos.first?.previewURL,
            locationName: location?.approximateName
        )
    }
}

enum ObservationLocation: Hashable, Sendable {
    case approximate(String)
    case obscured
}

private extension ObservationLocation {
    var approximateName: String? {
        guard case .approximate(let name) = self else { return nil }
        return name
    }
}

struct ObservationTaxon: Hashable, Sendable {
    let commonName: String?
    let scientificName: String?
    let rank: String?
    let iconicTaxonName: String?
    let wikipediaURL: URL?
    let classification: [ObservationTaxonRank]
}

struct ObservationTaxonRank: Hashable, Sendable {
    let rank: String
    let name: String
}

struct ObservationPhoto: Hashable, Sendable {
    let url: URL
    let previewURL: URL
    let attribution: String?
    let licenseCode: String?
}

struct ObservationAuthor: Hashable, Sendable {
    let name: String?
    let login: String?
    let avatarURL: URL?
}

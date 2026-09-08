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
    let qualityGrade: ObservationQualityGrade?
    let photos: [ObservationPhoto]
    let locationName: String?
    let author: ObservationAuthor?

    var summary: ObservationSummary {
        ObservationSummary(
            id: id,
            commonName: taxon?.commonName,
            scientificName: taxon?.scientificName,
            observedOn: observedOn,
            qualityGrade: qualityGrade,
            previewImageURL: photos.first?.previewURL
        )
    }
}

struct ObservationTaxon: Hashable, Sendable {
    let commonName: String?
    let scientificName: String?
    let rank: String?
    let iconicTaxonName: String?
    let wikipediaURL: URL?
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
}

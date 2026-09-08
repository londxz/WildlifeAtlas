//
//  ObservationDetails.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct ObservationDetails: Identifiable, Sendable {
    let id: UUID
    let taxon: ObservationTaxon?
    let observedOn: ObservationDate?
    let qualityGrade: ObservationQualityGrade?
    let photo: ObservationPhoto?
    let locationName: String?
    let author: ObservationAuthor?
}

struct ObservationTaxon: Sendable {
    let commonName: String?
    let scientificName: String?
    let rank: String?
    let iconicTaxonName: String?
    let wikipediaURL: URL?
}

struct ObservationPhoto: Sendable {
    let url: URL
    let attribution: String?
    let licenseCode: String?
}

struct ObservationAuthor: Sendable {
    let name: String?
    let login: String?
}

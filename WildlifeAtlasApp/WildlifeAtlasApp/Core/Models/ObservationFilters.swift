//
//  ObservationFilters.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

struct ObservationFilters: Equatable, Sendable {
    let taxon: TaxonSummary?
    let quality: ObservationQualityFilter
    let dateOrder: ObservationDateOrder

    init(
        taxon: TaxonSummary? = nil,
        quality: ObservationQualityFilter = .any,
        dateOrder: ObservationDateOrder = .newestFirst
    ) {
        self.taxon = taxon
        self.quality = quality
        self.dateOrder = dateOrder
    }
}

enum ObservationQualityFilter: Equatable, Sendable {
    case any
    case research
}

enum ObservationDateOrder: Equatable, Sendable {
    case newestFirst
    case oldestFirst
}

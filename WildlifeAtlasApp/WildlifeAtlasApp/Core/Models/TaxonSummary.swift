//
//  TaxonSummary.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

struct TaxonSummary: Identifiable, Equatable, Sendable {
    let id: Int
    let commonName: String?
    let scientificName: String
}

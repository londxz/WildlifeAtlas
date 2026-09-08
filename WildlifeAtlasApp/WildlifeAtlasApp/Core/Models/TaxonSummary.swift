//
//  TaxonSummary.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation

struct TaxonSummary: Identifiable, Equatable, Sendable {
    let id: Int
    let commonName: String?
    let scientificName: String
    let groupName: String?
    let previewImageURL: URL?

    init(
        id: Int,
        commonName: String?,
        scientificName: String,
        groupName: String? = nil,
        previewImageURL: URL? = nil
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.groupName = groupName
        self.previewImageURL = previewImageURL
    }
}

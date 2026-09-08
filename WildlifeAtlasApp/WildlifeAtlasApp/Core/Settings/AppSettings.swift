//
//  AppSettings.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct AppSettings {
    private enum Key {
        static let observationLayoutMode = "observations.layoutMode"
        static let recentTaxa = "taxonSearch.recentTaxa"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func loadObservationLayoutMode() -> ObservationLayoutMode {
        guard
            let rawValue = userDefaults.string(forKey: Key.observationLayoutMode),
            let layoutMode = ObservationLayoutMode(rawValue: rawValue)
        else {
            return .list
        }

        return layoutMode
    }

    func saveObservationLayoutMode(_ layoutMode: ObservationLayoutMode) {
        userDefaults.set(layoutMode.rawValue, forKey: Key.observationLayoutMode)
    }

    func loadRecentTaxa() -> [TaxonSummary] {
        guard
            let data = userDefaults.data(forKey: Key.recentTaxa),
            let storedTaxa = try? JSONDecoder().decode(
                [StoredTaxon].self,
                from: data
            )
        else {
            return []
        }

        return storedTaxa.map(\.taxon)
    }

    func saveRecentTaxa(_ taxa: [TaxonSummary]) {
        let storedTaxa = taxa.map(StoredTaxon.init)

        guard let data = try? JSONEncoder().encode(storedTaxa) else {
            return
        }

        userDefaults.set(data, forKey: Key.recentTaxa)
    }
}

private struct StoredTaxon: Codable {
    let id: Int
    let commonName: String?
    let scientificName: String
    let groupName: String?
    let previewImageURLString: String?

    init(taxon: TaxonSummary) {
        id = taxon.id
        commonName = taxon.commonName
        scientificName = taxon.scientificName
        groupName = taxon.groupName
        previewImageURLString = taxon.previewImageURL?.absoluteString
    }

    var taxon: TaxonSummary {
        TaxonSummary(
            id: id,
            commonName: commonName,
            scientificName: scientificName,
            groupName: groupName,
            previewImageURL: previewImageURLString.flatMap(URL.init(string:))
        )
    }
}

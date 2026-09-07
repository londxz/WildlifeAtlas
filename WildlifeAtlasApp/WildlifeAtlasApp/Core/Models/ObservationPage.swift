//
//  ObservationPage.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

struct ObservationPage: Sendable {
    let observations: [WildlifeObservation]
    let page: Int
    let perPage: Int
    let totalResults: Int

    var hasNextPage: Bool {
        page * perPage < totalResults
    }
}

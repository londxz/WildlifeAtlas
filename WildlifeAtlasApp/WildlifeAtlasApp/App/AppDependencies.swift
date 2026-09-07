//
//  AppDependencies.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct AppDependencies {
    let observationRepository: any ObservationRepository

    init() {
        let apiClient = URLSessionAPIClient(
            baseURL: Self.iNaturalistAPIBaseURL
        )

        let observationRepository = INaturalistObservationRepository(
            apiClient: apiClient
        )
        
        self.init(observationRepository: observationRepository)
    }

    init(observationRepository: any ObservationRepository) {
        self.observationRepository = observationRepository
    }

    private static let iNaturalistAPIBaseURL: URL = {
        guard let url = URL(string: "https://api.inaturalist.org/v2/") else {
            preconditionFailure("Invalid iNaturalist API base URL")
        }

        return url
    }()
}

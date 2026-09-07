//
//  AppDependencies.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct AppDependencies {
    let observationRepository: any ObservationRepository
    let appSettings: AppSettings

    init() {
        let apiClient = URLSessionAPIClient(
            baseURL: Self.iNaturalistAPIBaseURL
        )

        let observationRepository = INaturalistObservationRepository(
            apiClient: apiClient
        )

        let appSettings = AppSettings(userDefaults: .standard)

        self.init(
            observationRepository: observationRepository,
            appSettings: appSettings
        )
    }

    init(
        observationRepository: any ObservationRepository,
        appSettings: AppSettings
    ) {
        self.observationRepository = observationRepository
        self.appSettings = appSettings
    }

    private static let iNaturalistAPIBaseURL: URL = {
        guard let url = URL(string: "https://api.inaturalist.org/v2/") else {
            preconditionFailure("Invalid iNaturalist API base URL")
        }

        return url
    }()
}

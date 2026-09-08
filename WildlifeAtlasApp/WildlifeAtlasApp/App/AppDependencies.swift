//
//  AppDependencies.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

struct AppDependencies {
    let observationRepository: any ObservationRepository
    let taxonRepository: any TaxonRepository
    let favoritesRepository: any FavoritesRepository
    let appSettings: AppSettings
    let imagePipeline: ImagePipeline

    @MainActor
    init() {
        let apiClient = URLSessionAPIClient(
            baseURL: Self.iNaturalistAPIBaseURL
        )

        let observationRepository = INaturalistObservationRepository(
            apiClient: apiClient
        )
        let taxonRepository = INaturalistTaxonRepository(
            apiClient: apiClient
        )
        let favoritesRepository: any FavoritesRepository

        do {
            favoritesRepository = try SwiftDataFavoritesRepository()
        } catch {
            preconditionFailure("Failed to create favorites storage: \(error)")
        }

        let appSettings = AppSettings(userDefaults: .standard)
        let imagePipeline = ImagePipeline()

        self.init(
            observationRepository: observationRepository,
            taxonRepository: taxonRepository,
            favoritesRepository: favoritesRepository,
            appSettings: appSettings,
            imagePipeline: imagePipeline
        )
    }

    init(
        observationRepository: any ObservationRepository,
        taxonRepository: any TaxonRepository,
        favoritesRepository: any FavoritesRepository,
        appSettings: AppSettings,
        imagePipeline: ImagePipeline
    ) {
        self.observationRepository = observationRepository
        self.taxonRepository = taxonRepository
        self.favoritesRepository = favoritesRepository
        self.appSettings = appSettings
        self.imagePipeline = imagePipeline
    }

    private static let iNaturalistAPIBaseURL: URL = {
        guard let url = URL(string: "https://api.inaturalist.org/v2/") else {
            preconditionFailure("Invalid iNaturalist API base URL")
        }

        return url
    }()
}

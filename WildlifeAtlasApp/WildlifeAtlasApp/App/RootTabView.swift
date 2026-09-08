//
//  RootTabView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    private enum AppTab: Hashable {
        case observations
        case favorites
    }

    @State private var selectedTab: AppTab = .observations
    @State private var observationsViewModel: ObservationsViewModel

    private let observationRepository: any ObservationRepository

    init(dependencies: AppDependencies) {
        observationRepository = dependencies.observationRepository

        _observationsViewModel = State(
            initialValue: ObservationsViewModel(
                observationRepository: dependencies.observationRepository,
                appSettings: dependencies.appSettings
            )
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ObservationsView(viewModel: observationsViewModel)
                    .navigationDestination(for: UUID.self) { observationID in
                        ObservationDetailsView(
                            viewModel: ObservationDetailsViewModel(
                                observationID: observationID,
                                observationRepository: observationRepository
                            )
                        )
                    }
            }
            .tabItem {
                Label("Наблюдения", systemImage: "binoculars")
            }
            .tag(AppTab.observations)

            NavigationStack {
                FavoritesView {
                    selectedTab = .observations
                }
            }
            .tabItem {
                Label("Избранное", systemImage: "heart")
            }
            .tag(AppTab.favorites)
        }
    }
}

//
//  RootTabView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation
import SwiftUI
import UIKit

struct RootTabView: View {
    private enum AppTab: Hashable {
        case observations
        case favorites
    }

    @State private var selectedTab: AppTab = .observations
    @State private var observationsViewModel: ObservationsViewModel
    @State private var taxonSearchViewModel: TaxonSearchViewModel
    @State private var favoritesStore: FavoritesStore
    @FocusState private var isTaxonSearchFocused: Bool

    private let observationRepository: any ObservationRepository
    private let imagePipeline: ImagePipeline

    init(dependencies: AppDependencies) {
        observationRepository = dependencies.observationRepository
        imagePipeline = dependencies.imagePipeline

        _observationsViewModel = State(
            initialValue: ObservationsViewModel(
                observationRepository: dependencies.observationRepository,
                appSettings: dependencies.appSettings
            )
        )
        _taxonSearchViewModel = State(
            initialValue: TaxonSearchViewModel(
                taxonRepository: dependencies.taxonRepository,
                appSettings: dependencies.appSettings
            )
        )
        _favoritesStore = State(
            initialValue: FavoritesStore(
                favoritesRepository: dependencies.favoritesRepository
            )
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ObservationsView(
                    viewModel: observationsViewModel,
                    taxonSearchViewModel: taxonSearchViewModel,
                    imagePipeline: imagePipeline,
                    taxonSearchFocus: $isTaxonSearchFocused
                )
                    .navigationDestination(for: UUID.self) { observationID in
                        observationDetailsView(observationID: observationID)
                    }
            }
            .tabItem {
                Label("Наблюдения", systemImage: "binoculars")
            }
            .tag(AppTab.observations)

            NavigationStack {
                FavoritesView(
                    favoritesStore: favoritesStore,
                    imagePipeline: imagePipeline,
                    onBrowseObservations: {
                        selectedTab = .observations
                    }
                )
                .navigationDestination(for: ObservationDetails.self) { details in
                    observationDetailsView(
                        observationID: details.id,
                        initialDetails: details
                    )
                }
            }
            .tabItem {
                Label("Избранное", systemImage: "heart")
            }
            .tag(AppTab.favorites)
        }
        .background {
            TabBarDimmingView(isDimmed: isTaxonSearchPresented)
        }
        .onChange(of: selectedTab) {
            if selectedTab != .observations {
                isTaxonSearchFocused = false
                taxonSearchViewModel.clearQuery()
            }
        }
    }

    private var isTaxonSearchPresented: Bool {
        taxonSearchViewModel.hasQuery
            || isTaxonSearchFocused && !taxonSearchViewModel.recentTaxa.isEmpty
    }

    private func observationDetailsView(
        observationID: UUID,
        initialDetails: ObservationDetails? = nil
    ) -> ObservationDetailsView {
        ObservationDetailsView(
            viewModel: ObservationDetailsViewModel(
                observationID: observationID,
                observationRepository: observationRepository,
                initialDetails: initialDetails
            ),
            favoritesStore: favoritesStore,
            imagePipeline: imagePipeline
        )
    }
}

private struct TabBarDimmingView: UIViewControllerRepresentable {
    let isDimmed: Bool

    func makeUIViewController(context: Context) -> TabBarDimmingViewController {
        TabBarDimmingViewController()
    }

    func updateUIViewController(
        _ viewController: TabBarDimmingViewController,
        context: Context
    ) {
        viewController.setDimmed(isDimmed)
    }

    static func dismantleUIViewController(
        _ viewController: TabBarDimmingViewController,
        coordinator: Void
    ) {
        viewController.setDimmed(false)
    }
}

private final class TabBarDimmingViewController: UIViewController {
    private static let dimmingOpacity = 0.45

    private var shouldDim = false
    private weak var dimmingView: UIView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDimming()
    }

    func setDimmed(_ isDimmed: Bool) {
        shouldDim = isDimmed
        updateDimming()
    }

    private func updateDimming() {
        guard shouldDim else {
            dimmingView?.removeFromSuperview()
            return
        }

        guard
            let window = view.window,
            let tabBar = findTabBar(in: window),
            dimmingView?.superview !== tabBar
        else {
            return
        }

        let dimmingView = UIView(frame: tabBar.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(
            Self.dimmingOpacity
        )
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.addSubview(dimmingView)
        self.dimmingView = dimmingView
    }

    private func findTabBar(in view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar {
            return tabBar
        }

        for subview in view.subviews {
            if let tabBar = findTabBar(in: subview) {
                return tabBar
            }
        }

        return nil
    }
}

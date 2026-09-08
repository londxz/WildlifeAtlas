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

    private let observationRepository: any ObservationRepository

    init(dependencies: AppDependencies) {
        observationRepository = dependencies.observationRepository

        _observationsViewModel = State(
            initialValue: ObservationsViewModel(
                observationRepository: dependencies.observationRepository,
                appSettings: dependencies.appSettings
            )
        )
        _taxonSearchViewModel = State(
            initialValue: TaxonSearchViewModel(
                taxonRepository: dependencies.taxonRepository
            )
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ObservationsView(
                    viewModel: observationsViewModel,
                    taxonSearchViewModel: taxonSearchViewModel
                )
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
        .background {
            TabBarDimmingView(isDimmed: taxonSearchViewModel.hasQuery)
        }
        .onChange(of: selectedTab) {
            if selectedTab != .observations {
                taxonSearchViewModel.clearQuery()
            }
        }
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

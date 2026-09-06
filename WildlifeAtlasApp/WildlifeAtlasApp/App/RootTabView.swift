//
//  RootTabView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct RootTabView: View {
    private enum AppTab: Hashable {
        case observations
        case favorites
    }

    @State private var selectedTab: AppTab = .observations

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ExploreView()
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

#Preview {
    RootTabView()
}

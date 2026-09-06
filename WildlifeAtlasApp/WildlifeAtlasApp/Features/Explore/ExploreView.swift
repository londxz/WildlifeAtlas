//
//  ExploreView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        ContentUnavailableView(
            "Наблюдений пока нет",
            systemImage: "binoculars",
            description: Text("Здесь появится лента наблюдений за дикой природой.")
        )
        .navigationTitle("Wildlife Atlas")
    }
}

#Preview {
    NavigationStack {
        ExploreView()
    }
}

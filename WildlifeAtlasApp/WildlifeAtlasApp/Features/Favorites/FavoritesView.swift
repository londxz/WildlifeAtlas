//
//  FavoritesView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct FavoritesView: View {
    let onBrowseObservations: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Нет избранных", systemImage: "heart")
        } description: {
            Text("Добавляйте наблюдения с помощью кнопки сердца.")
        } actions: {
            Button("Смотреть наблюдения", action: onBrowseObservations)
                .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Избранное")
    }
}

#Preview {
    NavigationStack {
        FavoritesView(onBrowseObservations: {})
    }
}

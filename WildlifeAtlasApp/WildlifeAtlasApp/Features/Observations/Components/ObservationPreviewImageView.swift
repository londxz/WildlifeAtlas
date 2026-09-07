//
//  ObservationPreviewImageView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationPreviewImageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.quaternary)
        .clipped()
    }
}

//
//  ObservationImageView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI
import UIKit

struct ObservationImageView: View {
    private enum LoadingState {
        case loading
        case loaded(URL, UIImage)
        case failure(URL)
    }

    let url: URL?
    let contentMode: ContentMode
    let imagePipeline: ImagePipeline

    @State private var loadingState: LoadingState = .loading

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        imagePipeline: ImagePipeline
    ) {
        self.url = url
        self.contentMode = contentMode
        self.imagePipeline = imagePipeline
    }

    var body: some View {
        Group {
            if let url {
                image(for: url)
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.quaternary)
        .clipped()
        .task(id: url) {
            await loadImage()
        }
    }

    @ViewBuilder
    private func image(for url: URL) -> some View {
        switch loadingState {
        case .loaded(let loadedURL, let image) where loadedURL == url:
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        case .failure(let failedURL) where failedURL == url:
            placeholder
        default:
            ProgressView()
        }
    }

    private func loadImage() async {
        guard let url else { return }

        loadingState = .loading

        do {
            let image = try await imagePipeline.image(for: url)
            try Task.checkCancellation()
            loadingState = .loaded(url, image)
        } catch is CancellationError {
            return
        } catch {
            loadingState = .failure(url)
        }
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

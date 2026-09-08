//
//  ImagePipeline.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation
import UIKit

actor ImagePipeline {
    private enum LoadingError: Error {
        case invalidResponse
        case invalidImageData
    }

    private static let cacheCostLimit = 64 * 1_024 * 1_024

    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()
    private var loadingTasks: [URL: Task<UIImage, Error>] = [:]

    init(session: URLSession = .shared) {
        self.session = session
        cache.totalCostLimit = Self.cacheCostLimit
    }

    func image(for url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        if let loadingTask = loadingTasks[url] {
            return try await loadingTask.value
        }

        let loadingTask = Task { [session] in
            let (data, response) = try await session.data(from: url)

            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                throw LoadingError.invalidResponse
            }

            guard let image = UIImage(data: data) else {
                throw LoadingError.invalidImageData
            }

            return image
        }

        loadingTasks[url] = loadingTask

        do {
            let image = try await loadingTask.value
            cache.setObject(
                image,
                forKey: url as NSURL,
                cost: Self.cacheCost(for: image)
            )
            loadingTasks[url] = nil
            return image
        } catch {
            loadingTasks[url] = nil
            throw error
        }
    }

    private static func cacheCost(for image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

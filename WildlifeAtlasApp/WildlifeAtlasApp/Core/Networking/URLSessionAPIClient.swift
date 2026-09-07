//
//  URLSessionAPIClient.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<Response: Decodable & Sendable>(
        _ request: APIRequest,
        as type: Response.Type
    ) async throws -> Response {
        guard var components = URLComponents(
            url: baseURL.appending(path: request.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIClientError.invalidRequestURL
        }

        components.queryItems = request.queryItems

        guard let url = components.url else {
            throw APIClientError.invalidRequestURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, urlResponse) = try await session.data(for: urlRequest)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw APIClientError.nonHTTPResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.unsuccessfulStatusCode(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(type, from: data)
    }
}

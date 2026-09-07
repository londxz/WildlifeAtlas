//
//  APIClient.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import Foundation

protocol APIClient: Sendable {
    func get<Response: Decodable & Sendable>(
        _ request: APIRequest,
        as type: Response.Type
    ) async throws -> Response
}

struct APIRequest: Sendable {
    let path: String
    let queryItems: [URLQueryItem]
}

enum APIClientError: Error, Sendable {
    case invalidRequestURL
    case nonHTTPResponse
    case unsuccessfulStatusCode(Int)
}

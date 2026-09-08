//
//  ObservationDTO.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct ObservationDTO: Decodable, Sendable {
    private let uuid: UUID
    private let observedOn: String?
    private let timeObservedAt: String?
    private let qualityGrade: String?
    private let taxon: TaxonDTO?
    private let photos: [PhotoDTO]?
    private let placeGuess: String?
    private let geoprivacy: String?
    private let taxonGeoprivacy: String?
    private let obscured: Bool?
    private let user: UserDTO?
    private let uri: String?

    private enum CodingKeys: String, CodingKey {
        case uuid
        case observedOn = "observed_on"
        case timeObservedAt = "time_observed_at"
        case qualityGrade = "quality_grade"
        case taxon
        case photos
        case placeGuess = "place_guess"
        case geoprivacy
        case taxonGeoprivacy = "taxon_geoprivacy"
        case obscured
        case user
        case uri
    }

    func toObservationSummary() -> ObservationSummary {
        ObservationSummary(
            id: uuid,
            commonName: Self.nonEmpty(taxon?.preferredCommonName),
            scientificName: Self.nonEmpty(taxon?.name),
            observedOn: observedOn.flatMap(Self.parseObservedOn),
            qualityGrade: qualityGrade.flatMap(Self.parseQualityGrade),
            previewImageURL: photos?
                .compactMap { $0.imageURL(size: .medium) }
                .first,
            locationName: publicLocationName
        )
    }

    func toObservationDetails(
        classification: [ObservationTaxonRank] = []
    ) -> ObservationDetails {
        ObservationDetails(
            id: uuid,
            taxon: domainTaxon(classification: classification),
            observedOn: observedOn.flatMap(Self.parseObservedOn),
            observedTime: timeObservedAt.flatMap(Self.parseObservedTime),
            qualityGrade: qualityGrade.flatMap(Self.parseQualityGrade),
            photos: domainPhotos,
            location: domainLocation,
            author: domainAuthor,
            publicURL: uri.flatMap(URL.init(string:))
        )
    }

    var taxonID: Int? {
        taxon?.id
    }

    private func domainTaxon(
        classification: [ObservationTaxonRank]
    ) -> ObservationTaxon? {
        guard let taxon else { return nil }

        let commonName = Self.nonEmpty(taxon.preferredCommonName)
        let scientificName = Self.nonEmpty(taxon.name)
        let rank = Self.nonEmpty(taxon.rank)
        let iconicTaxonName = Self.nonEmpty(taxon.iconicTaxonName)
        let wikipediaURL = taxon.wikipediaURL.flatMap(URL.init(string:))

        guard
            commonName != nil
                || scientificName != nil
                || rank != nil
                || iconicTaxonName != nil
                || wikipediaURL != nil
        else {
            return nil
        }

        return ObservationTaxon(
            commonName: commonName,
            scientificName: scientificName,
            rank: rank,
            iconicTaxonName: iconicTaxonName,
            wikipediaURL: wikipediaURL,
            classification: classification
        )
    }

    private var domainPhotos: [ObservationPhoto] {
        photos?.compactMap { photo in
            guard
                let previewURL = photo.imageURL(size: .medium),
                let largeURL = photo.imageURL(size: .large)
            else {
                return nil
            }

            return ObservationPhoto(
                url: largeURL,
                previewURL: previewURL,
                attribution: Self.nonEmpty(photo.attribution),
                licenseCode: Self.nonEmpty(photo.licenseCode)?.uppercased()
            )
        } ?? []
    }

    private var domainLocation: ObservationLocation? {
        let normalizedGeoprivacy = geoprivacy?.lowercased()
        let normalizedTaxonGeoprivacy = taxonGeoprivacy?.lowercased()

        if obscured == true
            || normalizedGeoprivacy == "obscured"
            || normalizedGeoprivacy == "private"
            || normalizedTaxonGeoprivacy == "obscured"
            || normalizedTaxonGeoprivacy == "private"
        {
            return .obscured
        }

        return Self.nonEmpty(placeGuess).map(ObservationLocation.approximate)
    }

    private var publicLocationName: String? {
        guard case .approximate(let name) = domainLocation else { return nil }
        return name
    }

    private var domainAuthor: ObservationAuthor? {
        guard let user else { return nil }

        let name = Self.nonEmpty(user.name)
        let login = Self.nonEmpty(user.login)
        let avatarURL = user.iconURL.flatMap(URL.init(string:))

        guard name != nil || login != nil || avatarURL != nil else { return nil }

        return ObservationAuthor(
            name: name,
            login: login,
            avatarURL: avatarURL
        )
    }

    private static func parseObservedOn(_ value: String) -> ObservationDate? {
        let components = value.split(separator: "-", omittingEmptySubsequences: false)

        guard
            components.count == 3,
            let year = Int(components[0]),
            let month = Int(components[1]),
            let day = Int(components[2])
        else {
            return nil
        }

        return ObservationDate(
            year: year,
            month: month,
            day: day
        )
    }

    private static func parseObservedTime(_ value: String) -> ObservationTime? {
        guard let time = value.split(separator: "T").dropFirst().first else {
            return nil
        }

        let components = time.split(separator: ":")
        guard
            components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return nil
        }

        return ObservationTime(hour: hour, minute: minute)
    }

    private static func parseQualityGrade(_ value: String) -> ObservationQualityGrade? {
        switch value {
        case "research":
            .research
        case "needs_id":
            .needsIdentification
        case "casual":
            .casual
        default:
            nil
        }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

private struct TaxonDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let preferredCommonName: String?
    let rank: String?
    let iconicTaxonName: String?
    let wikipediaURL: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case preferredCommonName = "preferred_common_name"
        case rank
        case iconicTaxonName = "iconic_taxon_name"
        case wikipediaURL = "wikipedia_url"
    }
}

private struct PhotoDTO: Decodable, Sendable {
    let url: String?
    let attribution: String?
    let licenseCode: String?

    private enum CodingKeys: String, CodingKey {
        case url
        case attribution
        case licenseCode = "license_code"
    }

    func imageURL(size: INaturalistPhotoSize) -> URL? {
        guard let url else { return nil }

        return URL(
            string: url.replacingOccurrences(
                of: "/square.",
                with: "/\(size.rawValue)."
            )
        )
    }
}

private enum INaturalistPhotoSize: String {
    case medium
    case large
}

private struct UserDTO: Decodable, Sendable {
    let login: String?
    let name: String?
    let iconURL: String?

    private enum CodingKeys: String, CodingKey {
        case login
        case name
        case iconURL = "icon_url"
    }
}

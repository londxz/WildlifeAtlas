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
    private let qualityGrade: String?
    private let taxon: TaxonDTO?
    private let photos: [PhotoDTO]?
    private let placeGuess: String?
    private let geoprivacy: String?
    private let obscured: Bool?
    private let user: UserDTO?

    private enum CodingKeys: String, CodingKey {
        case uuid
        case observedOn = "observed_on"
        case qualityGrade = "quality_grade"
        case taxon
        case photos
        case placeGuess = "place_guess"
        case geoprivacy
        case obscured
        case user
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
                .first
        )
    }

    func toObservationDetails() -> ObservationDetails {
        ObservationDetails(
            id: uuid,
            taxon: domainTaxon,
            observedOn: observedOn.flatMap(Self.parseObservedOn),
            qualityGrade: qualityGrade.flatMap(Self.parseQualityGrade),
            photos: domainPhotos,
            locationName: publicLocationName,
            author: domainAuthor
        )
    }

    private var domainTaxon: ObservationTaxon? {
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
            wikipediaURL: wikipediaURL
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

    private var publicLocationName: String? {
        let normalizedGeoprivacy = geoprivacy?.lowercased()

        guard
            obscured != true,
            normalizedGeoprivacy != "obscured",
            normalizedGeoprivacy != "private"
        else {
            return nil
        }

        return Self.nonEmpty(placeGuess)
    }

    private var domainAuthor: ObservationAuthor? {
        guard let user else { return nil }

        let name = Self.nonEmpty(user.name)
        let login = Self.nonEmpty(user.login)

        guard name != nil || login != nil else { return nil }

        return ObservationAuthor(name: name, login: login)
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
    let name: String?
    let preferredCommonName: String?
    let rank: String?
    let iconicTaxonName: String?
    let wikipediaURL: String?

    private enum CodingKeys: String, CodingKey {
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
}

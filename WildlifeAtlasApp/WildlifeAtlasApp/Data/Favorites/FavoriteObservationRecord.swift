//
//  FavoriteObservationRecord.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteObservationRecord {
    @Attribute(.unique) var id: UUID
    var commonName: String?
    var scientificName: String?
    var taxonRank: String?
    var iconicTaxonName: String?
    var wikipediaURLString: String?
    var taxonClassificationData: Data?
    var observedOnYear: Int?
    var observedOnMonth: Int?
    var observedOnDay: Int?
    var observedTimeHour: Int?
    var observedTimeMinute: Int?
    var qualityGradeRawValue: String?
    var photoURLString: String?
    var previewImageURLString: String?
    var photoAttribution: String?
    var photoLicenseCode: String?
    var additionalPhotosData: Data?
    var locationName: String?
    var isLocationObscured: Bool?
    var authorName: String?
    var authorLogin: String?
    var authorAvatarURLString: String?
    var publicURLString: String?
    var addedAt: Date

    init(observation: ObservationDetails, addedAt: Date = .now) {
        id = observation.id
        commonName = observation.taxon?.commonName
        scientificName = observation.taxon?.scientificName
        taxonRank = observation.taxon?.rank
        iconicTaxonName = observation.taxon?.iconicTaxonName
        wikipediaURLString = observation.taxon?.wikipediaURL?.absoluteString
        taxonClassificationData = Self.encodeClassification(
            observation.taxon?.classification ?? []
        )
        observedOnYear = observation.observedOn?.year
        observedOnMonth = observation.observedOn?.month
        observedOnDay = observation.observedOn?.day
        observedTimeHour = observation.observedTime?.hour
        observedTimeMinute = observation.observedTime?.minute
        qualityGradeRawValue = observation.qualityGrade?.rawValue
        let primaryPhoto = observation.photos.first
        photoURLString = primaryPhoto?.url.absoluteString
        previewImageURLString = primaryPhoto?.previewURL.absoluteString
        photoAttribution = primaryPhoto?.attribution
        photoLicenseCode = primaryPhoto?.licenseCode
        additionalPhotosData = Self.encodeAdditionalPhotos(observation.photos)
        switch observation.location {
        case .approximate(let name):
            locationName = name
            isLocationObscured = false
        case .obscured:
            locationName = nil
            isLocationObscured = true
        case nil:
            locationName = nil
            isLocationObscured = false
        }
        authorName = observation.author?.name
        authorLogin = observation.author?.login
        authorAvatarURLString = observation.author?.avatarURL?.absoluteString
        publicURLString = observation.publicURL?.absoluteString
        self.addedAt = addedAt
    }

    func update(with observation: ObservationDetails) {
        commonName = observation.taxon?.commonName
        scientificName = observation.taxon?.scientificName
        taxonRank = observation.taxon?.rank
        iconicTaxonName = observation.taxon?.iconicTaxonName
        wikipediaURLString = observation.taxon?.wikipediaURL?.absoluteString
        taxonClassificationData = Self.encodeClassification(
            observation.taxon?.classification ?? []
        )
        observedOnYear = observation.observedOn?.year
        observedOnMonth = observation.observedOn?.month
        observedOnDay = observation.observedOn?.day
        observedTimeHour = observation.observedTime?.hour
        observedTimeMinute = observation.observedTime?.minute
        qualityGradeRawValue = observation.qualityGrade?.rawValue
        let primaryPhoto = observation.photos.first
        photoURLString = primaryPhoto?.url.absoluteString
        previewImageURLString = primaryPhoto?.previewURL.absoluteString
        photoAttribution = primaryPhoto?.attribution
        photoLicenseCode = primaryPhoto?.licenseCode
        additionalPhotosData = Self.encodeAdditionalPhotos(observation.photos)
        switch observation.location {
        case .approximate(let name):
            locationName = name
            isLocationObscured = false
        case .obscured:
            locationName = nil
            isLocationObscured = true
        case nil:
            locationName = nil
            isLocationObscured = false
        }
        authorName = observation.author?.name
        authorLogin = observation.author?.login
        authorAvatarURLString = observation.author?.avatarURL?.absoluteString
        publicURLString = observation.publicURL?.absoluteString
    }

    func toObservationDetails() -> ObservationDetails {
        ObservationDetails(
            id: id,
            taxon: taxon,
            observedOn: observedOn,
            observedTime: observedTime,
            qualityGrade: qualityGradeRawValue.flatMap(
                ObservationQualityGrade.init(rawValue:)
            ),
            photos: photos,
            location: location,
            author: author,
            publicURL: publicURLString.flatMap(URL.init(string:))
        )
    }

    private var taxon: ObservationTaxon? {
        let wikipediaURL = wikipediaURLString.flatMap(URL.init(string:))

        guard
            commonName != nil
                || scientificName != nil
                || taxonRank != nil
                || iconicTaxonName != nil
                || wikipediaURL != nil
        else {
            return nil
        }

        return ObservationTaxon(
            commonName: commonName,
            scientificName: scientificName,
            rank: taxonRank,
            iconicTaxonName: iconicTaxonName,
            wikipediaURL: wikipediaURL,
            classification: classification
        )
    }

    private var classification: [ObservationTaxonRank] {
        guard
            let taxonClassificationData,
            let storedRanks = try? JSONDecoder().decode(
                [StoredTaxonRank].self,
                from: taxonClassificationData
            )
        else {
            return []
        }

        return storedRanks.map(\.domainRank)
    }

    private var observedOn: ObservationDate? {
        guard
            let observedOnYear,
            let observedOnMonth,
            let observedOnDay
        else {
            return nil
        }

        return ObservationDate(
            year: observedOnYear,
            month: observedOnMonth,
            day: observedOnDay
        )
    }

    private var observedTime: ObservationTime? {
        guard let observedTimeHour, let observedTimeMinute else { return nil }
        return ObservationTime(hour: observedTimeHour, minute: observedTimeMinute)
    }

    private var photos: [ObservationPhoto] {
        var photos = primaryPhoto.map { [$0] } ?? []

        guard
            let additionalPhotosData,
            let storedPhotos = try? JSONDecoder().decode(
                [StoredFavoritePhoto].self,
                from: additionalPhotosData
            )
        else {
            return photos
        }

        photos.append(contentsOf: storedPhotos.compactMap(\.photo))
        return photos
    }

    private var primaryPhoto: ObservationPhoto? {
        guard
            let previewURL = previewImageURLString.flatMap(URL.init(string:))
        else {
            return nil
        }

        let photoURL = photoURLString.flatMap(URL.init(string:)) ?? previewURL

        return ObservationPhoto(
            url: photoURL,
            previewURL: previewURL,
            attribution: photoAttribution,
            licenseCode: photoLicenseCode
        )
    }

    private static func encodeAdditionalPhotos(
        _ photos: [ObservationPhoto]
    ) -> Data? {
        let storedPhotos = photos.dropFirst().map(StoredFavoritePhoto.init)
        guard !storedPhotos.isEmpty else { return nil }

        return try? JSONEncoder().encode(storedPhotos)
    }

    private static func encodeClassification(
        _ classification: [ObservationTaxonRank]
    ) -> Data? {
        guard !classification.isEmpty else { return nil }
        return try? JSONEncoder().encode(classification.map(StoredTaxonRank.init))
    }

    private var author: ObservationAuthor? {
        let avatarURL = authorAvatarURLString.flatMap(URL.init(string:))
        guard authorName != nil || authorLogin != nil || avatarURL != nil else {
            return nil
        }

        return ObservationAuthor(
            name: authorName,
            login: authorLogin,
            avatarURL: avatarURL
        )
    }

    private var location: ObservationLocation? {
        if isLocationObscured == true {
            return .obscured
        }

        return locationName.map(ObservationLocation.approximate)
    }
}

private struct StoredTaxonRank: Codable {
    let rank: String
    let name: String

    init(domainRank: ObservationTaxonRank) {
        rank = domainRank.rank
        name = domainRank.name
    }

    var domainRank: ObservationTaxonRank {
        ObservationTaxonRank(rank: rank, name: name)
    }
}

private struct StoredFavoritePhoto: Codable {
    let urlString: String
    let previewURLString: String
    let attribution: String?
    let licenseCode: String?

    init(photo: ObservationPhoto) {
        urlString = photo.url.absoluteString
        previewURLString = photo.previewURL.absoluteString
        attribution = photo.attribution
        licenseCode = photo.licenseCode
    }

    var photo: ObservationPhoto? {
        guard let previewURL = URL(string: previewURLString) else {
            return nil
        }

        return ObservationPhoto(
            url: URL(string: urlString) ?? previewURL,
            previewURL: previewURL,
            attribution: attribution,
            licenseCode: licenseCode
        )
    }
}

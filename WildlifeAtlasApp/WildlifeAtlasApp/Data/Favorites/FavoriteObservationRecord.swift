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
    var observedOnYear: Int?
    var observedOnMonth: Int?
    var observedOnDay: Int?
    var qualityGradeRawValue: String?
    var photoURLString: String?
    var previewImageURLString: String?
    var photoAttribution: String?
    var photoLicenseCode: String?
    var locationName: String?
    var authorName: String?
    var authorLogin: String?
    var addedAt: Date

    init(observation: ObservationDetails, addedAt: Date = .now) {
        id = observation.id
        commonName = observation.taxon?.commonName
        scientificName = observation.taxon?.scientificName
        taxonRank = observation.taxon?.rank
        iconicTaxonName = observation.taxon?.iconicTaxonName
        wikipediaURLString = observation.taxon?.wikipediaURL?.absoluteString
        observedOnYear = observation.observedOn?.year
        observedOnMonth = observation.observedOn?.month
        observedOnDay = observation.observedOn?.day
        qualityGradeRawValue = observation.qualityGrade?.rawValue
        photoURLString = observation.photo?.url.absoluteString
        previewImageURLString = observation.photo?.previewURL.absoluteString
        photoAttribution = observation.photo?.attribution
        photoLicenseCode = observation.photo?.licenseCode
        locationName = observation.locationName
        authorName = observation.author?.name
        authorLogin = observation.author?.login
        self.addedAt = addedAt
    }

    func update(with observation: ObservationDetails) {
        commonName = observation.taxon?.commonName
        scientificName = observation.taxon?.scientificName
        taxonRank = observation.taxon?.rank
        iconicTaxonName = observation.taxon?.iconicTaxonName
        wikipediaURLString = observation.taxon?.wikipediaURL?.absoluteString
        observedOnYear = observation.observedOn?.year
        observedOnMonth = observation.observedOn?.month
        observedOnDay = observation.observedOn?.day
        qualityGradeRawValue = observation.qualityGrade?.rawValue
        photoURLString = observation.photo?.url.absoluteString
        previewImageURLString = observation.photo?.previewURL.absoluteString
        photoAttribution = observation.photo?.attribution
        photoLicenseCode = observation.photo?.licenseCode
        locationName = observation.locationName
        authorName = observation.author?.name
        authorLogin = observation.author?.login
    }

    func toObservationDetails() -> ObservationDetails {
        ObservationDetails(
            id: id,
            taxon: taxon,
            observedOn: observedOn,
            qualityGrade: qualityGradeRawValue.flatMap(
                ObservationQualityGrade.init(rawValue:)
            ),
            photo: photo,
            locationName: locationName,
            author: author
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
            wikipediaURL: wikipediaURL
        )
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

    private var photo: ObservationPhoto? {
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

    private var author: ObservationAuthor? {
        guard authorName != nil || authorLogin != nil else { return nil }

        return ObservationAuthor(name: authorName, login: authorLogin)
    }
}

//
//  ObservationSummary.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct ObservationSummary: Identifiable, Sendable {
    let id: UUID
    let commonName: String?
    let scientificName: String?
    let observedOn: ObservationDate?
    let qualityGrade: ObservationQualityGrade?
    let previewImageURL: URL?
    let locationName: String?
}

struct ObservationDate: Hashable, Sendable {
    let year: Int
    let month: Int
    let day: Int

    init?(year: Int, month: Int, day: Int) {
        var calendar = Calendar(identifier: .gregorian)

        if let utc = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utc
        }

        let components = DateComponents(year: year, month: month, day: day)

        guard let date = calendar.date(from: components) else {
            return nil
        }

        let validatedComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard
            validatedComponents.year == year,
            validatedComponents.month == month,
            validatedComponents.day == day
        else {
            return nil
        }

        self.year = year
        self.month = month
        self.day = day
    }

    func date(in timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day
            )
        )
    }

    func date(at time: ObservationTime, in timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: time.hour,
                minute: time.minute
            )
        )
    }
}

struct ObservationTime: Hashable, Sendable {
    let hour: Int
    let minute: Int

    init?(hour: Int, minute: Int) {
        guard (0..<24).contains(hour), (0..<60).contains(minute) else {
            return nil
        }

        self.hour = hour
        self.minute = minute
    }
}

enum ObservationQualityGrade: String, Hashable, Sendable {
    case research
    case needsIdentification
    case casual
}

//
//  ObservationRowView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ObservationRowView: View {
    let observation: ObservationSummary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageURL = observation.previewImageURL {
                ObservationImageView(url: imageURL)
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                if let commonName = observation.commonName {
                    Text(commonName)
                        .font(.headline)
                }

                if let scientificName = observation.scientificName {
                    Text(scientificName)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                }

                if
                    let observedOn = observation.observedOn,
                    let date = observedOn.date(in: .current)
                {
                    Label {
                        Text(date, format: .dateTime.day().month().year())
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                if let qualityGrade = observation.qualityGrade {
                    ObservationQualityLabel(qualityGrade: qualityGrade)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

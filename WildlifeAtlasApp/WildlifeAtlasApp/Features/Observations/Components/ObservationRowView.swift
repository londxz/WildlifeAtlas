//
//  ObservationRowView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ObservationRowView: View {
    let observation: ObservationSummary
    let imagePipeline: ImagePipeline

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ObservationImageView(
                url: observation.previewImageURL,
                imagePipeline: imagePipeline
            )
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 12))

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

                Spacer(minLength: 0)

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
            .frame(minHeight: 88, alignment: .top)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

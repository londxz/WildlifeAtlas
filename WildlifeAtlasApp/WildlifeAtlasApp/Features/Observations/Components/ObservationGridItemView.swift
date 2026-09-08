//
//  ObservationGridItemView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationGridItemView: View {
    let observation: ObservationSummary
    let imagePipeline: ImagePipeline

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    ObservationImageView(
                        url: observation.previewImageURL,
                        imagePipeline: imagePipeline
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let commonName = observation.commonName {
                Text(commonName)
                    .font(.headline)
                    .lineLimit(2)
            }

            if let scientificName = observation.scientificName {
                Text(scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(8)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary)
        }
    }
}

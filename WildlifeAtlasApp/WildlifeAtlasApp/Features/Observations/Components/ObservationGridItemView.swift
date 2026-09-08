//
//  ObservationGridItemView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationGridItemView: View {
    let observation: ObservationSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = observation.previewImageURL {
                ObservationImageView(url: imageURL)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if let commonName = observation.commonName {
                Text(commonName)
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
            }

            if let scientificName = observation.scientificName {
                Text(scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
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

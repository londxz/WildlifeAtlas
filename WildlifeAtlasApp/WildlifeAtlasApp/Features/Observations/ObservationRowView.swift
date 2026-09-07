//
//  ObservationRowView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

struct ObservationRowView: View {
    let observation: WildlifeObservation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageURL = observation.previewImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 88, height: 88)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Фотография наблюдения")
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
                    qualityLabel(for: qualityGrade)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private func qualityLabel(for qualityGrade: ObservationQualityGrade) -> some View {
        Label(qualityGrade.title, systemImage: qualityGrade.systemImage)
            .font(.caption)
            .foregroundStyle(qualityGrade.color)
    }
}

private extension ObservationQualityGrade {
    var title: String {
        switch self {
        case .research:
            "Исследовательское"
        case .needsIdentification:
            "Требуется определение"
        case .casual:
            "Обычное"
        }
    }

    var systemImage: String {
        switch self {
        case .research:
            "checkmark.seal.fill"
        case .needsIdentification:
            "questionmark.circle.fill"
        case .casual:
            "circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .research:
            .green
        case .needsIdentification:
            .orange
        case .casual:
            .secondary
        }
    }
}

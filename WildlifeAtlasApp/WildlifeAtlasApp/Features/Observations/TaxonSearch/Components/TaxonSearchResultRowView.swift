//
//  TaxonSearchResultRowView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import SwiftUI

struct TaxonSearchResultRowView: View {
    let taxon: TaxonSummary

    var body: some View {
        HStack(spacing: 12) {
            taxonImage

            VStack(alignment: .leading, spacing: 3) {
                Text(taxon.commonName ?? taxon.scientificName)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                if taxon.commonName != nil {
                    Text(taxon.scientificName)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            if let groupTitle {
                Text(groupTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var taxonImage: some View {
        if let previewImageURL = taxon.previewImageURL {
            ObservationImageView(url: previewImageURL)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "leaf")
                .foregroundStyle(.secondary)
                .frame(width: 52, height: 52)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var groupTitle: String? {
        switch taxon.groupName {
        case "Animalia":
            "Животные"
        case "Plantae":
            "Растения"
        case "Fungi":
            "Грибы"
        case "Aves":
            "Птицы"
        case "Mammalia":
            "Млекопитающие"
        case "Reptilia":
            "Рептилии"
        case "Amphibia":
            "Земноводные"
        case "Actinopterygii":
            "Рыбы"
        case "Mollusca":
            "Моллюски"
        case "Arachnida":
            "Паукообразные"
        case "Insecta":
            "Насекомые"
        case "Protozoa":
            "Простейшие"
        case "Chromista":
            "Хромисты"
        case .some(let groupName):
            groupName
        case .none:
            nil
        }
    }
}

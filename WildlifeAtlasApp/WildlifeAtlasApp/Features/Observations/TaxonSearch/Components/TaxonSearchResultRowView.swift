//
//  TaxonSearchResultRowView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import SwiftUI

struct TaxonSearchResultRowView: View {
    let taxon: TaxonSummary
    let imagePipeline: ImagePipeline

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
            ObservationImageView(
                url: previewImageURL,
                imagePipeline: imagePipeline
            )
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
            "Animals"
        case "Plantae":
            "Plants"
        case "Fungi":
            "Fungi"
        case "Aves":
            "Birds"
        case "Mammalia":
            "Mammals"
        case "Reptilia":
            "Reptiles"
        case "Amphibia":
            "Amphibians"
        case "Actinopterygii":
            "Ray-finned fishes"
        case "Mollusca":
            "Mollusks"
        case "Arachnida":
            "Arachnids"
        case "Insecta":
            "Insects"
        case "Protozoa":
            "Protozoans"
        case "Chromista":
            "Chromists"
        case .some(let groupName):
            groupName
        case .none:
            nil
        }
    }
}

//
//  ObservationDetailsLoadingView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationDetailsLoadingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.quaternary)
                    .aspectRatio(4 / 3, contentMode: .fit)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Common name")
                        .font(.title2.bold())

                    Text("Scientific name")
                        .font(.headline)
                        .italic()

                    Text("Quality grade")
                        .font(.caption)

                    Text("Observation date")
                }

                ObservationDetailsSection("Taxon") {
                    Text("Taxon rank")
                    Text("Taxonomic group")
                }

                ObservationDetailsSection("Location") {
                    Text("Approximate location")
                }

                ObservationDetailsSection("Observer") {
                    Text("Observer name")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .redacted(reason: .placeholder)
            .modifier(SkeletonShimmerModifier())
        }
        .allowsHitTesting(false)
    }
}

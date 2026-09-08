//
//  ObservationsLoadingView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import SwiftUI

struct ObservationsLoadingView: View {
    let layoutMode: ObservationLayoutMode
    let gridColumns: [GridItem]

    var body: some View {
        Group {
            switch layoutMode {
            case .list:
                listSkeleton
            case .grid:
                gridSkeleton
            }
        }
        .allowsHitTesting(false)
    }

    private var listSkeleton: some View {
        List {
            ForEach(0..<6, id: \.self) { _ in
                ObservationRowSkeleton()
            }
        }
        .listStyle(.plain)
    }

    private var gridSkeleton: some View {
        ScrollView {
            LazyVGrid(
                columns: gridColumns,
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(0..<6, id: \.self) { _ in
                    ObservationGridItemSkeleton()
                }
            }
        }
        .contentMargins(.horizontal, 12, for: .scrollContent)
    }
}

private struct ObservationRowSkeleton: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .frame(width: 108, height: 108)

            VStack(alignment: .leading, spacing: 6) {
                Text("Common name")
                    .font(.headline)

                Text("Scientific name")
                    .font(.subheadline)
                    .italic()

                Label("Observation date", systemImage: "calendar")
                    .font(.caption)

                Label("Approximate location", systemImage: "mappin.and.ellipse")
                    .font(.caption)

                Label("Quality grade", systemImage: "circle.fill")
                    .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .redacted(reason: .placeholder)
        .modifier(SkeletonShimmerModifier())
    }
}

private struct ObservationGridItemSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
                .aspectRatio(1, contentMode: .fit)

            Text("Common name")
                .font(.headline)
                .lineLimit(2, reservesSpace: true)

            Text("Scientific name")
                .font(.subheadline)
                .italic()
                .lineLimit(2, reservesSpace: true)

            Label("Observation date", systemImage: "calendar")
                .font(.caption)

            Label("Approximate location", systemImage: "mappin.and.ellipse")
                .font(.caption)

            Label("Quality grade", systemImage: "circle.fill")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(8)
        .redacted(reason: .placeholder)
        .modifier(SkeletonShimmerModifier())
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary)
        }
    }
}

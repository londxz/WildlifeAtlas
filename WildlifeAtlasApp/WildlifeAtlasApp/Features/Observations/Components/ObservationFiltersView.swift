//
//  ObservationFiltersView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

import SwiftUI

struct ObservationFiltersView: View {
    private static let basicTaxa = [
        TaxonSummary(
            id: 1,
            commonName: "Животные",
            scientificName: "Animalia"
        ),
        TaxonSummary(
            id: 47126,
            commonName: "Растения",
            scientificName: "Plantae"
        ),
        TaxonSummary(
            id: 47170,
            commonName: "Грибы",
            scientificName: "Fungi"
        )
    ]

    let filters: ObservationFilters
    let onSelectTaxon: (TaxonSummary?) -> Void
    let onSelectQuality: (ObservationQualityFilter) -> Void
    let onSelectDateOrder: (ObservationDateOrder) -> Void

    @State private var isTaxonFilterPresented = false
    @State private var isQualityFilterPresented = false
    @State private var isDateOrderFilterPresented = false

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                taxonFilter
                qualityFilter
                dateOrderFilter
            }
        }
        .contentMargins(.horizontal, 12, for: .scrollContent)
        .scrollIndicators(.hidden)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var taxonFilter: some View {
        if let taxon = filters.taxon {
            Button {
                onSelectTaxon(nil)
            } label: {
                FilterChipLabel(
                    title: taxon.commonName ?? taxon.scientificName,
                    systemImage: "xmark",
                    isSelected: true
                )
            }
            .buttonStyle(.plain)
        } else {
            Button {
                isTaxonFilterPresented = true
            } label: {
                FilterChipLabel(
                    title: "Все наблюдения",
                    systemImage: "chevron.down",
                    isExpanded: isTaxonFilterPresented
                )
            }
            .buttonStyle(.plain)
            .popover(
                isPresented: $isTaxonFilterPresented,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .top
            ) {
                taxonFilterOptions
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var qualityFilter: some View {
        Button {
            isQualityFilterPresented = true
        } label: {
            FilterChipLabel(
                title: qualityFilterTitle,
                systemImage: "chevron.down",
                isExpanded: isQualityFilterPresented
            )
        }
        .buttonStyle(.plain)
        .popover(
            isPresented: $isQualityFilterPresented,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            qualityFilterOptions
                .presentationCompactAdaptation(.popover)
        }
    }

    private var dateOrderFilter: some View {
        Button {
            isDateOrderFilterPresented = true
        } label: {
            FilterChipLabel(
                title: dateOrderTitle,
                systemImage: "chevron.down",
                isExpanded: isDateOrderFilterPresented
            )
        }
        .buttonStyle(.plain)
        .popover(
            isPresented: $isDateOrderFilterPresented,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            dateOrderFilterOptions
                .presentationCompactAdaptation(.popover)
        }
    }

    private var taxonFilterOptions: some View {
        FilterOptionsView {
            filterOption("Все наблюдения", isSelected: true) {
                isTaxonFilterPresented = false
                onSelectTaxon(nil)
            }

            Divider()

            ForEach(Self.basicTaxa) { taxon in
                filterOption(
                    taxon.commonName ?? taxon.scientificName,
                    isSelected: false
                ) {
                    isTaxonFilterPresented = false
                    onSelectTaxon(taxon)
                }
            }
        }
    }

    private var qualityFilterOptions: some View {
        FilterOptionsView {
            filterOption(
                "Любое качество",
                isSelected: filters.quality == .any
            ) {
                isQualityFilterPresented = false
                onSelectQuality(.any)
            }

            Divider()

            filterOption(
                "Исследовательское",
                isSelected: filters.quality == .research
            ) {
                isQualityFilterPresented = false
                onSelectQuality(.research)
            }
        }
    }

    private var dateOrderFilterOptions: some View {
        FilterOptionsView {
            filterOption(
                "Сначала новые",
                isSelected: filters.dateOrder == .newestFirst
            ) {
                isDateOrderFilterPresented = false
                onSelectDateOrder(.newestFirst)
            }

            Divider()

            filterOption(
                "Сначала старые",
                isSelected: filters.dateOrder == .oldestFirst
            ) {
                isDateOrderFilterPresented = false
                onSelectDateOrder(.oldestFirst)
            }
        }
    }

    private func filterOption(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark")
                    .opacity(isSelected ? 1 : 0)

                Text(title)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
    }

    private var qualityFilterTitle: String {
        switch filters.quality {
        case .any:
            "Любое качество"
        case .research:
            "Исследовательское"
        }
    }

    private var dateOrderTitle: String {
        switch filters.dateOrder {
        case .newestFirst:
            "Сначала новые"
        case .oldestFirst:
            "Сначала старые"
        }
    }
}

private struct FilterChipLabel: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let isExpanded: Bool

    init(
        title: String,
        systemImage: String? = nil,
        isSelected: Bool = false,
        isExpanded: Bool = false
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.isExpanded = isExpanded
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .lineLimit(1)

            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.snappy(duration: 0.2), value: isExpanded)
            }
        }
        .font(.subheadline)
        .fixedSize(horizontal: true, vertical: false)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
            if isSelected {
                Capsule().fill(Color.accentColor)
            } else {
                Capsule().fill(.background)
            }
        }
        .overlay {
            if !isSelected {
                Capsule().stroke(.tertiary, lineWidth: 1)
            }
        }
        .contentShape(Capsule())
    }
}

private struct FilterOptionsView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(width: 250)
        .padding(.vertical, 8)
    }
}

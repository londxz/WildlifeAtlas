//
//  ObservationDetailsContentView.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationDetailsContentView: View {
    let details: ObservationDetails
    let imagePipeline: ImagePipeline

    @State private var selectedPhotoIndex = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !details.photos.isEmpty {
                    photoGallery
                }

                primaryInformation

                if
                    let taxon = details.taxon,
                    hasAdditionalInformation(taxon)
                {
                    ObservationDetailsSection("Taxon") {
                        ForEach(taxon.classification, id: \.rank) { taxonRank in
                            LabeledContent(
                                rankTitle(taxonRank.rank),
                                value: taxonRank.name
                            )
                        }

                        if let rank = taxon.rank {
                            LabeledContent("Observation rank", value: rankTitle(rank))
                        }

                        if let iconicTaxonName = taxon.iconicTaxonName {
                            LabeledContent("Group", value: iconicTaxonName)
                        }

                        if let wikipediaURL = taxon.wikipediaURL {
                            Link(destination: wikipediaURL) {
                                Label("Open in Wikipedia", systemImage: "safari")
                            }
                        }
                    }
                }

                if let location = details.location {
                    locationSection(location)
                }

                if let author = details.author {
                    authorSection(author)
                }

                if let selectedPhoto,
                   selectedPhoto.attribution != nil
                    || selectedPhoto.licenseCode != nil
                {
                    ObservationDetailsSection("Photo") {
                        if let attribution = selectedPhoto.attribution {
                            Text(attribution)
                        }

                        if let licenseCode = selectedPhoto.licenseCode {
                            LabeledContent("License", value: licenseCode)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var photoGallery: some View {
        Color.clear
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                TabView(selection: $selectedPhotoIndex) {
                    ForEach(details.photos.indices, id: \.self) { index in
                        ObservationImageView(
                            url: details.photos[index].url,
                            contentMode: .fit,
                            imagePipeline: imagePipeline
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(
                    .page(
                        indexDisplayMode: details.photos.count > 1
                            ? .automatic
                            : .never
                    )
                )
                .background(.quaternary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var selectedPhoto: ObservationPhoto? {
        guard details.photos.indices.contains(selectedPhotoIndex) else {
            return nil
        }

        return details.photos[selectedPhotoIndex]
    }

    private var primaryInformation: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let commonName = details.taxon?.commonName {
                Text(commonName)
                    .font(.title2.bold())
            }

            if let scientificName = details.taxon?.scientificName {
                Text(scientificName)
                    .font(.headline)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            if let qualityGrade = details.qualityGrade {
                ObservationQualityLabel(qualityGrade: qualityGrade)
            }

            if let observedOn = details.observedOn {
                Label {
                    observationDate(observedOn)
                } icon: {
                    Image(systemName: "calendar")
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    private func hasAdditionalInformation(_ taxon: ObservationTaxon) -> Bool {
        taxon.rank != nil
            || taxon.iconicTaxonName != nil
            || taxon.wikipediaURL != nil
            || !taxon.classification.isEmpty
    }

    @ViewBuilder
    private func observationDate(_ observedOn: ObservationDate) -> some View {
        if
            let observedTime = details.observedTime,
            let date = observedOn.date(at: observedTime, in: .current)
        {
            Text(
                date,
                format: .dateTime.day().month().year().hour().minute()
            )
        } else if let date = observedOn.date(in: .current) {
            Text(date, format: .dateTime.day().month().year())
        }
    }

    private func authorSection(_ author: ObservationAuthor) -> some View {
        ObservationDetailsSection("Observer") {
            HStack(spacing: 12) {
                if let avatarURL = author.avatarURL {
                    ObservationImageView(
                        url: avatarURL,
                        imagePipeline: imagePipeline
                    )
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                        .frame(width: 52, height: 52)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let name = author.name {
                        Text(name)
                    }

                    if let login = author.login, login != author.name {
                        Text("@\(login)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func locationSection(_ location: ObservationLocation) -> some View {
        ObservationDetailsSection("Location") {
            switch location {
            case .approximate(let name):
                Label(name, systemImage: "mappin.and.ellipse")
            case .obscured:
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location obscured")
                            .font(.headline)

                        Text("Exact location is hidden to protect wildlife and sensitive habitats.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "lock.fill")
                }
            }
        }
    }

    private func rankTitle(_ rank: String) -> String {
        switch rank {
        case "kingdom":
            "Kingdom"
        case "phylum":
            "Phylum"
        case "class":
            "Class"
        case "order":
            "Order"
        case "family":
            "Family"
        case "genus":
            "Genus"
        case "species":
            "Species"
        default:
            rank
        }
    }
}

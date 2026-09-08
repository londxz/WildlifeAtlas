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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let photo = details.photo {
                    ObservationImageView(
                        url: photo.url,
                        contentMode: .fit,
                        imagePipeline: imagePipeline
                    )
                        .aspectRatio(4 / 3, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                primaryInformation

                if
                    let taxon = details.taxon,
                    hasAdditionalInformation(taxon)
                {
                    ObservationDetailsSection("Таксон") {
                        if let rank = taxon.rank {
                            LabeledContent("Ранг", value: rankTitle(rank))
                        }

                        if let iconicTaxonName = taxon.iconicTaxonName {
                            LabeledContent("Группа", value: iconicTaxonName)
                        }

                        if let wikipediaURL = taxon.wikipediaURL {
                            Link(destination: wikipediaURL) {
                                Label("Открыть в Wikipedia", systemImage: "safari")
                            }
                        }
                    }
                }

                if let locationName = details.locationName {
                    ObservationDetailsSection("Место наблюдения") {
                        Label(locationName, systemImage: "mappin.and.ellipse")
                    }
                }

                if let author = details.author {
                    ObservationDetailsSection("Автор наблюдения") {
                        if let name = author.name {
                            Text(name)
                        }

                        if
                            let login = author.login,
                            login != author.name
                        {
                            Text("@\(login)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if
                    let photo = details.photo,
                    photo.attribution != nil || photo.licenseCode != nil
                {
                    ObservationDetailsSection("Фотография") {
                        if let attribution = photo.attribution {
                            Text(attribution)
                        }

                        if let licenseCode = photo.licenseCode {
                            LabeledContent("Лицензия", value: licenseCode)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
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

            if
                let observedOn = details.observedOn,
                let date = observedOn.date(in: .current)
            {
                Label {
                    Text(date, format: .dateTime.day().month().year())
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
    }

    private func rankTitle(_ rank: String) -> String {
        switch rank {
        case "kingdom":
            "Царство"
        case "phylum":
            "Тип"
        case "class":
            "Класс"
        case "order":
            "Отряд"
        case "family":
            "Семейство"
        case "genus":
            "Род"
        case "species":
            "Вид"
        default:
            rank
        }
    }
}

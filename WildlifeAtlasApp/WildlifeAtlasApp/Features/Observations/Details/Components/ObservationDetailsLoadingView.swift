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
                    Text("Общепринятое название")
                        .font(.title2.bold())

                    Text("Научное название")
                        .font(.headline)
                        .italic()

                    Text("Качество наблюдения")
                        .font(.caption)

                    Text("Дата наблюдения")
                }

                ObservationDetailsSection("Таксон") {
                    Text("Ранг таксона")
                    Text("Группа живых организмов")
                }

                ObservationDetailsSection("Место наблюдения") {
                    Text("Приблизительное место")
                }

                ObservationDetailsSection("Автор наблюдения") {
                    Text("Имя автора")
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

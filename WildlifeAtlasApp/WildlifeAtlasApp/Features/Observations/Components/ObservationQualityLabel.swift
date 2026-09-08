//
//  ObservationQualityLabel.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import SwiftUI

struct ObservationQualityLabel: View {
    let qualityGrade: ObservationQualityGrade

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption)
            .foregroundStyle(color)
    }

    private var title: String {
        switch qualityGrade {
        case .research:
            "Research grade"
        case .needsIdentification:
            "Needs ID"
        case .casual:
            "Casual"
        }
    }

    private var systemImage: String {
        switch qualityGrade {
        case .research:
            "checkmark.seal.fill"
        case .needsIdentification:
            "questionmark.circle.fill"
        case .casual:
            "circle.fill"
        }
    }

    private var color: Color {
        switch qualityGrade {
        case .research:
            .green
        case .needsIdentification:
            .orange
        case .casual:
            .secondary
        }
    }
}

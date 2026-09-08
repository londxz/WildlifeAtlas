//
//  TaxonClassificationResponseDTO.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 08.09.2026.
//

struct TaxonClassificationResponseDTO: Decodable, Sendable {
    private let results: [TaxonClassificationDTO]

    func toDomain() -> [ObservationTaxonRank] {
        guard let taxon = results.first else { return [] }

        return (taxon.ancestors + [taxon]).compactMap { taxon in
            guard Self.supportedRanks.contains(taxon.rank) else { return nil }
            return ObservationTaxonRank(rank: taxon.rank, name: taxon.name)
        }
    }

    private static let supportedRanks = [
        "kingdom",
        "phylum",
        "class",
        "order",
        "family"
    ]
}

private struct TaxonClassificationDTO: Decodable, Sendable {
    let name: String
    let rank: String
    let ancestors: [TaxonClassificationDTO]

    private enum CodingKeys: String, CodingKey {
        case name
        case rank
        case ancestors
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        rank = try container.decode(String.self, forKey: .rank)
        ancestors = try container.decodeIfPresent(
            [TaxonClassificationDTO].self,
            forKey: .ancestors
        ) ?? []
    }
}

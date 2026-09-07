//
//  AppSettings.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 07.09.2026.
//

import Foundation

struct AppSettings {
    private enum Key {
        static let observationLayoutMode = "observations.layoutMode"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func loadObservationLayoutMode() -> ObservationLayoutMode {
        guard
            let rawValue = userDefaults.string(forKey: Key.observationLayoutMode),
            let layoutMode = ObservationLayoutMode(rawValue: rawValue)
        else {
            return .list
        }

        return layoutMode
    }

    func saveObservationLayoutMode(_ layoutMode: ObservationLayoutMode) {
        userDefaults.set(layoutMode.rawValue, forKey: Key.observationLayoutMode)
    }
}

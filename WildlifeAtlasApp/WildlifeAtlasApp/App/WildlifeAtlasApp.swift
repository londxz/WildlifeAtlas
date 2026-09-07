//
//  WildlifeAtlasApp.swift
//  WildlifeAtlasApp
//
//  Created by Родион Холодов on 06.09.2026.
//

import SwiftUI

@main
struct WildlifeAtlasApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
        }
    }
}

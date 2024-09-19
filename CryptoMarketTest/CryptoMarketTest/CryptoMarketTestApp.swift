//
//  CryptoMarketTestApp.swift
//  CryptoMarketTest
//
//  Created by Max Pintchouk on 9/19/24.
//

import SwiftUI
import SwiftData

@main
struct CryptoMarketTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DataModel.self)
        }
    }
}

//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Eric Chan on 8/16/22.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrumsView(scrums: DailyScrum.sampleData)
            }
        }
    }
}

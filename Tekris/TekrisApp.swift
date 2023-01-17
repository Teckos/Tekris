//
//  TeckrisApp.swift
//  Teckris
//
//  Created by Teck Tea on 06/01/2023.
//

import SwiftUI

@main
struct TekrisApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(board)
        }
    }
}

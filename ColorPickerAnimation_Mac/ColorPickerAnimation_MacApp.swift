//
//  ColorPickerAnimation_MacApp.swift
//  ColorPickerAnimation_Mac
//
//  Created by M H on 20/12/2022.
//

import SwiftUI

@main
struct ColorPickerAnimation_MacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.windowStyle(.hiddenTitleBar)
		.windowResizability(.contentSize)
    }
}

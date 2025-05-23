//
//  JovesLandingApp.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/9/22.
//

import SwiftUI
import BLEByJove
import Infrastructure

@main
struct JovesLandingApp: App {
	private let bluetooth = BTClient()
	private let mDNS = MDNSClient()
	private let facilities = FacilitiesFactory()

	@SceneBuilder var body: some Scene {
		WindowGroup {
			FacilitiesListView(bluetooth: bluetooth, mDNS: mDNS, facilities: facilities)
		}
	}
}

//
//  JovesLandingApp.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/9/22.
//

import SwiftUI
import BTByJove
import Infrastructure

extension BTClient {
	private static var mocking: Bool {
		#if targetEnvironment(simulator)
			true
		#else
			false
		#endif
	}

	public static let services: [BTServiceIdentity] = {
		var base = [
			TheJoveExpress.Service,
			CircuiteCube.Service,
			LegoPoweredUp.Service,
		]
		if (mocking) {
			base.append(BTServiceIdentity(name: "Garbage", id: UUID()))
		}
		return base
	}()

	convenience init() {
		self.init(services: Self.services, mocking: Self.mocking)
	}
}

@main
struct JovesLandingApp: App {
	@ObservedObject private var client = BTClient()

	@SceneBuilder var body: some Scene {
		WindowGroup {
			SystemSelectorView(client)
		}
	}
}

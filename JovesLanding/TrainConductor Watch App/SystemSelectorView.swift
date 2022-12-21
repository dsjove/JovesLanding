//
//  SystemSelectorView.swift
//  TrainConductor Watch App
//
//  Created by David Giovannini on 12/15/22.
//

import SwiftUI
import BTByJove
import TrainsByJove

struct SystemSelectorView: View {
	@ObservedObject private var client: BTClient

	@State private var models: ServiceImpFactory = {
		ServiceImpFactory()
	}()

	init(_ client: BTClient) {
		self.client = client
	}

    var body: some View {
		NavigationStack {
			List(client.devices) { device in
				NavigationLink(device.name, value: device)
			}
			.onAppear() {
				client.scanning = true
			}
			.onDisappear() {
				client.scanning = false
			}
			.navigationDestination(for: BTDevice.self) { device in
				SystemDetailView(impl: models.implementation(for: device))
					.padding(0)
					.ignoresSafeArea(edges: Edge.Set.all.subtracting(.top))
					.navigationTitle(device.name)
					.onAppear() {
						device.connect()
					}
					.onDisappear() {
						device.disconnect()
					}
			}
		}
    }
}

struct SystemSelectorView_Previews: PreviewProvider {
    static var previews: some View {
		SystemSelectorView(BTClient())
    }
}

//
//  SystemSelectorView.swift
//  TrainConductor Watch App
//
//  Created by David Giovannini on 12/15/22.
//

import SwiftUI
import BTByJove
import Infrastructure

struct SystemSelectorView: View {
	@ObservedObject private var client: BTClient

	@State private var models: InfrastructureImpFactory = {
		InfrastructureImpFactory()
	}()

	init(_ client: BTClient) {
		self.client = client
	}

    var body: some View {
		NavigationStack {
			Group {
				if client.devices.isEmpty {
					Text("No systems found.")
				}
				else {
					List(client.devices) { device in
						let impl = models.implementation(for: device);
						let entry = InfrastructureEntry(device.id, impl)
						NavigationLink(value: entry) {
							HStack {
								impl.image
								Text(impl.name)
							}
						}
					}
				}
			}
			.onAppear() {
				client.scanning = true
			}
			.onDisappear() {
				client.scanning = false
			}
			.navigationDestination(for: InfrastructureEntry.self) { device in
				SystemDetailView(impl: device.impl)
					.padding(0)
					.ignoresSafeArea(edges: Edge.Set.all.subtracting(.top))
					.navigationTitle(device.impl.name)
					.onAppear() {
						device.impl.connect()
					}
					.onDisappear() {
						device.impl.disconnect()
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

//
//  FacilitiesListView.swift
//  TrainConductor Watch App
//
//  Created by David Giovannini on 12/15/22.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct FacilitiesListView: View {
	@ObservedObject private var client: BTClient
	private let facilities: FacilitiesFactory

	init(client: BTClient, facilities: FacilitiesFactory) {
		self.client = client
		self.facilities = facilities
	}

	var body: some View {
		NavigationStack {
			Group {
				if client.devices.isEmpty {
					Text("No facilities found.")
				}
				else {
					List(client.devices) { device in
						let facility = facilities.implementation(for: device)
						let entry = FacilityEntry(device.id, facility)
						NavigationLink(value: entry) {
							FacilityLineView(facility: facility)
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
			.navigationDestination(for: FacilityEntry.self) { device in
				FacilityDetailView(impl: device.facility)
					.navigationTitle(device.facility.name)
					.onAppear() {
						device.facility.connect()
					}
					.onDisappear() {
						device.facility.disconnect()
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					.ignoresSafeArea(edges: Edge.Set.all.subtracting(.top))
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
			}
		}
	}
}

#Preview {
	FacilitiesListView(client: .init(), facilities: .init())
}

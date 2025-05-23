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
	@ObservedObject var bluetooth: BTClient
	@ObservedObject var mDNS: MDNSClient
	let facilities: FacilitiesFactory

	var body: some View {
		NavigationStack {
			Group {
				if bluetooth.devices.isEmpty && mDNS.devices.isEmpty {
					Text("No facilities found.")
				}
				else {
					List(mDNS.devices) { device in
						let facilities = facilities.implementation(for: device)
						ForEach(facilities) { entry in
							NavigationLink(value: entry) {
								FacilityLineView(facility: entry.facility)
							}
						}
					}
					List(bluetooth.devices) { device in
						let facilities = facilities.implementation(for: device)
						ForEach(facilities) { entry in
							NavigationLink(value: entry) {
								FacilityLineView(facility: entry.facility)
							}
						}
					}
				}
			}
			.onAppear() {
				bluetooth.scanning = true
				mDNS.scanning = true
			}
			.onDisappear() {
				bluetooth.scanning = false
				mDNS.scanning = false
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
	FacilitiesListView(bluetooth: .init(), mDNS: .init(), facilities: .init())
}

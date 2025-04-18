//
//  FacilitiesListView.swift
//  JovesLanding
//
//  Created by David Giovannini on 7/9/21.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct FacilitiesListView: View {
	@ObservedObject var client: BTClient
	let facilities: FacilitiesFactory
	
	@State private var device: FacilityEntry?
	@State private var visibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView(columnVisibility: $visibility) {
			Group {
				if client.devices.isEmpty {
					Text("No facilities found.")
				}
				else {
					List(client.devices, selection: $device) { device in
						let facilities = facilities.implementation(for: device)
						ForEach(facilities) { entry in
							NavigationLink(value: entry) {
								FacilityLineView(facility: entry.facility)
							}
						}
					}
				}
			}
		}
		detail: {
			FacilityDetailView(impl: device?.facility)
				.toolbarBackground(Color.green.opacity(1.0), for: .navigationBar)
#if !os(tvOS)
				.navigationBarTitleDisplayMode(.inline)
#endif
		}
		.onChange(of: device) { [device] newValue in
			if device?.id != newValue?.id {
				newValue?.facility.connect()
			}
			visibility = newValue != nil ? .detailOnly : .all
		}
		.onLoad {
			client.scanning = true
		}
	}
}

#Preview {
	FacilitiesListView(client: .init(), facilities: .init())
}

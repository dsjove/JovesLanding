//
//  SystemSelectorView.swift
//  JovesLanding
//
//  Created by David Giovannini on 7/9/21.
//

import SwiftUI
import BTByJove
import Infrastructure

struct SystemSelectorView: View {
	@ObservedObject private var client: BTClient
	@State private var device: BTDevice?
	@State private var visibility: NavigationSplitViewVisibility = .all
	
	@State private var models: InfrastructureImpFactory = {
		InfrastructureImpFactory()
	}()

	init(_ client: BTClient) {
		self.client = client
	}
	
	var body: some View {
		NavigationSplitView(columnVisibility: $visibility) {
			Group {
				if client.devices.isEmpty {
					Text("No systems found.")
				}
				else {
					List(client.devices, selection: $device) { device in
						let _ = models.implementation(for: device)
						NavigationLink(device.name, value: device)
					}
				}
			}
		}
		detail: {
			SystemDetailView(impl: models.implementation(for: device))
		}
		.onChange(of: device) { [device] newValue in
			if device?.id != newValue?.id {
				newValue?.connect()
			}
			visibility = newValue != nil ? .detailOnly : .all
		}
		.onLoad {
			client.scanning = true;
		}
	}
}

struct SystemSelectorView_Previews: PreviewProvider {
	static var previews: some View {
		SystemSelectorView(BTClient())
	}
}

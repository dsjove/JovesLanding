//
//  SystemDetailView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/10/22.
//

import SwiftUI
import BTByJove
import Infrastructure

class ServiceImpFactory {
	private var impls: [UUID: Any] = [:]

	@MainActor
	func implementation(for device: BTDevice?) -> Any? {
		if let device {
			if let existing = impls[device.id] {
				return existing
			}
			if device.service == JoveMetroLine.Service {
				let impl = JoveMetroLine(device: device)
				impls[device.id] = impl
				return impl
			}
			if device.service == TheJoveExpress.Service {
				let impl = TheJoveExpress(device: device)
				impls[device.id] = impl
				return impl
			}
		}
		return nil
	}
}

struct SystemDetailView: View {
	let impl: Any?

	var body: some View {
		Group {
			if let impl {
				switch impl
				{
				case is TheJoveExpress:
					TheJoveExpressView(train: impl as! TheJoveExpress);
				case is JoveMetroLine:
					JoveMetroLineView(rail: impl as! JoveMetroLine)
				default:
					NotSupportedView(text: "Unsupported")
				}
			}
			else {
				NotSupportedView(text: "No system selected.")
			}
		}
	}
}

struct NotSupportedView: View {
	var text: String

	var body: some View {
		Text(text)
	}
}

struct SystemDetailView_Previews: PreviewProvider {
	static var previews: some View {
		SystemDetailView(impl: nil)
	}
}

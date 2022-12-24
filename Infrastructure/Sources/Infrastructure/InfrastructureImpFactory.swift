//
//  InfrastructureImpFactory.swift
//  
//
//  Created by David Giovannini on 12/24/22.
//

import SwiftUI
import BTByJove

public enum InfrastructureCategory {
	case transportation
}

public protocol InfrastructureImpl {
	var category: InfrastructureCategory { get async }
	var name: String { get async }
	var image: Image { get async }

	func connect() async

	func disconnect() async
}

public struct Unsupported: InfrastructureImpl {
	public let id = UUID()
	public let name: String
	public let category: Infrastructure.InfrastructureCategory = .transportation
	public let image: Image = Image(systemName: "questionmark.diamond")

	public func connect() async {}

	public func disconnect() async {}

	public func hash(into hasher: inout Hasher) {
		id.hash(into: &hasher)
	}
}

public class InfrastructureImpFactory {
	private var impls: [UUID: any InfrastructureImpl] = [:]

	public init() {
	}

	@MainActor
	public func implementation(for device: BTDevice?) -> (any InfrastructureImpl)? {
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
			return Unsupported(name: device.name)
		}
		return nil
	}
}

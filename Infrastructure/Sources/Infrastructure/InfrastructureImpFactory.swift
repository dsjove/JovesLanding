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

@MainActor
public protocol InfrastructureImpl {
	var category: InfrastructureCategory { get }
	var name: String { get }
	var image: Image { get }

	func connect()

	func disconnect()
}

@MainActor
public struct Unsupported: InfrastructureImpl {
	public let id = UUID()
	public let name: String
	public let category: Infrastructure.InfrastructureCategory = .transportation
	public let image: Image = Image(systemName: "questionmark.diamond")

	public func connect() {}

	public func disconnect() {}

	public func hash(into hasher: inout Hasher) {
		id.hash(into: &hasher)
	}
}

public struct InfrastructureEntry: Identifiable, Hashable {
	public let id: UUID
	public let impl: any InfrastructureImpl

	public init(_ id: UUID, _ impl: any InfrastructureImpl) {
		self.id = id
		self.impl = impl
	}

	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		id.hash(into: &hasher)
	}
}

public class InfrastructureImpFactory {
	private var impls: [UUID: any InfrastructureImpl] = [:]

	public init() {
	}

	@MainActor
	public func implementation(for device: BTDevice) -> any InfrastructureImpl {
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
}

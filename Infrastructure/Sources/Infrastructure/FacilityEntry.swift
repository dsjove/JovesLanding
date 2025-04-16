//
//  FacilityEntry.swift
//  JovesLanding
//
//  Created by David Giovannini on 3/26/25.
//

import SwiftUI
import Combine

public struct FacilityEntry: Identifiable, Hashable {
	public let id: UUID
	public let facility: any Facility

	public init(_ id: UUID, _ facility: any Facility) {
		self.id = id
		self.facility = facility
	}

	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		id.hash(into: &hasher)
	}
}

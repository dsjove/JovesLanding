//
//  FacilitiesFactory.swift
//  Infrastructure
//
//  Created by David Giovannini on 12/24/22.
//

import BLEByJove
import Foundation

public class FacilitiesFactory {
	private var facilities: [UUID: [FacilityEntry]] = [:]

	public init() {
	}

	public func implementation(for device: BTDevice) -> [FacilityEntry] {
		if let existing = facilities[device.id] {
			return existing
		}
		let newFacilities: [any Facility]
		switch device.service {
			case JoveMetroLine.Service:
				newFacilities = [JoveMetroLine(device: device)]
			case CityStreets.Service:
				newFacilities = [CityStreets(device: device)]
			case TheJoveExpress.Service:
				newFacilities = [TheJoveExpress(device: device)]
			default:
				newFacilities = [UnsupportedFacility(name: device.name)]
		}
		let entries = newFacilities.map { FacilityEntry($0) }
		facilities[device.id, default: []].append(contentsOf: entries)
		return facilities[device.id]!
	}
}

extension BTClient {
	private static var mocking: Bool {
		#if targetEnvironment(simulator)
			true
		#else
			false
		#endif
	}

	public static let services: [BTServiceIdentity] = {
		var base = [
			CircuitCube.Service,
			CityStreets.Service,
		//	LegoPoweredUp.Service,
		//	TheJoveExpress.Service,
		]
		if (mocking) {
			base.append(BTServiceIdentity(name: "Garbage"))
		}
		print(base.map { "\($0.name)=\($0.identifer.uuidString)"})
		return base
	}()

	public convenience init() {
		self.init(services: Self.services, mocking: Self.mocking)
	}
}

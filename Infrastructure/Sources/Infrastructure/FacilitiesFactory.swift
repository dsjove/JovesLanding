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
		if device.service == JoveMetroLine.Service {
			let facility = JoveMetroLine(device: device)
			let entry = FacilityEntry(device.id, facility)
			facilities[device.id, default: []].append(entry)
			return facilities[device.id]!
		}
		if device.service == CityStreets.Service {
			let facility = CityStreets(device: device)
			let entry = FacilityEntry(device.id, facility)
			facilities[device.id, default: []].append(entry)
			return facilities[device.id]!
		}
		if device.service == TheJoveExpress.Service {
			let facility = TheJoveExpress(device: device)
			let entry = FacilityEntry(device.id, facility)
			facilities[device.id, default: []].append(entry)
			return facilities[device.id]!
		}
		let facility = UnsupportedFacility(name: device.name)
		let entry = FacilityEntry(device.id, facility)
		return [entry]
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

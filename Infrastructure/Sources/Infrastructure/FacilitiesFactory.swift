//
//  FacilitiesFactory.swift
//  Infrastructure
//
//  Created by David Giovannini on 12/24/22.
//

import BLEByJove
import Foundation

public class FacilitiesFactory {
	private var facilities: [UUID: any Facility] = [:]

	public init() {
	}

	public func implementation(for device: BTDevice) -> any Facility {
		if let existing = facilities[device.id] {
			return existing
		}
		if device.service == JoveMetroLine.Service {
			let facility = JoveMetroLine(device: device)
			facilities[device.id] = facility
			return facility
		}
		if device.service == CityStreets.Service {
			let facility = CityStreets(device: device)
			facilities[device.id] = facility
			return facility
		}
		if device.service == TheJoveExpress.Service {
			let facility = TheJoveExpress(device: device)
			facilities[device.id] = facility
			return facility
		}
		return UnsupportedFacility(name: device.name)
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

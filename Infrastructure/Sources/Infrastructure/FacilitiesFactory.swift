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

	public func implementation(for device: any DeviceIdentifiable) -> [FacilityEntry] {
		if let existing = facilities[device.id] {
			return existing
		}
		let newFacilities: [any Facility]
		if let btDevice = device as? BTDevice {
			switch btDevice.service {
				case JoveMetroLine.Service:
					newFacilities = [JoveMetroLine(device: btDevice)]
				case CityStreets.Service:
					newFacilities = [CityStreets(device: btDevice)]
				case JoveExpress.Service:
					newFacilities = [JoveExpress(device: btDevice)]
				default:
					newFacilities = [UnsupportedFacility(name: btDevice.name)]
			}
		}
		else if let mDNSDevice = device as? MDNSDevice {
			switch mDNSDevice.service {
				case ESPCam.Service:
					newFacilities = [ESPCam(device: mDNSDevice)]
				default:
					newFacilities = [UnsupportedFacility(name: mDNSDevice.name)]
			}
		}
		else {
			newFacilities = [UnsupportedFacility(name: device.name)]
		}

		let entries = newFacilities.map { FacilityEntry($0) }
		facilities[device.id, default: []].append(contentsOf: entries)
		return facilities[device.id]!
	}
}

extension MDNSClient {
	private static var mocking: Bool {
		#if targetEnvironment(simulator)
			true
		#else
			false
		#endif
	}

	public static let services: [String] = {
		var base = [
			ESPCam.Service,
		]
		if (mocking) {
			base.append("Garbage")
		}
		print(base)
		return base
	}()
	
	public convenience init() {
		self.init(services: Self.services)
	}
}

extension BTClient {

	public static let services: [BTServiceIdentity] = {
		var base = [
			CircuitCube.Service,
			CityStreets.Service,
			JoveExpress.Service,
		]
		print(base.map { "\($0.name)=\($0.identifer.uuidString)"})
		return base
	}()

	public convenience init() {
		self.init(services: Self.services)
	}
}

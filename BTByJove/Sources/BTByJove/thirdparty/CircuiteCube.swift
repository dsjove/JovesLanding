//
//  CircuiteCube.swift
//  
//
//  Created by David Giovannini on 12/11/22.
//

import Foundation

public final class CircuiteCube {
	public static let Service = BTServiceIdentity(
		name: "Tenka",
		id: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")

	private struct Component: BTComponent {
		public let rawValue: UInt8 = 0x6e
		public init() {}
	}

	private struct Category: BTCategory {
		public let rawValue: UInt8 = 0x40
		public init() {}
	}

	private struct SubCategory: BTSubCategory {
		public let rawValue: UInt8 = 0x00
		public init() {}
	}

	private let device: BTDevice
	private let uart: BTUART

	public var id: UUID {
		device.id
	}

	public func connect() {
		device.connect()
	}

	public func disconnect() {
		device.disconnect()
	}

	public init(device: BTDevice) {
		self.device = device
		self.uart = BTUART(
			BTCharacteristicIdentity(
				component: Component(), Category(), SubCategory(), BTUARTChannel.tx),
			BTCharacteristicIdentity(
				component: Component(), Category(), SubCategory(), BTUARTChannel.rx),
			device);
	}
	
	public func battery() async -> Double? {
		let cmd = "b"
		return await uart.call(cmd.data(using: String.Encoding.ascii)) { data in
			if let str = String(data: data, encoding: String.Encoding.ascii) {
				if let value = Double(str) {
					return value / 4.2
				}
			}
			return nil
		}
	}

	public func name() async -> String {
		let cmd = "n?"
		let name = await uart.call(cmd.data(using: String.Encoding.ascii)) { data in
			return String(data: data, encoding: String.Encoding.ascii)
		}
		if let name {
			DispatchQueue.main.async {
				self.device.name = name
			}
			return name
		}
		return device.name
	}

	public func name(set name: String = "") async -> Bool {
		let cmd = "n\(name.safeName())\n"
		let success = await uart.call(cmd.data(using: String.Encoding.ascii)) { data in
			return (data.first ?? 1) == 0
		} ?? false
		if success {
			DispatchQueue.main.async {
				self.device.name = name
			}
		}
		return success
	}

	public enum Port: String {
		case a
		case b
		case c
	}

	public func power(set value: Int16, on port: Port, dropeKey: String? = nil) async {
		await power(set: [port : value], dropeKey: dropeKey)
	}

	public func power(set value: Int16, on ports: [Port], dropeKey: String? = nil) async {
		await power(set: ports.reduce([:]) {
			var a = $0
			a[$1] = value
			return a
		}, dropeKey: dropeKey)
	}

	public func power(set values: [Port: Int16], dropeKey: String? = nil) async {
		let cmd = values.reduce("") {
			let node = String(format: "%+04d\($1.key.rawValue)", $1.value.clamped(-255, 255))
			return $0 + node
		}
		await uart.call(cmd.data(using: String.Encoding.ascii), dropKey: dropeKey)
	}

	public func allOff() async -> Bool {
		let cmd = "0"
		return await uart.call(cmd.data(using: String.Encoding.ascii)) { data in
			return (data.first ?? 1) == 0
		} ?? false
	}
}

private extension String {
	func safeName() -> String {
		if self.isEmpty {
			return "Tenka"
		}
		let allowed = CharacterSet(charactersIn:
			"_-0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
		let safe = String(self.unicodeScalars.filter { allowed.contains($0) })
		return String(safe.prefix(20))
	}
}

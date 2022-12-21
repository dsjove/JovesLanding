//
//  BTServiceIdentity.swift
//  BTByJove
//
//  Created by David Giovannini on 7/4/21.
//

import Foundation
import CoreBluetooth

public protocol BTComponent: CustomStringConvertible {
	var rawValue: UInt8 { get }
}

public extension BTComponent {
	var bitValue: UInt32 {
		UInt32(rawValue) << 24
	}
	
	var description: String {
		rawValue.description
	}
}

public struct MainComponent: BTComponent {
	public let rawValue: UInt8 = 1
	public init() {}
}

public protocol BTCategory: CustomStringConvertible {
	var rawValue: UInt8 { get }
}

public extension BTCategory {
	var bitValue: UInt32 {
		UInt32(rawValue) << 16
	}
	
	var description: String {
		rawValue.description
	}
}

public protocol BTSubCategory: CustomStringConvertible {
	var rawValue: UInt8 { get }
}

public extension BTSubCategory {
	var bitValue: UInt32 {
		UInt32(rawValue) << 8
	}
	
	var description: String {
		rawValue.description
	}
}

public protocol BTChannel: CustomStringConvertible {
	var rawValue: UInt8 { get }
}

public extension BTChannel {
	var bitValue: UInt32 {
		UInt32(rawValue) << 0
	}

	var description: String {
		rawValue.description
	}
}

public enum BTPropChannel: UInt8, BTChannel {
	case property = 0
	case control = 1
	case feedback = 2
	
	public var description: String {
		switch self {
		case .property:
			return "P"
		case .control:
			return "C"
		case .feedback:
			return "F"
		}
	}
}

public enum BTUARTChannel: UInt8, BTChannel {
	case tx = 2
	case rx = 3

	public var description: String {
		switch self {
		case .tx:
			return "TX"
		case .rx:
			return "RX"
		}
	}
}

public struct BTCharacteristicIdentity: Hashable, CustomStringConvertible {
	public let component: BTComponent
	public let category: BTCategory
	public let subCategory: BTSubCategory
	public let channel: BTChannel
	public let bitValue: UInt32
	
	public init(component: BTComponent = MainComponent(), _ category: BTCategory, _ subCategory: BTSubCategory, _ channel: BTChannel = BTPropChannel.property) {
		self.component = component
		self.category = category
		self.subCategory = subCategory
		self.channel = channel
		self.bitValue = (component.bitValue | category.bitValue | subCategory.bitValue | channel.bitValue).bigEndian
	}
	
	public func apply(channel: BTChannel) -> BTCharacteristicIdentity {
		BTCharacteristicIdentity(category, subCategory, channel)
	}
	
	public static func == (lhs: BTCharacteristicIdentity, rhs: BTCharacteristicIdentity) -> Bool {
		rhs.bitValue == lhs.bitValue
	}
	
	public func hash(into hasher: inout Hasher) {
		bitValue.hash(into: &hasher)
	}
	
	public var description: String {
		"\(self.category).\(self.subCategory)[\(self.channel)]"
	}
}

public struct BTServiceIdentity: CustomStringConvertible, Hashable {
	public let name: String

	public init(name: String) {
		let base: Data = CBUUID(string: "00000000-0000-1000-8000-008000000000").data
		self.name = name
		var data = base
		let normalized = name.prefix(4).padding(toLength: 4, withPad: " ", startingAt: 0).data(using: .ascii)!
		data.replaceSubrange(12...15, with: normalized)
		self.identifer = CBUUID(data: data)
	}

	public init(name: String, id: String) {
		self.name = name;
		self.identifer = CBUUID(string: id);
	}

	public init(name: String, id: UUID) {
		self.name = name;
		let cbid = CBUUID(nsuuid: id);
		self.identifer = cbid;
	}
	
	public let identifer: CBUUID
	
	public var description: String {
		name
	}

	public func characteristic(characteristic: BTCharacteristicIdentity) -> CBUUID {
		var data = identifer.data
		let code = characteristic.bitValue
		withUnsafePointer(to: code) { address in
			data.replaceSubrange(0..<4, with: address, count: 4)
		}
		return CBUUID(data: data)
	}
}

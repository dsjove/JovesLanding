//
//  BTBroadcaster.swift
//  BTByJove
//
//  Created by David Giovannini on 7/4/21.
//

import Foundation
import Combine

public enum BTBroadcasterWriteResponse {
	case notSent
	case sentOnly
	case reponseReceived
	case error(Error)
}

public protocol BTBroadcaster: AnyObject {
	func send(data: Data, to value: BTCharacteristicIdentity, confirmed: ((BTBroadcasterWriteResponse)->())?)
	
	func request(value: BTCharacteristicIdentity)
	
	func read(value: BTCharacteristicIdentity) -> Data?
	
	func sink(id: CombineIdentifier, to characteristic: BTCharacteristicIdentity, with: @escaping (Data)->()) -> AnyCancellable
}

extension BTBroadcaster {
	public func send(data: Data, to value: BTCharacteristicIdentity) {
		self.send(data: data, to: value, confirmed: nil)
	}
}

public final class NullBTBroadcaster: BTBroadcaster {
	public init() {}

	public func send(data: Data, to value: BTCharacteristicIdentity, confirmed: ((BTBroadcasterWriteResponse)->())?) {
	}
	
	public func request(value: BTCharacteristicIdentity) {
	}
	
	public func read(value: BTCharacteristicIdentity) -> Data? {
		nil
	}
	
	public func sink(id: CombineIdentifier, to characteristic: BTCharacteristicIdentity, with: @escaping (Data) -> ()) -> AnyCancellable {
		AnyCancellable({})
	}
}

public protocol BTControl: AnyObject {
	var connected: Bool { get }
	func connect()
	func disconnect()
}

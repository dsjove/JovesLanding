//
//  BTUART.swift
//  BTByJove
//
//  Created by David Giovannini on 12/5/22.
//

import Foundation
import Combine
import Collections

public final actor BTUART {
	public let id = CombineIdentifier()
	private let controlChar: BTCharacteristicIdentity
	private let feedbackChar: BTCharacteristicIdentity
	private let broadcaster: BTBroadcaster
	private var sink: AnyCancellable?
	private var keyFactory: Int = 0

	private var queue: OrderedDictionary<Int, (Data, ((Data?)->())?, String?)> = [:]

	public init(_ controlChar: BTCharacteristicIdentity, _ feedbackChar: BTCharacteristicIdentity, _ broadcaster: BTBroadcaster) {
		self.feedbackChar = feedbackChar
		self.controlChar = controlChar
		self.broadcaster = broadcaster
		self.sink = broadcaster.sink(id: id, to: feedbackChar) { data in
			Task { await
				self.receiveFeedback(data)
			}
		}
	}

	public func call<T>(_ data: Data?, dropKey: String? = nil, _ parse: (Data)->T?) async -> T? {
		if let data, data.isEmpty == false {
			let response = await withCheckedContinuation { continuation in
				call(data, dropKey: dropKey) { data in
					return continuation.resume(with: .success(data))
				}
			}
			if let response {
				if let value = parse(response) {
					return value
				}
			}
		}
		return nil
	}

	public func call(_ data: Data?, dropKey: String? = nil, response: ((Data?)->())? = nil) {
		if let data, data.isEmpty == false {
			if let dropKey {
				for element in queue {
					if element.value.2 == dropKey {
						if (queue.index(forKey: element.key) != 0) {
							element.value.1?(nil) //timeout
							queue[element.key] = (data, response, dropKey)
							return
						}
					}
				}
			}
			keyFactory += 1
			let key = keyFactory
			queue[key] = (data, response, dropKey)
			if queue.count == 1 {
				broadcast(key, data, response)
			}
		}
		else {
			response?(nil)
		}
	}

	private func broadcast(_ key: Int, _ data: Data, _ response: ((Data?)->())?) {
		DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
			Task { await
				self.receiveTimout(key)
			}
		}
		broadcaster.send(data: data, to: controlChar, confirmed: { _ in })
	}

	private func receiveFeedback(_ data: Data?) {
		if queue.isEmpty == false {
			let finalied = queue.removeFirst().value
			finalied.1?(data)
		}
		if queue.isEmpty == false {
			let next = queue.elements[0]
			broadcast(next.key, next.value.0, next.value.1)
		}
	}

	private func receiveTimout(_ key: Int) {
		if let finalied = self.queue[key] {
			let idx = self.queue.index(forKey: key)
			self.queue.removeValue(forKey: key)
			finalied.1?(nil)
			if ( idx == 0 && queue.isEmpty == false)
			{
				let next = queue.elements[0]
				broadcast(next.key, next.value.0, next.value.1)
			}
		}
	}
}

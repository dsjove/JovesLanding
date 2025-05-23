//
//  JoveMetroLine.swift
//  Infrastructure
//
//  Created by David Giovannini on 12/4/22.
//

import Foundation
import Combine
import BLEByJove
import SwiftUI

public class JoveMetroLine: ObservableObject, MotorizedFacility {
	public static let Service = CircuitCube.Service
	public let id: UUID
	private let cube: CircuitCube
	private var sink: Set<AnyCancellable> = []
	private var beatCheck: Cancellable = AnyCancellable({})

	public let heartBeatSpec : (delay: Int, interval: Int) = (1000, 30)

	public convenience init() {
		self.init(device: .init(preview: "Sample"))
	}

	public init(device: BTDevice) {
		self.id = device.id
		self.cube = CircuitCube(device: device)
		self.connectionState = device.connectionState
		self.name = device.name
		self.battery = -1
		self.motor = CCMotor(cube: cube)
		self.lighting = CCLighting(cube: cube)

		device.$connectionState.dropFirst().sink { [weak self] in
			self?.connectionState = $0
		}.store(in: &sink)

		device.$name.sink { [weak self] in
			self?.name = $0
		}.store(in: &sink)
	}

	deinit {
		self.beatCheck.cancel()
	}

	public var category: FacilityCategory { .transportation }
	public var image: Image { Image(systemName: "lightrail") }

	@Published
	public private(set) var name: String

	public func change(name: String) {
		if name != self.name {
			Task {
				await cube.name(set: name)
			}
		}
	}

	@Published
	public private(set) var connectionState: ConnectionState {
		didSet {
			switch connectionState {
				case .connected:
					Task {
						await cube.name()
					}
					self.startHeartBeat()
				case .connecting:
					break
				case .disconnected:
					reset()
				break
			}
		}
	}

	@Published
	public private(set) var battery: Double?

	@Published
	public var motor: CCMotor

	@Published
	public var lighting: CCLighting

	public func fullStop() {
		motor.fullStop()
		lighting.fullStop()
	}

	public func connect() {
		Task {
			await cube.connect()
		}
	}

	public func disconnect() {
		Task {
			await cube.disconnect()
		}
	}

	@MainActor
	private func updateBattery() async {
		let b = await cube.battery()
		DispatchQueue.main.async {
			self.battery = b
		}
	}

	private func reset() {
		self.lighting.reset()
		self.motor.reset()
		self.beatCheck.cancel()
		self.heartBeat = -1
		self.battery = -1
	}

	@Published private(set) public var heartBeat: Int = -1 {
		didSet {
			if self.heartBeat > -1 {
				Task {
					await updateBattery()
				}
			}
		}
	}

	private func connectionStateChanged(connectionState: ConnectionState) {
		switch connectionState {
			case .connected:
				startHeartBeat()
			case .connecting:
				break
			case .disconnected:
				reset()
		}
	}

	private func startHeartBeat() {
		let (heartBeatInit, heartBeatInterval) = heartBeatSpec
		if heartBeatInit > 0 {
			if heartBeatInterval > 0 {
				self.beatCheck = DispatchQueue.main.schedule(
					after: DispatchQueue.SchedulerTimeType(.now() + .milliseconds(heartBeatInit)),
					interval: DispatchQueue.SchedulerTimeType.Stride(.seconds(heartBeatInterval))) { [weak self] in
							self?.heartBeat += 1
					}
			}
			else {
				DispatchQueue.main.schedule(
					after: DispatchQueue.SchedulerTimeType(.now() + .milliseconds(heartBeatInit))) { [weak self] in
							self?.heartBeat = 0
					}
			}
		}
	}
}

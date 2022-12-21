//
//  JoveMetroLine.swift
//  The Jove Express
//
//  Created by David Giovannini on 12/4/22.
//

import Foundation
import Combine
import BTByJove

@MainActor
public class JoveMetroLine: ObservableObject {
	public static let Service = CircuiteCube.Service
	private let cube: CircuiteCube
	private var sink: Set<AnyCancellable> = []
	private var beatCheck: Cancellable = AnyCancellable({})
	private var realPower: Int16
	private var realLights: Int16

	public init(device: BTDevice) {
		self.cube = CircuiteCube(device: device)
		self.name = device.name
		self.connectionState = .disconneted
		self.battery = nil
		self.power = 0.0
		self.realPower = 0
		self.calibration = 0.25
		self.lights = 0.0
		self.realLights = 0
		self.motorState = .idle

		device.$connected.sink { [weak self] in
			self?.connectionState = $0 ? .connected : .disconneted
		}.store(in: &sink)
	}

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
			guard oldValue != connectionState else {
				return
			}
			self.stateChange(oldValue)
		}
	}

	@Published
	public private(set) var battery: Double?

	@Published
	public var power: Double {
		didSet {
			applyPower()
		}
	}

	@Published
	public var calibration: Double {
		didSet {
			applyPower()
		}
	}

	public func fullStop() {
		self.power = 0.0
		self.lights = 0.0
		Task {
			await cube.allOff()
		}
	}

	@Published
	public private(set) var motorState: MotorState

	private func applyPower() {
		var powerRatio = power
		let calibrationRatio = calibration
		if powerRatio < 0 && powerRatio > -calibrationRatio {
			powerRatio = 0;
		}
		else if powerRatio > 0 && powerRatio < calibrationRatio {
			powerRatio = 0
		}
		let testPower = Int16(powerRatio * 255.0).clamped(-255, 255)
		motorState = MotorState(power: testPower)
		if (testPower != realPower) {
			realPower = testPower
			Task {
				await cube.power(set: testPower, on: .a, dropeKey: "motor")
			}
		}
	}

	@Published
	public var lights: Double {
		didSet {
			applyLights()
		}
	}

	private func applyLights() {
		let lightsRatio = lights
		let testLights = Int16(lightsRatio * 255.0).clamped(-255, 255)
		if (testLights != realLights) {
			realLights = testLights
			Task {
				await cube.power(set: testLights, on: [.b, .c], dropeKey: "lights")
			}
		}
	}

	public func connect() {
		self.connectionState = .connecting
		cube.connect()
	}

	public func disconnect() {
		cube.disconnect()
	}

	private func updateBattery() async {
		let result = await cube.battery()
		self.battery = result
	}

	private func updateName() async {
		self.name = await cube.name()
	}

	private func reset() {
		self.battery = nil
		self.power = 0.0
		self.calibration = 0.25
		self.lights = 0.0
	}

	private func stateChange(_ oldValue: ConnectionState) {
		switch connectionState {
		case .disconneted:
			reset()
		case .connecting:
			break
		case .connected:
			heartBeat()
		}
	}

	private func heartBeat() {
		self.beatCheck.cancel()
		self.beatCheck = DispatchQueue.main.schedule(
			after: DispatchQueue.SchedulerTimeType(.now() + .milliseconds(1000)),
			interval: DispatchQueue.SchedulerTimeType.Stride(.seconds(30)))  {
				Task { [weak self] in
					if let self {
						_ = await self.updateBattery()
					}
				}
			}
	}
}

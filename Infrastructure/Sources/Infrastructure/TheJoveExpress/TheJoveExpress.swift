//
//  TheJoveExpress.swift
//  The Jove Express
//
//  Created by David Giovannini on 7/9/21.
//

import Foundation
import Combine
import SwiftUI
import BTByJove

//FUTURE:
//Sound

public enum TrainCategory: UInt8, BTCategory {
	case train = 0
	case engine = 1
	case lights = 2
	case heart = 3
	case motion = 4
	case camera = 5
	case display = 6
	case sound = 7
	
	public var description: String {
		switch self {
		case .train:
			return "train"
		case .engine:
			return "engine"
		case .lights:
			return "lights"
		case .heart:
			return "heart"
		case .motion:
			return "motion"
		case .camera:
			return "camera"
		case .display:
			return "display"
		case .sound:
			return "sound"
		}
	}
}

public enum TrainPower: UInt8, BTSubCategory {
	case calibration = 0
	case power = 1
	case state = 2
	case sensed = 3
	
	public var description: String {
		switch self {
		case .calibration:
			return "calibration"
		case .power:
			return "power"
		case .state:
			return "state"
		case .sensed:
			return "sensed"
		}
	}
}

extension TheJoveExpress: InfrastructureImpl {
	public var category: InfrastructureCategory { .transportation }
	public var image: Image { Image(systemName: "Train") }
	public var name: String { name2.feedback }
}

public class TheJoveExpress: ObservableObject {
	public static let Service = BTServiceIdentity(name: "TJEx");
	
	private let device: BTBroadcaster & BTControl
	private var sink: Set<AnyCancellable> = []

	@Published public private(set) var state: ConnectionState {
		didSet {
			guard oldValue != state else {
				return
			}
			self.stateChange(oldValue)
		}
	}

	public var name2: BTSubject<String>
	public var heart: Heart
	public var engine: Engine
	public var lights: Lights
	public var motion: Motion
	public var camera: Camera
	public var display: Display
	public var sound: Sound
	
	private var beatCheck: Timer?
	private var beatTime: Date?

	public init(device: BTDevice) {
		self.device = device
		self.state = .disconneted
		
		self.name2 = BTSubject(
			BTCharacteristicIdentity(TrainCategory.train, TrainPower.calibration),
			device,
			device.name)

		self.heart = Heart(broadcaster: device)
		self.engine = Engine(broadcaster: device)
		self.lights = Lights(broadcaster: device)
		self.motion = Motion(broadcaster: device)
		self.camera = Camera(broadcaster: device)
		self.display = Display(broadcaster: device)
		self.sound = Sound(broadcaster: device)

		device.$connected.sink { [weak self] in
			self?.state = $0 ? .connected : .disconneted
		}.store(in: &sink)
		
		self.heart.beat.$feedback.sink { [weak self] _ in
			self?.beatTime = Date()
		}.store(in: &sink)
	}

	deinit {
		self.beatCheck?.invalidate()
	}

	public func connect() {
		self.state = .connecting
		device.connect()
	}

	public func disconnect() {
		device.disconnect()
		self.reset()
	}
	
	public func reset() {
		name2.reset()
		heart.reset()
		engine.reset()
		lights.reset()
		motion.reset()
		camera.reset()
		display.reset()
		sound.reset()
	}
	
	private func stateChange(_ oldValue: ConnectionState) {
		switch state {
		case .disconneted:
			self.reset()
			self.beatCheck?.invalidate()
			self.beatCheck = nil
			self.beatTime = nil
		case .connecting:
			break
		case .connected:
			self.beatTime = Date()
			self.beatCheck?.invalidate()
			self.beatCheck = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
				if let self = self {
					if self.beatTime!.timeIntervalSinceNow < -5.0 {
						//self.state = .dead
					}
				}
			}
		}
	}
}

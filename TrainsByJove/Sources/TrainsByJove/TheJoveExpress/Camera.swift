//
//  Camera.swift
//  The Jove Express
//
//  Created by David Giovannini on 7/15/21.
//

import Foundation
import BTByJove

public enum CameraFPS: UInt8, FogExternalizable, CaseIterable, Hashable {
	case fps6 = 6
	case fps12 = 12
	case fps24 = 24
	case fps48 = 48
}

public struct Camera {
	public var fps: BTSubject<CameraFPS>
	public var power: BTSubject<Bool>
	public var url: BTSubject<FogIPAddress>
	
	public init(broadcaster: BTBroadcaster) {
		self.fps = BTSubject(
			BTCharacteristicIdentity(TrainCategory.camera, TrainPower.calibration),
			broadcaster,
			.fps6)
		self.power = BTSubject(
			BTCharacteristicIdentity(TrainCategory.camera, TrainPower.power),
			broadcaster,
			false)
		self.url = BTSubject(
			BTCharacteristicIdentity(TrainCategory.camera, TrainPower.state),
			broadcaster,
			FogIPAddress())
	}
	
	public func reset() {
		fps.reset()
		power.reset()
		url.reset()
	}
}

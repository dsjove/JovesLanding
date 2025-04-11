//
//  MotorState.swift
//  Infrastructure
//
//  Created by David Giovannini on 12/15/22.
//

import Foundation

public enum MotorState: String, CaseIterable {
	case reverse
	case idle
	case forward

	public init<T: Comparable & ExpressibleByIntegerLiteral>(power: T) {
		if power == 0 {
			self = .idle
		}
		else if power > 0 {
			self = .forward
		}
		else {
			self = .reverse
		}
	}
}

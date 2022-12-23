//
//  MotorState.swift
//  
//
//  Created by David Giovannini on 12/15/22.
//

import Foundation

public enum MotorState: Int8 {
	case reverse = -1
	case idle = 0
	case forward = 1

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

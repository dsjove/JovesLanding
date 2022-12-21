//
//  GaugeView.State+.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import TrainsByJove

extension GaugeView.State {
	static func rail() -> GaugeView.State {
		var state = GaugeView.State()
		state.values = [0]
		state.minMax = -100...100
		state.majorMod = 25
		state.minorMod = 5
		state.angles = 210...510
		state.ranges = [
			GaugeView.State.GRange(values: 0 ... 0, color: Color("Motor/Idle"), label: "Idle"),
			GaugeView.State.GRange(values: -100 ... 0, color: Color("Motor/Reverse"), label: "Reverse"),
			GaugeView.State.GRange(values: 0 ... 100, color: Color("Motor/Forward"), label: "Forward"),
		]
		return state
	}

	static func lights() -> GaugeView.State {
		var state = GaugeView.State()
		state.values = [0]
		state.minMax = 0...256
		state.majorMod = 32
		state.minorMod = 4
		state.angles = 210...510
		state.indicators?.light = 0.0
		state.ranges = [
			GaugeView.State.GRange(values: -100 ... 0, color: Color("Lights/Off"), label: "Dark"),
			GaugeView.State.GRange(values: 0 ... 0, color: Color("Lighst/On"), label: "Light"),
		]
		return state
	}
}

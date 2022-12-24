//
//  GaugeView.State+.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import Infrastructure

struct Indicators {
	var connectionState: ConnectionState = .disconneted
	var motorState: MotorState = .idle
	var battery: Double? = nil
	var light: Double = 0.0
}

struct IndicatorView: View {
	let geom: Gauge.Geometry
	var indicators: Indicators
	let width: Double

	var body: some View {
		let width = geom.width(width)

		MotorIndicatorView(motorState: indicators.motorState)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		LightIndicatorView(on: indicators.light)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		ConnectionIndicatorView(connectionState: indicators.connectionState)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		BatteryIndicatorView(progress: indicators.battery)
			.indicator(padding: width * 0.15)
			.frame(width: width)
	}
}

extension Gauge.GState {
	static func rail() -> Gauge.GState {
		var state = Gauge.GState()
		state.values = [0]
		state.minMax = -100...100
		state.angles = 210...510
		state.ranges = [
			Gauge.GRange(values: 0 ... 0, color: Color("Motor/Idle"), label: "Idle"),
			Gauge.GRange(values: -100 ... 0, color: Color("Motor/Reverse"), label: "Reverse"),
			Gauge.GRange(values: 0 ... 100, color: Color("Motor/Forward"), label: "Forward"),
		]
		state.ticks = [
			Gauge.GTick(increment: 5, thickness: 0.008, transform: { _ in nil }, draw:  { i, v, _ in
				((i + 5) % 5) != 0
			}),
			Gauge.GTick(increment: 25, innerRadius: 0.820, transform: { _ in nil }),
			Gauge.GTick(increment: 25, outerRadius: 0.820, innerRadius: 0.700, thickness: 0.000),
		]
		return state
	}

	static func lights() -> Gauge.GState {
		var state = Gauge.GState()
		state.values = [0]
		state.minMax = 0...256
		//state.majorMod = 32
		//state.minorMod = 4
		state.angles = 210...510
		state.ranges = [
			Gauge.GRange(values: -100 ... 0, color: Color("Lights/Off"), label: "Dark"),
			Gauge.GRange(values: 0 ... 0, color: Color("Lighst/On"), label: "Light"),
		]
		return state
	}
}

//
//  GaugeView.State+.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import Infrastructure

struct Indicators {
	var image: Image
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

		MotorIndicatorView(image: indicators.image, motorState: indicators.motorState)
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

extension Gauge.Model {
	static func rail() -> Gauge.Model {
		var model = Gauge.Model()
		model.values = [0]
		model.minMax = -100...100
		model.angles = 210...510
		model.ranges = [
			Gauge.Range(values: 0 ... 0, color: Color("Motor/Idle"), label: "Idle"),
			Gauge.Range(values: -100 ... 0, color: Color("Motor/Reverse"), label: "Reverse"),
			Gauge.Range(values: 0 ... 100, color: Color("Motor/Forward"), label: "Forward"),
		]
		model.ticks = [
			Gauge.Tick(increment: 5, thickness: 0.008, transform: { _ in nil }, draw:  { i, v, _ in
				((i + 5) % 5) != 0
			}),
			Gauge.Tick(increment: 25, innerRadius: 0.820, transform: { _ in nil }),
			Gauge.Tick(increment: 25, outerRadius: 0.820, innerRadius: 0.680, thickness: 0.000),
		]
		return model
	}

	static func lights() -> Gauge.Model {
		var model = Gauge.Model()
		model.values = [0]
		model.minMax = 0...256
		model.angles = 210...510
		model.ranges = [
			Gauge.Range(values: -100 ... 0, color: Color("Lights/Off"), label: "Dark"),
			Gauge.Range(values: 0 ... 0, color: Color("Lighst/On"), label: "Light"),
		]
		return model
	}
}

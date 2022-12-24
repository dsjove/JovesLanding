//
//  JoveMetroLineGauageView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import Infrastructure

struct JoveMetroLineGauageView : View {
	@ObservedObject var rail: JoveMetroLine
	@State var gaugeState: Gauge.GState
	@State var indicators: Indicators

    init(rail: JoveMetroLine) {
		self.rail = rail
		_gaugeState = State(initialValue: {
			var state = Gauge.GState.rail()
			state.values[0] = rail.power * 100.0
			let c = rail.calibration * 100.0
			state.ranges[0].values = -c ... c
			state.ranges[1].values = -100 ... -c
			state.ranges[2].values = c ... 100
			return state
		}())
		_indicators = State(initialValue: {
			var indicators = Indicators()
			indicators.battery = rail.battery
			indicators.light = rail.lights
			indicators.motorState = rail.motorState
			indicators.connectionState = rail.connectionState
			return indicators
		}())
	}
	
	var body: some View {
		Gauge.GView(state: gaugeState) { geom, state in
			Gauge.standard(geom: geom, state: state, indicators: { _, _, w in
				IndicatorView(geom: geom, indicators: indicators, width: w)
			})
		}
		.onChange(of: rail.power) { newValue in
			gaugeState.values[0] = newValue * 100.0
		}
		.onChange(of: rail.calibration) { newValue in
			let c = newValue * 100.0
			gaugeState.ranges[0].values = -c ... c
			gaugeState.ranges[1].values = -100 ... -c
			gaugeState.ranges[2].values = c ... 100
		}
		.onChange(of: rail.motorState) { newValue in
			indicators.motorState = newValue
		}
		.onChange(of: rail.battery) { newValue in
			indicators.battery = newValue
		}
		.onChange(of: rail.lights) { newValue in
			indicators.light = newValue
		}
		.onChange(of: rail.connectionState) { newValue in
			indicators.connectionState = newValue
		}
	}
}

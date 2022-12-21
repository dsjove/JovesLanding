//
//  JoveMetroLineGauageView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import TrainsByJove

struct JoveMetroLineGauageView : View {
	@ObservedObject var rail: JoveMetroLine
	@State var gaugeState: GaugeView.State

    init(rail: JoveMetroLine) {
		self.rail = rail
		_gaugeState = State(initialValue: {
			var state = GaugeView.State.rail()
			state.values[0] = rail.power * 100.0
			state.indicators = Indicators()
			state.indicators?.battery = rail.battery
			state.indicators?.light = rail.lights
			state.indicators?.motorState = rail.motorState
			state.indicators?.connectionState = rail.connectionState
			let c = rail.calibration * 100.0
			state.ranges[0].values = -c ... c
			state.ranges[1].values = -100 ... -c
			state.ranges[2].values = c ... 100
			return state
		}())
	}
	
	var body: some View {
		GaugeView(state: gaugeState)
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
				gaugeState.indicators?.motorState = newValue
			}
			.onChange(of: rail.battery) { newValue in
				gaugeState.indicators?.battery = newValue
			}
			.onChange(of: rail.lights) { newValue in
				gaugeState.indicators?.light = newValue
			}
			.onChange(of: rail.connectionState) { newValue in
				gaugeState.indicators?.connectionState = newValue
			}
	}
}

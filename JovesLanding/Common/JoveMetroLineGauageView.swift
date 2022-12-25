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
	@State var gaugeModel: Gauge.Model
	@State var indicators: Indicators

    init(rail: JoveMetroLine) {
		self.rail = rail
		_gaugeModel = State(initialValue: {
			var model = Gauge.Model.rail()
			model.values[0] = rail.power * 100.0
			let c = rail.calibration * 100.0
			model.ranges[0].values = -c ... c
			model.ranges[1].values = -100 ... -c
			model.ranges[2].values = c ... 100
			return model
		}())
		_indicators = State(initialValue: {
			var indicators = Indicators(image: rail.image)
			indicators.battery = rail.battery
			indicators.light = rail.lights
			indicators.motorState = rail.motorState
			indicators.connectionState = rail.connectionState
			return indicators
		}())
	}
	
	var body: some View {
		Gauge.Container(model: gaugeModel) { geom, model in
			Gauge.standard(geom: geom, model: model, indicators: { _, _, w in
				IndicatorView(geom: geom, indicators: indicators, width: w)
			})
		}
		.onChange(of: rail.power) { newValue in
			gaugeModel.values[0] = newValue * 100.0
		}
		.onChange(of: rail.calibration) { newValue in
			let c = newValue * 100.0
			gaugeModel.ranges[0].values = -c ... c
			gaugeModel.ranges[1].values = -100 ... -c
			gaugeModel.ranges[2].values = c ... 100
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

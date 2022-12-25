//
//  EngineView.swift
//  JovesLanding
//
//  Created by David Giovannini on 7/9/21.
//

import SwiftUI
import BTByJove
import Infrastructure

struct EngineView: View {
	@ObservedObject var calibration: BTSubject<EngineRational>
	@ObservedObject var power: BTSubject<EngineRational>
	@State var gaugeModel: Gauge.Model
	
	init(_ engine: Engine) {
		self._calibration = ObservedObject(initialValue: engine.calibration)
		self._power = ObservedObject(initialValue: engine.power)
		_gaugeModel = State(initialValue: Gauge.Model.rail())
	}
	
    var body: some View {
		VStack(alignment: .center, spacing: 12) {
		Gauge.Container(model: gaugeModel) { geom, model in
			Gauge.standard(geom: geom, model: model)
		}
			/*
				.onChange(of: rail.power) { newValue in
					gaugeValues.value = newValue.ratio * 100.0
				}
				.onChange(of: rail.calibration) { newValue in
					let c = newValue.ratio * 100.0
					gaugeValues.ranges[0].values = -100 ... -c
					gaugeValues.ranges[1].values = -c ... c
					gaugeValues.ranges[2].values = c ... 100
				}
				.onChange(of: rail.motorState) { newValue in
					gaugeValues.image = newValue.imageName
				}

			RationalSlider(hasNegative: true, value: $power.control, thumbColor: Color.gray, minTrackColor: Color.red, maxTrackColor: Color.green)
			Text("Speed").multilineTextAlignment(.center)
			RationalSlider(hasNegative: false, value: $calibration.control, thumbColor: Color.gray, minTrackColor: Color.yellow, maxTrackColor: Color.red)
			*/
			Text("Idle Threshold").multilineTextAlignment(.center)
		}
	}
}

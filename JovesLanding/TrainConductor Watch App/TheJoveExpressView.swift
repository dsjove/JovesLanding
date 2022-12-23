//
//  TheJoveExpressView.swift
//  TrainConductor
//
//  Created by David Giovannini on 7/15/21.
//

import SwiftUI
import BTByJove
import Infrastructure

struct TheJoveExpressView: View {
	@ObservedObject private var train: TheJoveExpress
	@ObservedObject private var name: BTSubject<String>
	@ObservedObject private var lightsPower: BTSubject<LightCommand>
	@ObservedObject private var lightsState: BTSubject<Bool>
	@ObservedObject private var enginePower: BTSubject<EngineRational>
	
	@State private var crown = Int16()

	init(train: TheJoveExpress) {
		self.train = train
		self.name = train.name
		self.lightsPower = train.lights.power
		self.lightsState = train.lights.state
		self.enginePower = train.engine.power
	}

	var body: some View {
		Group {
/*
			VStack {
				HStack {
					BatteryView(progress: 0.5, fill: .green, text: .black, outline: .black)
						.frame(width: 75)
					Image(lightsState.feedback ? "TorchOn" : "TorchOff")
						.resizable()
						.aspectRatio(contentMode: .fit)
					Image(uiImage: MotorState(power: enginePower.feedback.num).image)
						.resizable()
						.aspectRatio(contentMode: .fit)
				}
				Text(enginePower.control.num.description).font(.title)
				HStack(spacing: 14) {
					ForEach(LightCommand.allCases, id: \.self) { option in
						Button {
							self.lightsPower.control = option
						} label: {
							Text(option.symbol)
						}
						.cornerRadius(4.0)
						.overlay(Circle()
							.stroke(self.lightsPower.control == option ?
								Color.black.opacity(0.75) : Color.clear, lineWidth: 2.0)
						)
						.aspectRatio(1.0, contentMode: .fit)
					}
				}
				Spacer()
			}*/
		}
		.focusable(true)
		.digitalCrownRotation(
			detent: $crown, from: -256, through: 256, by: 1,
			sensitivity: .high, isContinuous: false,
			 isHapticFeedbackEnabled: true,
			 onChange: { _ in }, onIdle: {})
		.onChange(of: crown) { newValue in
			//rail.power = Double(newValue) / 256.0
		}
	}
}

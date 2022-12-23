//
//  SuspensionRailView.swift
//  TrainConductor
//
//  Created by David Giovannini on 12/5/22.
//

import SwiftUI
import BTByJove
import Infrastructure

struct JoveMetroLineView: View {
	@ObservedObject private var rail: JoveMetroLine
	@State private var crown = Int()

	init(rail: JoveMetroLine) {
		self.rail = rail
	}

	var body: some View {
		JoveMetroLineGauageView(rail: rail)
			.onTapGesture(count: 2) {
				rail.connect()
			}
			.onTapGesture(count: 1) {
				rail.lights = rail.lights == 0.0 ? 1.0 : 0.0
			}
			.onLongPressGesture {
				crown = 0
				rail.fullStop()
			}
			.focusable(true)
			.digitalCrownRotation(
				detent: $crown, from: -256, through: 256, by: 1,
				sensitivity: .high, isContinuous: false,
				 isHapticFeedbackEnabled: true,
				 onChange: { _ in }, onIdle: {})
			.onChange(of: crown) { newValue in
				rail.power = Double(newValue) / 256.0
			}
	}
}

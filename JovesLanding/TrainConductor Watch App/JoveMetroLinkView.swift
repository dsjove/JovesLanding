//
//  JoveMetroLineView.swift
//  TrainConductor
//
//  Created by David Giovannini on 12/5/22.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct JoveMetroLineView: View {
	@ObservedObject private var facility: JoveMetroLine
	@State private var crown = Int()

	init(facility: JoveMetroLine) {
		self.facility = facility
	}

	var body: some View {
		JoveMetroLineGauageView(facility: facility)
			.onTapGesture(count: 1) {
				facility.lights = facility.lights == 0.0 ? 1.0 : 0.0
			}
			.onLongPressGesture {
				switch (facility.connectionState) {
					case .connected:
					crown = 0
						facility.fullStop()
					case .connecting:
						break
					case .disconnected:
						facility.connect()
				}
			}
			.focusable(true)
			.digitalCrownRotation(
				detent: $crown, from: -100, through: 100, by: 1,
				sensitivity: .high, isContinuous: false,
				 isHapticFeedbackEnabled: true,
				 onChange: { _ in }, onIdle: {})
			.onChange(of: crown) { newValue in
				facility.powerControl = Double(newValue) / 100.0
			}
	}
}

#Preview {
	JoveMetroLineView(facility: JoveMetroLine())
}

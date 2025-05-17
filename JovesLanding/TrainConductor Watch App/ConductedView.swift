//
//  ConductedView.swift
//  JovesLanding
//
//  Created by David Giovannini on 4/4/25.
//

import SwiftUI
import BLEByJove
import Infrastructure

typealias JoveMetroLineView = ConductedView<JoveMetroLine>
typealias CityStreetsView = ConductedView<CityStreets>
typealias JoveExpressView = ConductedView<JoveExpress>

struct ConductedView<F: MotorizedFacility>: View {
	let facility: F
	@State private var crown = Int()

	init(facility: F) {
		self.facility = facility
	}
	
	var body: some View {
		MotorizedFacilityGauageView(facility: facility)
			.onTapGesture(count: 1) {
				facility.lighting.power.control = facility.lighting.power.control == 0.0 ? 1.0 : 0.0
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
					facility.motor.power.control = Double(newValue) / 100.0
				}
	}
}

#Preview {
	ConductedView(facility: JoveMetroLine())
}

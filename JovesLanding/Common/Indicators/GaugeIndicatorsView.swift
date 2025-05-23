//
//  GaugeIndicatorsView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/14/22.
//

import SwiftUI
import Infrastructure
import SbjGauge
import BLEByJove

struct GaugeIndicators {
	let image: Image
	var connectionState: ConnectionState = .disconnected
	var heartBeat: Int = -1
	var motorState: MotorState = .idle
	var battery: Double? = 0
	var light: Double = 0.0
}

struct Indicator: ViewModifier {
	var padding: Double = 2.0
	func body(content: Content) -> some View {
		ZStack {
			Circle()
				.fill(Color("GaugeIndicator"))
				.aspectRatio(1, contentMode: .fit)
			content
				.aspectRatio(1, contentMode: .fit)
				.padding(padding)
		}
	}
}

extension View {
	func indicator(padding: Double = 2.0) -> some View {
		modifier(Indicator(padding: padding))
	}
}

struct GaugeIndicatorsView: View {
	let width: Double
	let indicators: GaugeIndicators

	var body: some View {
		MotorIndicatorView(image: indicators.image, motorState: indicators.motorState)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		ConnectionIndicatorView(connectionState: indicators.connectionState, heartBeat: indicators.heartBeat)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		LightIndicatorView(on: indicators.light)
			.indicator(padding: width * 0.15)
			.frame(width: width)

		if let battery = indicators.battery {
			BatteryIndicatorView(progress: battery)
				.indicator(padding: width * 0.15)
				.frame(width: width)
		}
	}
}

#Preview {
	GaugeIndicatorsView(width: 300, indicators: .init(image: .init(systemName: "person")))
}

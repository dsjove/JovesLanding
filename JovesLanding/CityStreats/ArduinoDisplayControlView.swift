//
//  ArduinoDisplayControlView.swift
//  JovesLanding
//
//  Created by David Giovannini on 3/25/25.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct ArduinoDisplayControlView: View {
	@ObservedObject var display: ArduinoDisplay.Power
	@State private var isScrolling = false

	var body: some View {
		VStack {
			HStack() {
				Button("Fill") {
					display.control.fill(.on)
				}
				.frame(maxWidth: .infinity)
				Button("Clear") {
					display.control.fill(.off)
				}
				.frame(maxWidth: .infinity)
				Button("Invert") {
					display.control.fill(.toggle)
				}
				.frame(maxWidth: .infinity)
				Button("Flip X") {
					display.control.flip(true, false)
				}
				.frame(maxWidth: .infinity)
				Button("Flip Y") {
					display.control.flip(false, true)
				}
				.frame(maxWidth: .infinity)
				Toggle(isOn: $isScrolling) {
					Text("Scroll")
						.font(.headline)
				}
#if !os(tvOS)
				.toggleStyle(ButtonToggleStyle())
#endif
				.frame(maxWidth: .infinity)
			}
			ArduinoR4MatrixView(value: display.feedback, interactive: isScrolling ? .scroll : .draw) {
				display.control = $0
			}
		}
	}
}

#Preview {
	ArduinoDisplayControlView(display: ArduinoDisplay.Power(
			broadcaster: BTDevice(preview: "Sample"),
			characteristic: BTCharacteristicIdentity(),
			transfomer: .init()))
}

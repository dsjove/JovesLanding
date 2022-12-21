//
//  MotorIndicatorView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/16/22.
//

import SwiftUI
import TrainsByJove

struct MotorIndicatorView: View {
	let motorState: MotorState
	
    var body: some View {
		Image(systemName: "train.side.front.car")
			.resizable()
			.foregroundColor(color())
			.aspectRatio(contentMode: .fit)
	}

    private func color() -> Color {
		switch motorState {
			case .idle:
				return Color("Motor/Idle")
			case .forward:
				return Color("Motor/Forward")
			case.reverse:
				return Color("Motor/Reverse")
		}
    }
}

struct MotorIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			MotorIndicatorView(motorState: .reverse)
			MotorIndicatorView(motorState: .idle)
			MotorIndicatorView(motorState: .forward)
		}
    }
}

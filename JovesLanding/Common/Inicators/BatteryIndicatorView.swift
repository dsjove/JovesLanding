//
//  BatteryIndicatorView.swift
//  MaskingStuff
//
//  Created by Federico on 16/04/2022.
//
import SwiftUI
import TrainsByJove

struct BatteryIndicatorView: View {
    let progress: Double?

    var body: some View {
		ZStack {
			Image(systemName: iconName())
				.resizable()
				.scaledToFit()
				.foregroundStyle(color(), .black)
			//Text(progress != nil ? "\(Int(self.progress! * 100))%" : "")
			.lineLimit(1)
				.foregroundColor(Color("Battery/Text"))
		}
	}

    private func iconName() -> String {
		if let progress {
			if progress >= 0.90 {
				return "battery.100"
			}
			if progress >= 0.60 {
				return "battery.75"
			}
			if progress >= 0.30 {
				return "battery.50"
			}
			return "battery.25"
		}
		return "battery.0"
    }

    private func color() -> Color {
		if let progress {
			if progress >= 0.50 {
				return Color("Battery/High")
			}
			return Color("Battery/Low")
		}
		return Color("Battery/Disconnect")
    }
}

struct BatteryView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			BatteryIndicatorView(progress: nil)
			BatteryIndicatorView(progress: 0.29)
			BatteryIndicatorView(progress: 0.59)
			BatteryIndicatorView(progress: 0.89)
			BatteryIndicatorView(progress: 0.90)
			BatteryIndicatorView(progress: 1.0)
			}
    }
}

//
//  LightIndicatorView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/16/22.
//

import SwiftUI

struct LightIndicatorView: View {
	let on: Double
    var body: some View {
		ZStack {
			Image(systemName: "lightbulb.fill")
				.resizable()
				.scaledToFit()
				.foregroundColor(
					Color("Lights/Off"))
				.aspectRatio(contentMode: .fit)
			Image(systemName: "lightbulb.fill")
				.resizable()
				.scaledToFit()
				.foregroundColor(
					Color("Lights/On").opacity(on))
				.aspectRatio(contentMode: .fit)
		}
	}
}

struct LightIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			LightIndicatorView(on: 0.0)
			LightIndicatorView(on: 0.5)
			LightIndicatorView(on: 1.0)
		}
    }
}

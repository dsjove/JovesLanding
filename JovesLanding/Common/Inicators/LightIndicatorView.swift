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
				.aspectRatio(contentMode: .fit)
				.foregroundColor(
					Color("Lights/Off"))
			Image(systemName: "lightbulb.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(
					Color("Lights/On").opacity(on))
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

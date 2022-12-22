//
//  Indicator.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/17/22.
//

import SwiftUI

struct Indicator: ViewModifier {
	var padding: Double = 2.0
    func body(content: Content) -> some View {
		ZStack {
			Circle()
				.fill(Color("Gauge/Indicator"))
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

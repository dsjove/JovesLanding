//
//  Gauge+Indicators.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	@ViewBuilder
	static func indicators(
			geom: Geometry,
			model: Model,
			radius: Double = 0.200,
			width: Double = 0.185,
			@ViewBuilder indicators: (Geometry, Model, Double)->some View = {_, _, _ in EmptyView()}) -> some View {
		IndicatorLayout(radius: radius) {
			indicators(geom, model, width)
		}
	}
}

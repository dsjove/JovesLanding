//
//  Gauge+Background.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	@ViewBuilder
	public static func background(
			geom: Geometry,
			model: Model) -> some View {
		Circle()
			.fill(.radialGradient(
				stops: [
					Gradient.Stop(
						color: Color(0.375, 0.375, 0.375), location: 0.35),
					Gradient.Stop(
						color: Color(0.265, 0.265, 0.265), location: 0.96),
					Gradient.Stop(
						color: Color(0.125, 0.125, 0.125), location: 1.0),
				], center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: geom.radius))
		Circle()
			.fill(.radialGradient(
				stops: [
					Gradient.Stop(
						color: Color(0.156, 0.375, 0.664, 0.234), location: 0.60),
					Gradient.Stop(
						color: Color(0.059, 0.132, 0.382, 0.312), location: 0.85),
					Gradient.Stop(
						color: Color(0.0, 0.0, 0.0, 0.468), location: 0.96),
					Gradient.Stop(
						color: Color(0.0, 0.0, 0.0, 0.546), location: 1.0),
				], center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: geom.radius))
	}

	@ViewBuilder
	public static func foregound(
			geom: Geometry,
			model: Model,
			outerRadius: Double = 0.995,
			innerRadius: Double = 0.988,
			color: Color = Color(packaged: "Gauge/Standard/Rim")) -> some View {

		let radius = geom.radius(outerRadius)
		let lineWidth = radius - geom.radius(innerRadius)
		Circle()
			.strokeBorder(color, lineWidth: lineWidth)
			.frame(width: radius * 2.0)
	}
}

private extension Color {
	init(_ r: Double, _ g: Double, _ b: Double, _ o: Double = 1.0) {
		self = Color( red: r, green: g, blue: b).opacity(o)
	}
}

struct GaugeBackground_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Container(Gauge.Model()) { geom, model in
			Gauge.background(geom: geom, model: model)
			Gauge.foregound(geom: geom, model: model)
		}
	}
}

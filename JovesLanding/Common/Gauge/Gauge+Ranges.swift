//
//  Gauge+Ranges.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	struct Range {
		var values: ClosedRange<Double> = 0...0
		var color: Color =  Color.white
		var textColor: Color = Color("Gauge/RangeText")
		var label: String = ""
	}

	@ViewBuilder
	static func ranges(
			geom: Geometry,
			model: Model,
			outerRadius: Double = 0.989,
			innerRadius: Double = 0.900,
			@ViewBuilder range: @escaping (Geometry, Model, Double, Double, Range)->some View = Gauge.range) -> some View {
		ForEach(Array(model.ranges.enumerated()), id: \.self.offset) {
			range(geom, model, outerRadius, innerRadius, $0.element)
		}
	}

	@ViewBuilder
	static func range(
			geom: Geometry,
			model: Model,
			outerRadius: Double = 0.989,
			innerRadius: Double = 0.900,
			range: Range) -> some View {
		if range.values.lowerBound == range.values.upperBound {
			EmptyView()
		}
		else {
			let radius = geom.radius(outerRadius)
			let lineWidth = radius - geom.radius(innerRadius)

			let angle1 = model.angle(Double(range.values.lowerBound), -90)
			let angle2 = model.angle(Double(range.values.upperBound), -90)
			Path { path in
				path.addArc(
					center: geom.center,
					radius: radius - lineWidth / 2.0,
					startAngle: angle1,
					endAngle: angle2,
					clockwise: false)
			}
			.stroke(range.color, lineWidth: lineWidth)
			let angle3 = model.angle(Double(range.values.lowerBound)) + (angle2 - angle1) / 2.0
			CircleTextView(
				text: range.label,
				angle: angle3, tooFar: angle2 - angle1)
					.font(.system(size: lineWidth * 0.8))
					.foregroundColor(range.textColor)
					.frame(width: radius*2, height: radius * 2)
		}
	}
}

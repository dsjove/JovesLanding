//
//  Gauge+Ranges.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	struct Range {
		var values: ClosedRange<Double> = 0...5
		var color: Color =  Color("Gauge/Standard/RangeBackground")
		var textColor: Color = Color("Gauge/Standard/RangeText")
		var label: String = ""
		var outerRadius: Double = 0.989
		var innerRadius: Double = 0.900
	}

	@ViewBuilder
	static func ranges(
			geom: Geometry,
			model: Model,
			@ViewBuilder range: @escaping (Geometry, Model, Range)->some View = Gauge.range) -> some View {
		ForEach(Array(model.ranges.enumerated()), id: \.self.offset) {
			range(geom, model, $0.element)
		}
	}

	@ViewBuilder
	static func range(
			geom: Geometry,
			model: Model,
			range: Range) -> some View {
		if range.values.lowerBound == range.values.upperBound {
			EmptyView()
		}
		else {
			let radius = geom.radius(range.outerRadius)
			let lineWidth = radius - geom.radius(range.innerRadius)

			let angle1 = model.angle(Double(range.values.lowerBound), .degrees(-90))
			let angle2 = model.angle(Double(range.values.upperBound), .degrees(-90))
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

struct GaugeRanges_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Container(model: {
			var model = Gauge.Model()
			model.ranges = [Gauge.Range()]
			return model
		}()) { geom, model in
			Gauge.ranges(geom: geom, model: model)
		}
	}
}

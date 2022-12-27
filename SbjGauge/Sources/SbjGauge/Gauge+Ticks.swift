//
//  Gauge+Ticks.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	struct Tick {
		var increment: Double = 1.0
		var outerRadius: Double = 0.900
		var innerRadius: Double = 0.870
		var thickness: Double = 0.004
		var color: Color = Color("Gauge/Standard/Tick")
		var transform: (Double)->String? = {Int($0).description}
		var draw: (Int, Double, ClosedRange<Double>)->Bool = { _, _, _ in true }
	}

	@ViewBuilder
	static func ticks(
			geom: Geometry,
			model: Model,
			@ViewBuilder tick: @escaping (Geometry, Model, Tick, Double)->some View = Gauge.tick) -> some View {
		ForEach(Array(model.ticks.enumerated()), id: \.offset) { (e, t) in
			ForEach(model.enumerated(inc: t.increment), id: \.0) { (i, v) in
				if t.draw(i, v, model.minMax) {
					tick(geom, model, t, v)
				}
			}
		}
	}

	@ViewBuilder
	static func tick(
			geom: Geometry,
			model: Model,
			tick: Tick,
			value: Double) -> some View {
		let outer = geom.radius(tick.outerRadius)
		let inner = geom.radius(tick.innerRadius)
		let angle = model.angle(value)

		let lineWidth = geom.width(tick.thickness)
		if lineWidth > 0 {
			Path { path in
				path.move(to: geom.center(x: 0, y: -outer))
				path.addLine(to: geom.center(x: 0, y: -inner))
			}
			.rotation(angle)
			.stroke(tick.color, lineWidth: lineWidth)
		}
		if let text = tick.transform(value) {
			let outer = geom.radius(tick.outerRadius)
			let inner = geom.radius(tick.innerRadius)
			let height = outer - inner
			Text(text)
				.lineLimit(1)
				.font(.system(size: height))
				.foregroundColor(tick.color)
				.offset(y: -outer + height/2.0)
				.rotationEffect(angle)
		}
	}
}

struct GaugeTicks_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Container(model: Gauge.Model()) { geom, model in
			Gauge.ticks(geom: geom, model: model)
		}.background(Color.green)
	}
}

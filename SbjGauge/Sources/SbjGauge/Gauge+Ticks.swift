//
//  Gauge+Ticks.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

public extension Color {
    init(packaged: String) {
		self = Color(UIColor(named: packaged, in: .module, compatibleWith: nil)!)
    }
}

extension Gauge {
	public struct Tick {
		public init(
			increment: Double = 1.0,
			outerRadius: Double = 0.900,
			innerRadius: Double = 0.870,
			thickness: Double = 0.004,
			color: Color = Color(packaged: "Gauge/Standard/Tick"),
			transform: @escaping (Double) -> String? = {Int($0).description},
			draw: @escaping (Int, Double, ClosedRange<Double>) -> Bool = { _, _, _ in true }) {
			self.increment = increment
			self.outerRadius = outerRadius
			self.innerRadius = innerRadius
			self.thickness = thickness
			self.color = color
			self.transform = transform
			self.draw = draw
		}

		public var increment: Double = 1.0
		public var outerRadius: Double = 0.900
		public var innerRadius: Double = 0.870
		public var thickness: Double = 0.004
		public var color: Color = Color(packaged: "Gauge/Standard/Tick")
		public var transform: (Double)->String? = {Int($0).description}
		public var draw: (Int, Double, ClosedRange<Double>)->Bool = { _, _, _ in true }
	}

	@ViewBuilder
	public static func ticks(
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
	public static func tick(
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
		Gauge.Container(Gauge.Model()) { geom, model in
			Gauge.ticks(geom: geom, model: model)
		}.background(Color.green)
	}
}

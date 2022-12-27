//
//  Gauge+Needles.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	struct Needle {
		var idx: Int = 0
		var radius: Double = 0.660
		var width: Double = 0.055
		var color1: Color = Color("Gauge/Standard/Needle1")
		var color2: Color = Color("Gauge/Standard/Needle2")
	}

	@ViewBuilder
	static func needles(
			geom: Geometry,
			model: Model,
			@ViewBuilder needle: @escaping (Geometry, Model, Needle)->some View = Gauge.needle,
			@ViewBuilder screw: @escaping (Geometry, Model)->some View = Gauge.screw) -> some View {
		ForEach(Array(model.values.enumerated()), id: \.offset) {
			if let n = model.needles[$0.offset] {
				needle(geom, model, n)
				.rotationEffect(model.angle($0.element))
			}
		}
		Gauge.screw(geom: geom, model: model)
	}

	@ViewBuilder
	static func needle(
			geom: Geometry,
			model: Model,
			needle: Needle) -> some View {
		let actualRadius = geom.radius(needle.radius)
		let actualWidth = geom.width(needle.width)
		Path { path in
			path.move(to: geom.center)
			path.addLine(to: geom.center(x: actualWidth / 2.0, y: 0))
			path.addLine(to: geom.center(x: 0, y: -actualRadius))
		}
		.fill(needle.color1)

		Path { path in
			path.move(to: geom.center)
			path.addLine(to: geom.center(x: -actualWidth / 2.0, y: 0))
			path.addLine(to: geom.center(x: 0, y: -actualRadius))
		}
		.fill(needle.color2)
	}

	@ViewBuilder
	static func screw(
			geom: Geometry,
			model: Model) -> some View {
		let outerRadius: Double = 0.120
		let outerColor: Color = Color("Gauge/Standard/ScrewOuter")
		let innerRadius: Double = 0.060
		let innerColor: Color = Color("Gauge/Standard/ScrewInner")
		Circle()
			.fill(outerColor)
			.frame(width: geom.radius(outerRadius))
		Circle()
			.fill(innerColor)
			.frame(width: geom.radius(innerRadius))
	}
}

struct GaugeNeedles_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Container(model: Gauge.Model()) { geom, model in
			Gauge.needles(geom: geom, model: model)
		}
	}
}

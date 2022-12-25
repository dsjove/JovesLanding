//
//  Gauge.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/23/22.
//  Inspired by: https://github.com/Will-tm/WMGaugeView
//

import SwiftUI

public enum Gauge {
	struct GState {
		var values: [Double] = [0.0]
		var minMax: ClosedRange<Double> = 0...0
		var angles: ClosedRange<Double> = 0...360

		var ranges: [Gauge.GRange] = []
		var ticks: [Gauge.GTick] = []
		var needles: [Int: Gauge.GNeedle] = [0:Gauge.GNeedle()]

		func enumerated(inc: Double) -> [(Int, Double)] {
			var ds: [(Int, Double)] = [];
			var v = minMax.lowerBound
			var i = 0
			while v <= minMax.upperBound {
				ds.append((i, v))
				v += inc
				i += 1
			}
			return ds
		}

		func angle(_ value: Double, _ offset: Double = 0.0) -> Angle {
			let scale = value / (minMax.upperBound - minMax.lowerBound)
			let angle = scale * (angles.upperBound - angles.lowerBound)
			return .degrees(angle + offset)
		}
	}

	struct Geometry {
		private let width: Double
		private let height: Double

		init(_ geom: GeometryProxy) {
			width = geom.size.width
			height = geom.size.height
		}

		var diameter: Double { min(width, height) }

		var radius: Double { diameter / 2.0 }

		var center: CGPoint { CGPoint(x: width / 2.0, y: height / 2.0) }

		func center(x: Double, y: Double) -> CGPoint {
			CGPoint(x: (width / 2.0) + x, y: (height / 2.0) + y)
		}

		func radius(_ unit: Double) -> Double {
			radius * unit
		}

		func width(_ unit: Double) -> Double {
			diameter * unit
		}
	}

	struct GView<Content: View>: View {
		let state: GState
		@ViewBuilder var content: (Geometry, GState) -> Content

		var body: some View {
			GeometryReader { geometry in
			let geom = Geometry(geometry)
				ZStack {
					Color.clear
					content(geom, state)
				}
			}
		}
	}

	@ViewBuilder
	static func standard(
			geom: Geometry,
			state: GState,
			@ViewBuilder indicators: (Geometry, GState, Double)->some View = {_, _, _ in EmptyView()}) -> some View {
		Gauge.background(geom: geom, state: state)
		Gauge.ticks(geom: geom, state: state)
		Gauge.indicators(geom: geom, state: state, indicators: indicators)
		Gauge.ranges(geom: geom, state: state)
		Gauge.needles(geom: geom, state: state)
		Gauge.screw(geom: geom, state: state)
		Gauge.rim(geom: geom, state: state)
	}

	struct Clock: View {
		@State var gaugeState: GState = {
			var state = GState()
			state.minMax = 0...43200
			state.values = [10000, 20000, 30000]
			state.ranges = [
				GRange(values:10000.0...20000.0, color: Color(0.098, 0.098, 0.439)),
				GRange(values:20000.0...30000.0, color: Color(0.098, 0.098, 0.439)),
				GRange(values:30000.0...40000.0, color: Color(1.0, 0.858, 0.0))
			]
			return state
		}()

		var seconds: Double {
			get {
				gaugeState.values[0]
			}
			set {
				gaugeState.values[1] = 43200 / (60 * newValue)
				gaugeState.values[2] = 43200 / (60 * 60 * newValue)
			}
		}

		var body: some View {
			GView(state: gaugeState) { geom, state in
				Gauge.background(geom: geom, state: state)
				Gauge.ticks(geom: geom, state: state)
				//Gauge.indicators(geom: geom, state: state, indicators: indicators)
				Gauge.ranges(geom: geom, state: state)
				Gauge.needles(geom: geom, state: state)
				Gauge.screw(geom: geom, state: state)
				Gauge.rim(geom: geom, state: state)
			}
		}
	}
}

extension Gauge {
	struct GRange {
		var values: ClosedRange<Double> = 0...0
		var color: Color =  Color.white
		var textColor: Color = Color("Gauge/RangeText")
		var label: String = ""
	}

	struct GTick {
		var increment: Double = 1.0
		var outerRadius: Double = 0.900
		var innerRadius: Double = 0.870
		var thickness: Double = 0.004
		var color: Color = Color("Gauge/Tick")
		var transform: (Double)->String? = {Int($0).description}
		var draw: (Int, Double, ClosedRange<Double>)->Bool = { _, _, _ in true }
	}

	struct GNeedle {
		var idx: Int = 0
		var radius: Double = 0.660
		var width: Double = 0.055
		var color1: Color = Color("Gauge/Needle1")
		var color2: Color = Color("Gauge/Needle2")
	}

	@ViewBuilder
	static func background(
			geom: Geometry,
			state: GState) -> some View {
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
	static func rim(
			geom: Geometry,
			state: GState,
			outerRadius: Double = 0.995,
			innerRadius: Double = 0.990,
			color: Color = Color("Gauge/Rim")) -> some View {

		let radius = geom.radius(outerRadius)
		let lineWidth = radius - geom.radius(innerRadius)
		Circle()
			.strokeBorder(color, lineWidth: lineWidth)
			.frame(width: radius * 2.0)
	}

	@ViewBuilder
	static func screw(
			geom: Geometry,
			state: GState,
			outerRadius: Double = 0.120,
			outerColor: Color = Color("Gauge/ScrewOuter"),
			innerRadius: Double = 0.060,
			innerColor: Color = Color("Gauge/ScrewInner")) -> some View {
		Circle()
			.fill(outerColor)
			.frame(width: geom.radius(outerRadius))
		Circle()
			.fill(innerColor)
			.frame(width: geom.radius(innerRadius))
	}

	@ViewBuilder
	static func indicators(
			geom: Geometry,
			state: GState,
			radius: Double = 0.200,
			width: Double = 0.185,
			@ViewBuilder indicators: (Geometry, GState, Double)->some View = {_, _, _ in EmptyView()}) -> some View {
		IndicatorLayout(radius: radius) {
			indicators(geom, state, width)
		}
	}

	@ViewBuilder
	static func needles(
			geom: Geometry,
			state: GState,
			@ViewBuilder needle: @escaping (Geometry, GState, GNeedle)->some View = Gauge.needle) -> some View {
		ForEach(Array(state.values.enumerated()), id: \.offset) {
			if let n = state.needles[$0.offset] {
				needle(geom, state, n)
				.rotationEffect(state.angle($0.element))
			}
		}
	}

	@ViewBuilder
	static func needle(
			geom: Geometry,
			state: GState,
			needle: GNeedle) -> some View {
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
	static func ranges(
			geom: Geometry,
			state: GState,
			outerRadius: Double = 0.989,
			innerRadius: Double = 0.900,
			@ViewBuilder range: @escaping (Geometry, GState, Double, Double, GRange)->some View = Gauge.range) -> some View {
		ForEach(Array(state.ranges.enumerated()), id: \.self.offset) {
			range(geom, state, outerRadius, innerRadius, $0.element)
		}
	}

	@ViewBuilder
	static func range(
			geom: Geometry,
			state: GState,
			outerRadius: Double = 0.989,
			innerRadius: Double = 0.900,
			range: GRange) -> some View {
		if range.values.lowerBound == range.values.upperBound {
			EmptyView()
		}
		else {
			let radius = geom.radius(outerRadius)
			let lineWidth = radius - geom.radius(innerRadius)

			let angle1 = state.angle(Double(range.values.lowerBound), -90)
			let angle2 = state.angle(Double(range.values.upperBound), -90)
			Path { path in
				path.addArc(
					center: geom.center,
					radius: radius - lineWidth / 2.0,
					startAngle: angle1,
					endAngle: angle2,
					clockwise: false)
			}
			.stroke(range.color, lineWidth: lineWidth)
			let angle3 = state.angle(Double(range.values.lowerBound)) + (angle2 - angle1) / 2.0
			CircleTextView(
				text: range.label,
				angle: angle3, tooFar: angle2 - angle1)
					.font(.system(size: lineWidth * 0.8))
					.foregroundColor(range.textColor)
					.frame(width: radius*2, height: radius * 2)
		}
	}

	@ViewBuilder
	static func ticks(
			geom: Geometry,
			state: GState,
			@ViewBuilder tick: @escaping (Geometry, GState, GTick, Double)->some View = Gauge.tick) -> some View {
		ForEach(Array(state.ticks.enumerated()), id: \.offset) { (e, t) in
			ForEach(state.enumerated(inc: t.increment), id: \.0) { (i, v) in
				if t.draw(i, v, state.minMax) {
					tick(geom, state, t, v)
				}
			}
		}
	}

	@ViewBuilder
	static func tick(
			geom: Geometry,
			state: GState,
			tick: GTick,
			value: Double) -> some View {
		let outer = geom.radius(tick.outerRadius)
		let inner = geom.radius(tick.innerRadius)
		let angle = state.angle(value)

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

private extension Color {
	init(_ r: Double, _ g: Double, _ b: Double, _ o: Double = 1.0) {
		self = Color( red: r, green: g, blue: b).opacity(o)
	}
}

struct Gauge_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Clock()
	}
}

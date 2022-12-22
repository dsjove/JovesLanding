//
//  GaugeView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/12/22.
//  Based on: https://github.com/Will-tm/WMGaugeView
//

import SwiftUI
import TrainsByJove // engine state

extension GaugeView.State {
	static var clock: GaugeView.State {
		var state = GaugeView.State()
		state.minMax = 0...43200
		state.majorMod = 3600
		state.minorMod = 600
		state.skipfirst = true
		state.values = [10000, 20000, 30000]
		state.transformMajor = {($0 / state.majorMod).description}
		//TODO: make reasonable
		state.ranges = [
			GRange(values:10000.0...20000.0, color: Color(0.098, 0.098, 0.439)),
			GRange(values:20000.0...30000.0, color: Color(0.098, 0.098, 0.439)),
			GRange(values:30000.0...40000.0, color: Color(1.0, 0.858, 0.0))
		]
		return state
	}
}

//TODO: make into generic paramter for indicator layer
struct Indicators {
	var connectionState: ConnectionState = .disconneted
	var motorState: MotorState = .idle
	var battery: Double? = nil
	var light: Double = 0.0
}

struct GaugeView: View {
	struct State {
		var values: [Double] = []
		var second: Double? = nil
		var minMax: ClosedRange<Int> = 0...0 // TODO: Double

		//TODO: ticks: [Double]
		var majorMod: Int = 0
		var minorMod: Int = 0

		var skipfirst: Bool = false
		var skipLast: Bool = false
		var angles: ClosedRange<Double> = 0...360

		//TODO: should be view builder
		var transformMajor: (Int)->String = {$0.description}
		struct GTick {
			var mod: Int
			var length: Double
			var thickness: Double
			var colorLine: Color
			var colorText: Color
			var transform: (Int)->String = {$0.description}
		}

		var indicators: Indicators?

		struct GRange {
			var values: ClosedRange<Double> = 0...0
			var color: Color =  Color.white
			var label: String = ""
		}

		var ranges: [GRange] = []

		func angle(_ value: Double, _ offset: Double = 0.0) -> Angle {
			let scale = value / (Double(minMax.upperBound) - Double(minMax.lowerBound))
			let angle = scale * (Double(angles.upperBound) - Double(angles.lowerBound))
			return .degrees(angle + offset)
		}

		var tickMinMax : ClosedRange<Int> {
			var l = minMax.lowerBound
			if skipfirst {
				l += 1
			}
			var u = minMax.upperBound
			if skipLast {
				u -= 1
			}
			return l...u
		}

		func isBigTick(_ idx: Int) -> Bool {
			majorMod > 0 && ((minMax.lowerBound + majorMod + idx) % majorMod) == 0
		}

		func isLilTick(_ idx: Int) -> Bool {
			minorMod > 0 && ((minMax.lowerBound + minorMod + idx) % minorMod) == 0
		}
	}

	struct Rings {
		var rimRadius: Double = 0.995
		var rimWidth: Double = 0.01
		var rangeRadius: Double = 0.985
		var rangeWidth: Double = 0.05
		var tickRadius: Double = 0.88
		var tick1Width: Double = 0.0
		var tick2Width: Double = 0.0
		var needleRadius: Double = 0.04
		var needleWidth: Double = 0.007
		var indicatorRadius: Double = 0.2
		var indicatorWidth: Double = 0.2
		var screw1Radius: Double = 0.06
		var screw2Radius: Double = 0.03
	}

	//TODO: replace with ring information
	//TODO: try to go all normalized graphics
	struct Geometry {
		let width: Double
		let height: Double

		init(_ geom: GeometryProxy) {
			width = geom.size.width
			height = geom.size.height
		}

		var unit: Double { min(width, height) }

		var center: CGPoint { CGPoint(x: width / 2.0, y: height / 2.0) }

		func center(x: Double, y: Double) -> CGPoint {
			CGPoint(x: (width / 2.0) + x, y: (height / 2.0) + y)
		}
/*
		func scale(_ v: Double, minV: Double = Double.leastNonzeroMagnitude, maxV: Double = Double.greatestFiniteMagnitude ) -> Double {
			max(min(v * unit, maxV), minV)
		}
*/
	}

	let state: State

	// Break out 7 (and sub) view builder functions
    var body: some View {
		GeometryReader { geometry in
			let geom = Geometry(geometry)
			ZStack {
				GaugeBackgroundView(geom: geom, state: state)
				GaugeTicksView(geom: geom, state: state)
				GaugeLabelView(geom: geom, state: state)
				GaugeRangeView(geom: geom, state: state)
				GaugeFullNeedleView(geom: geom, state: state)
				GaugeNeedleScrewView(geom: geom, state: state)
				GaugeRimView(geom: geom, state: state)
			}
			//.scaleEffect(CGSize(width: geometry.size.width, height: geometry.size.height))
		}
		.aspectRatio(1, contentMode: .fit)
    }

	struct GaugeBackgroundView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			Circle()
				.fill(.radialGradient(
					stops: [
						Gradient.Stop(
							color: Color(0.375, 0.375, 0.375), location: 0.35),
						Gradient.Stop(
							color: Color(0.265, 0.265, 0.265), location: 0.96),
						Gradient.Stop(
							color: Color(0.125, 0.125, 0.125), location: 1.0),
					], center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: geom.unit / 2.0))
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
					], center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: geom.unit / 2.0))
		}
	}

	struct GaugeLabelView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			//TODO: how do I apply view modifiers to view builder's sub
			MyRadialLayout(radius: 0.2) {
				let width = geom.unit *  0.185

				if let indicators = state.indicators {
					MotorIndicatorView(motorState: indicators.motorState)
						.indicator(padding: geom.unit * 0.02)
						.frame(width: width)

					LightIndicatorView(on: indicators.light)
						.indicator(padding: geom.unit * 0.02)
						.frame(width: width)

					ConnectionIndicatorView(connectionState: indicators.connectionState)
						.indicator(padding: geom.unit * 0.02)
						.frame(width: width)

					BatteryIndicatorView(progress: indicators.battery)
						.indicator(padding: geom.unit * 0.02)
						.frame(width: width)
				}
			}
		}
	}

	struct GaugeTicksView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			ForEach(state.tickMinMax, id: \.self) { idx in
				GaugeTickView(geom: geom, state: state, idx: idx)
			}
		}
	}

	struct GaugeTickView: View {
		let geom: Geometry
		let state: State
		let idx: Int

		var body: some View {
			let big = state.isBigTick(idx)
			let lil = state.isLilTick(idx)
			if (!big && !lil) {
				EmptyView()
			}
			else {
				let bigLen = geom.unit * 0.04
				let lilLen = geom.unit * 0.02
				let lineLength = (big ? bigLen : lil ? lilLen : 0)
				let lineWidth = geom.unit * (big ? 0.008 : 0.004)
				let offset = bigLen - lineLength
				let angle = state.angle(Double(idx))
				let move = ((geom.unit * -0.50) + bigLen) + (geom.unit * 0.06)
				Path { path in
					path.move(to: geom.center(x: 0, y: -offset))
					path.addLine(to: geom.center(x: 0, y: -lineLength - offset))
				}
				.offset(CGSize(width: 0, height: move))
				.rotation(angle)
				.stroke(Color("Gauge/Tick"), lineWidth: lineWidth)
				if (big) {
					let h = move + lineLength
					let v = state.transformMajor(idx)
					Text(v)
						.lineLimit(1)
						.font(.system(size: geom.unit * 0.06))
						.foregroundColor(Color("Gauge/Tick"))
						.offset(CGSize(width: 0.0, height: h))
						.rotationEffect(angle)
				}
			}
		}
	}

	struct GaugeRangeView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			ForEach(Array(state.ranges.enumerated()), id: \.self.offset) {
				GaugeRangeArcView(geom: geom, state: state, range: $0.element)
			}
		}
	}

	struct GaugeRangeArcView: View {
		let geom: Geometry
		let state: State
		let range: State.GRange

		var body: some View {
			if range.values.lowerBound == range.values.upperBound {
				EmptyView()
			}
			else {
				let angle1 = state.angle(Double(range.values.lowerBound), -90)
				let angle2 = state.angle(Double(range.values.upperBound), -90)
				let radius = (geom.unit / 2.0) - (geom.unit * 0.05) / 2.0 - geom.unit * 0.01
				Path { path in
					path.addArc(
						center: geom.center,
						radius: radius,
						startAngle: angle1,
						endAngle: angle2,
						clockwise: false)
				}
				.stroke(range.color, lineWidth: geom.unit * 0.05)
				let angle3 = state.angle(Double(range.values.lowerBound)) + (angle2 - angle1) / 2.0
				CircleTextView(
					text: range.label,
					angle: angle3, tooFar: angle2 - angle1)
						.font(.system(size: geom.unit * 0.05))
			}
		}
	}

	struct GaugeNeedleView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			Path { path in
				path.move(to: geom.center)
				path.addLine(to: geom.center(x: geom.unit * 0.04, y: 0))
				path.addLine(to: geom.center(x: 0, y: -geom.unit * 0.35))
			}
			.fill(Color("Gauge/Needle1"))

			Path { path in
				path.move(to: geom.center)
				path.addLine(to: geom.center(x: geom.unit * -0.04, y: 0))
				path.addLine(to: geom.center(x: 0, y: -geom.unit * 0.35))
			}
			.fill(Color("Gauge/Needle2"))
		}
	}

	struct GaugeFullNeedleView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			ForEach(Array(state.values.enumerated()), id: \.offset) {
				GaugeNeedleView(geom: geom, state: state)
					.rotationEffect(state.angle($0.element))
			}
		}
	}

	struct GaugeNeedleScrewView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			Circle()
				.fill(Color("Gauge/ScrewInner"))
				.frame(width: geom.unit * 0.08)
			Circle()
				.strokeBorder(Color("Gauge/ScrewOuter"), lineWidth: geom.unit * 0.02)
				.frame(width: geom.unit * 0.08)
		}
	}

	struct GaugeRimView: View {
		let geom: Geometry
		let state: State

		var body: some View {
			Circle()
				.strokeBorder(Color("Gauge/Rim"), lineWidth: geom.unit * 0.008)
				.frame(width: geom.width - geom.unit * 0.004)
		}
	}
}

private extension Color {
	init(_ r: Double, _ g: Double, _ b: Double, _ o: Double = 1.0) {
		self = Color( red: r, green: g, blue: b).opacity(o)
	}
}

struct GaugeView_Previews: PreviewProvider {
    static var previews: some View {
        GaugeView(state: GaugeView.State.clock)
    }
}

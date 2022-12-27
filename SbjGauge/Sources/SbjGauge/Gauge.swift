//
//  Gauge.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/23/22.
//  Inspired by: https://github.com/Will-tm/WMGaugeView
//

import SwiftUI

//TODO: make Model generic
protocol GaugePart: View {
	associatedtype Model
}

public enum Gauge {
	struct Container<Content: View>: View {
		let model: Model
		@ViewBuilder var content: (Geometry, Model) -> Content

		var body: some View {
			GeometryReader { geometry in
			let geom = Geometry(geometry)
				ZStack {
					Color.clear
					content(geom, model)
				}
			}
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
}

extension Gauge {
	struct Model {
		var values: [Double] = [0.0]
		var minMax: ClosedRange<Double> = 0...10
		var angles: ClosedRange<Angle> = .degrees(0) ... .degrees(360)

		//TODO: cache this with users
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

		func angle(_ value: Double, _ offset: Angle = Angle()) -> Angle {
			let scale = value / (minMax.upperBound - minMax.lowerBound)
			let angle = scale * (angles.upperBound.degrees - angles.lowerBound.degrees)
			return .degrees(angle) + offset
		}

		var ranges: [Gauge.Range] = []
		var ticks: [Gauge.Tick] = [Gauge.Tick()]
		var needles: [Int: Gauge.Needle] = [0:Gauge.Needle()]
	}
}

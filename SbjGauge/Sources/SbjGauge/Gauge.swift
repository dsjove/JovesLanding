//
//  Gauge.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/23/22.
//  Inspired by: https://github.com/Will-tm/WMGaugeView
//

import SwiftUI

//TODO: make Model generic
public protocol GaugePart: View {
	associatedtype Model
}

public enum Gauge {
	public struct Container<Content: View>: View {
		public let model: Model
		@ViewBuilder public var content: (Geometry, Model) -> Content

		public init(_ model: Model, @ViewBuilder _ content: @escaping (Geometry, Model) -> Content) {
			self.model = model
			self.content = content
		}

		public var body: some View {
			GeometryReader { geometry in
			let geom = Geometry(geometry)
				ZStack {
					Color.clear
					content(geom, model)
				}
			}
		}
	}

	public struct Geometry {
		private let width: Double
		private let height: Double

		public init(_ geom: GeometryProxy) {
			width = geom.size.width
			height = geom.size.height
		}

		public var diameter: Double { min(width, height) }

		public var radius: Double { diameter / 2.0 }

		public var center: CGPoint { CGPoint(x: width / 2.0, y: height / 2.0) }

		public func center(x: Double, y: Double) -> CGPoint {
			CGPoint(x: (width / 2.0) + x, y: (height / 2.0) + y)
		}

		public func radius(_ unit: Double) -> Double {
			radius * unit
		}

		public func width(_ unit: Double) -> Double {
			diameter * unit
		}
	}
}

extension Gauge {
	public struct Model {
		public var values: [Double] = [0.0]
		public var minMax: ClosedRange<Double> = 0...10
		public var angles: ClosedRange<Angle> = .degrees(0) ... .degrees(360)

		public init() {}

		//TODO: cache this with users
		public func enumerated(inc: Double) -> [(Int, Double)] {
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

		public func angle(_ value: Double, _ offset: Angle = Angle()) -> Angle {
			let scale = value / (minMax.upperBound - minMax.lowerBound)
			let angle = scale * (angles.upperBound.degrees - angles.lowerBound.degrees)
			return .degrees(angle) + offset
		}

		public var ranges: [Gauge.Range] = []
		public var ticks: [Gauge.Tick] = [Gauge.Tick()]
		public var needles: [Int: Gauge.Needle] = [0:Gauge.Needle()]
	}
}

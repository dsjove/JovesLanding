//
//  Gauge+Styles.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/26/22.
//

import SwiftUI

extension Gauge {
	@ViewBuilder
	static func standard(
			geom: Geometry,
			model: Model,
			@ViewBuilder indicators: (Geometry, Model, Double)->some View = {_, _, _ in EmptyView()}) -> some View {
		Gauge.background(geom: geom, model: model)
		Gauge.ticks(geom: geom, model: model)
		Gauge.indicators(geom: geom, model: model, indicators: indicators)
		Gauge.ranges(geom: geom, model: model)
		Gauge.needles(geom: geom, model: model)
		Gauge.foregound(geom: geom, model: model)
	}

	struct Clock: View {
		@State var model: Model = {
			var model = Model()
			model.minMax = 0...43200
			model.values = [10000, 20000, 30000]
			model.ranges = [
				Range(values:10000.0...20000.0, color: Color.blue),
				Range(values:20000.0...30000.0, color: Color.yellow),
				Range(values:30000.0...40000.0, color: Color.gray)
			]
			return model
		}()

		var seconds: Double {
			get {
				model.values[0]
			}
			set {
				model.values[1] = 43200 / (60 * newValue)
				model.values[2] = 43200 / (60 * 60 * newValue)
			}
		}

		var body: some View {
			Container(model: model) { geom, model in
				Gauge.background(geom: geom, model: model)
				Gauge.ticks(geom: geom, model: model)
				//Gauge.indicators(geom: geom, model: model, indicators: indicators)
				Gauge.ranges(geom: geom, model: model)
				Gauge.needles(geom: geom, model: model)
				Gauge.foregound(geom: geom, model: model)
			}
		}
	}
}

struct GaugeStyles_Previews: PreviewProvider {
	static var previews: some View {
		Gauge.Clock()
	}
}

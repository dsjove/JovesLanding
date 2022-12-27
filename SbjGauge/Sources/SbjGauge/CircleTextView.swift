//
//  CircleTextView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/12/22.
//  Based on: https://github.com/viettrungphan/SwiftUIGeometryPractice

import Foundation
import SwiftUI

public struct CircleTextView: View {
	var text: String
	var angle: Angle = Angle()
	var alignment: Double = 0.5
	var tooFar: Angle = Angle(degrees: 360)
	//TODO: option to center align first letter
	//TODO: option to span letters across range of angles
	//TODO: option for different baselines
	var guides: Bool = false

	@State private var textSizes: [Int:CGSize] = [:]

	public var body: some View {
		GeometryReader { geometry in
			let diameter = min(geometry.size.width, geometry.size.height)
			let radius = diameter / 2.0
			let fullAngle = self.angle(at: self.textSizes.count, radius: radius).0
			ZStack {
				Color.clear
				ForEach(Array(text.enumerated()), id: \.self.offset) { (offset, element) in
					let angle = self.angle(at: offset, radius: radius)
					VStack {
						Text(String(element))
							.background(Sizeable())
							.onPreferenceChange(SizePreferenceKey.self, perform: { size in
								self.textSizes[offset] = size
							})
						.border(Color.green.opacity(guides ? 1.0 : 0.0), width: 1)
						Spacer()
					}
					.frame(width: diameter, height: diameter)
					.rotationEffect(angle.0)
					.opacity(angle.1 > .degrees(360) ? 0 : 1)
				}
			}
			.rotationEffect(-fullAngle * self.alignment + self.angle)
			.opacity(fullAngle <= tooFar ? 1.0 : tooFar.degrees / fullAngle.degrees)
		}
	}

	private func angle(at index: Int, radius: Double) -> (Angle, Angle) {
		guard textSizes.isEmpty == false else { return (Angle(), Angle()) }
		var length = textSizes.filter{$0.key < index}.map{$0.value.width}.reduce(0,+)
		var bounds = length
		let height: Double
		if let mySize = textSizes[index] {
			length += mySize.width * 0.5
			bounds += mySize.width
			height = mySize.height
		}
		else {
			//TODO: height is almost what we want
			height = textSizes.first!.value.height
		}
		let realRadius = radius - height
		return (.radians(length/realRadius), .radians(bounds/realRadius))
	}
}

private struct SizePreferenceKey: PreferenceKey {
	typealias Value = CGSize
	static var defaultValue = CGSize()
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value = nextValue()
	}
}

private struct Sizeable: View {
	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(key: SizePreferenceKey.self, value: geometry.size)
		}
	}
}

struct CircleText_Preview: PreviewProvider {
	struct Preview: View {
		let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
		@State var angle =  Angle()

		var body: some View {
			CircleTextView(
					text: "The quick brown fox jumps over the lazy dog.",
					angle: angle,
					alignment: 0.0,
					guides: true)
				.font(.title2)
				.frame(width: 200, height: 300)
				.border(Color.green, width: 3)
				.animation(.linear(duration: 0.5), value: angle)
				.onReceive(timer) { _ in
					angle -= .degrees(10)
				}
		}
	}

	static var previews: some View {
		Preview()
	}
}
